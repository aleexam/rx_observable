part of 'observable.dart';

/// This observable class is async, based on [StreamController].
/// See [Observable] for same functionality based on ChangeNotifier,
/// You can use it like usual broadcast StreamController anywhere
/// Must always call dispose when use [ObservableAsync]
class ObservableAsync<T> extends ObservableAsyncReadOnly<T>
    implements IObservableMutable<T>, StreamController<T>  {
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
    if (ExperimentalObservableFeatures.useExperimental && ObsTrackingContext.current != null) {
      throw Exception('You cannot modify reactive value inside Observer builder');
    }

    /// Experimental end

    _value = event;
    _add(event);
  }
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
    _controller =
        StreamController<T>.broadcast(sync: sync, onListen: onListen, onCancel: onCancel);
    _notifyOnlyIfChanged = notifyOnlyIfChanged;
  }

  @override
  T get value {
    if (ExperimentalObservableFeatures.useExperimental) ObsTrackingContext.current?._register(this); /// Experimental
    return _value;
  }

  @override
  T get v => value;

  final Set<ICancelable> _mapSubs = {};

  @override
  ObservableStreamSubscription<T> listen(FutureOr<void> Function(T) onData,
      {bool fireImmediately = false}) {
    var subscription = _controller.stream.listen(onData);
    if (fireImmediately) {
      onData(_value);
    }
    return ObservableStreamSubscription(subscription);
  }

  void _updateValue(T newValue) {
    if (isClosed) throw StateError("Cannot update value after calling dispose");

    /// Experimental start
    if (ExperimentalObservableFeatures.useExperimental && ObsTrackingContext.current != null) {
      throw Exception('You cannot modify reactive value inside Observer builder');
    }
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
  ObservableAsyncReadOnly<R> map<R>(R Function(T value) transform) {
    final result = ObservableAsync<R>(transform(value), notifyOnlyIfChanged: _notifyOnlyIfChanged);

    final subscription = listen((val) {
      result.value = transform(val);
    });

    _mapSubs.add(DisposableAdapter(() {
      subscription.cancel();
      result.dispose();
    }));
    return result;
  }

  void _add(T event) {
    _controller.add(event);
  }

  void addError(Object error, [StackTrace? stackTrace]) {
    _controller.addError(error, stackTrace);
  }

  Future addStream(Stream<T> source, {bool? cancelOnError}) {
    return _controller.addStream(stream, cancelOnError: cancelOnError);
  }

  bool get hasListener => _controller.hasListener;

  bool get isClosed => _controller.isClosed;

  bool get isPaused => _controller.isPaused;

  StreamSink<T> get sink => _controller.sink;

  Stream<T> get stream => _controller.stream;

  Future get done => _controller.done;

  FutureOr<void> Function()? onCancel;

  void Function()? get onPause => _controller.onPause;

  set onPause(void Function()? function) {
    _controller.onPause = function;
  }

  void Function()? get onResume => _controller.onResume;

  set onResume(void Function()? function) {
    _controller.onResume = function;
  }

  void Function()? get onListen => _controller.onListen;

  set onListen(void Function()? function) {
    _controller.onListen = function;
  }


  @override
  void dispose() {
    for (var cancelable in _mapSubs) {
      cancelable.cancel();
    }
    close();
  }

  Future close() {
    return _controller.close();
  }
}
