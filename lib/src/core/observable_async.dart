// ignore_for_file: override_on_non_overriding_member

part of 'observable.dart';

/// This observable class is async, based on [StreamController].
/// See [Observable] for same functionality based on ChangeNotifier,
/// You can use it like usual broadcast StreamController anywhere
/// Must always call dispose when use [ObservableAsync]
class ObservableAsync<T> extends ObservableAsyncReadOnly<T>
    implements IObservableMutable<T>, StreamController<T> {
  /// Constructs a [Observable], with value setter and getter, pass initial value, handlers for
  /// [onListen], [onCancel], flag to handle events [sync] and
  /// flag [notifyOnlyIfChanged] - if true, listeners will be notified
  /// if new value not equals to old value
  ObservableAsync(super.initialValue,
      {super.notifyOnlyIfChanged, super.sync, super.onListen, super.onCancel});

  @override
  set value(T newValue) => _updateValue(newValue);

  @override
  set v(T v) => value = v;

  /// This will force unchanged value to notify listeners, even if notifyOnlyIfChanged set true
  /// Sends a data [event].
  ///
  /// Listeners receive this event in a later microtask.
  ///
  /// Note that a synchronous controller (created by passing true to the `sync`
  /// parameter of the `StreamController` constructor) delivers events
  /// immediately. Since this behavior violates the contract mentioned here,
  /// synchronous controllers should only be used as described in the
  /// documentation to ensure that the delivered events always *appear* as if
  /// they were delivered in a separate microtask.
  @override
  void add(T event) {
    if (isClosed) throw StateError("Cannot add new events after calling close");

    /// Experimental start
    ObsTrackingContext._handleModificationDuringTracking(this);

    /// Experimental end

    _value = event;
    _add(event);
  }

  @override
  StreamSink<T> get sink {
    _customSink ??= _CustomStreamSink<T>(_controller.sink, (value) {
      _value = value;
    });
    return _customSink!;
  }

  _CustomStreamSink<T>? _customSink;

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      _addError(error, stackTrace);

  @override
  Future addStream(Stream<T> source, {bool? cancelOnError}) =>
      _addStream(source, cancelOnError: cancelOnError);
}

/// This observable class is async, based on StreamController.
/// See [ObservableReadOnly] for same functionality based on ChangeNotifier,
/// Must always call dispose when use [ObservableAsync]
/// This one is read only variant, you can't set it's value
class ObservableAsyncReadOnly<T> implements IObservableAsync<T> {
  late final StreamController<T> _controller;
  T _value;

  /// If true, listeners will be notified if new value not equals to old value
  /// Default true
  late bool _notifyOnlyIfChanged;

  bool get notifyOnlyIfChanged => _notifyOnlyIfChanged;

  /// Constructs a [Observable], with value setter and getter, pass initial value, handlers for
  /// [onListen], [onCancel], flag to handle events [sync] and
  /// flag [notifyOnlyIfChanged] - if true, listeners will be notified
  /// if new value not equals to old value
  ObservableAsyncReadOnly(
    this._value, {
    bool notifyOnlyIfChanged = true,
    void Function()? onListen,
    void Function()? onCancel,
    bool sync = false,
  }) {
    _controller = StreamController<T>.broadcast(
        sync: sync, onListen: onListen, onCancel: onCancel);
    _notifyOnlyIfChanged = notifyOnlyIfChanged;
  }

  @override
  T get value {
    ObsTrackingContext.current?._register(this);

    /// Experimental
    return _value;
  }

  @override
  T get v => value;

  @override
  ObservableStreamSubscription<T> listen(FutureOr<void> Function(T) onData,
      {bool fireImmediately = false}) {
    var subscription = _controller.stream.listen((event) {
      onData(event);
    }, onError: (e, s) {
      reportObservableFlutterError(e, s, this);
    });
    if (fireImmediately && !isClosed) {
      Future.microtask(() {
        try {
          onData(_value);
        } catch (exception, stack) {
          reportObservableFlutterError(exception, stack, this);
        }
      });
    }
    return ObservableStreamSubscription<T>(subscription);
  }

  StreamSubscription<T> listenAsStream(
    void Function(T)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _controller.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  void _updateValue(T newValue) {
    if (isClosed) throw StateError("Cannot update value after calling dispose");

    /// Experimental start
    ObsTrackingContext._handleModificationDuringTracking(this);

    /// Experimental end

    if (_value != newValue || !_notifyOnlyIfChanged) {
      _value = newValue;
      _add(_value);
    }
  }

  @override
  void notify() {
    if (isClosed) throw StateError("Cannot notify after calling dispose");
    _add(_value);
  }

  @override
  ObservableAsyncReadOnly<R> map<R>(R Function(T value) transform,
      {bool? notifyOnlyIfChanged}) {
    return MappedObservableAsyncReadOnly<T, R>(this, _controller, transform,
        notifyOnlyIfChanged: notifyOnlyIfChanged ?? _notifyOnlyIfChanged);
  }

  void _add(T event) {
    _controller.add(event);
  }

  /// Override is not necessary, and this class is not actually implements stream controller,
  /// but this makes more likely to understand which methods are implements to be compatible
  /// withstream controller
  /// Excluding add method, because readonly class should not be able to add events,
  /// and therefore add() method implemented in ObservableAsync only,
  /// and ObservableAsync implements StreamController

  @override
  void _addError(Object error, [StackTrace? stackTrace]) {
    _controller.addError(error, stackTrace);
  }

  @override
  Future _addStream(Stream<T> source, {bool? cancelOnError}) {
    final transformedStream = source.map((event) {
      _value = event;
      return event;
    });

    return _controller.addStream(transformedStream,
        cancelOnError: cancelOnError);
  }

  @override
  bool get hasListener => _controller.hasListener;

  @override
  bool get isClosed => _controller.isClosed;

  @override
  bool get isPaused => _controller.isPaused;

  @override
  Stream<T> get stream => _controller.stream;

  @override
  Future get done => _controller.done;

  @override
  FutureOr<void> Function()? onCancel;

  @override
  void Function()? get onPause => _controller.onPause;

  @override
  set onPause(void Function()? function) {
    _controller.onPause = function;
  }

  @override
  void Function()? get onResume => _controller.onResume;

  @override
  set onResume(void Function()? function) {
    _controller.onResume = function;
  }

  @override
  void Function()? get onListen => _controller.onListen;

  @override
  set onListen(void Function()? function) {
    _controller.onListen = function;
  }

  @override
  void dispose() async {
    if (!isClosed) {
      await _controller.close();
      //_customSink?.close();
    }
  }

  @override
  Future close() async {
    return dispose();
  }
}

class _CustomStreamSink<T> implements StreamSink<T> {
  final StreamSink<T> _inner;
  final void Function(T value) _onAdd;

  _CustomStreamSink(this._inner, this._onAdd);

  @override
  void add(T event) {
    _onAdd(event);
    _inner.add(event);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _inner.addError(error, stackTrace);
  }

  @override
  Future close() {
    return _inner.close();
  }

  @override
  Future addStream(Stream<T> stream) {
    return _inner.addStream(
      stream.map((event) {
        _onAdd(event);
        return event;
      }),
    );
  }

  @override
  Future get done => _inner.done;
}
