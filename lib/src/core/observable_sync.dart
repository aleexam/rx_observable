part of 'observable.dart';

/// This default observable class is sync, based on [ChangeNotifier].
/// See [ObservableAsync] for same functionality based on StreamController,
/// You can use it like ChangeNotifier anywhere (addListener, notifyListeners, etc)
/// Or use convenient stream-like listen method
class Observable<T> extends ObservableReadOnly<T> implements IObservableMutable<T> {
  /// Constructs a [Observable], with value setter and getter, pass initial value, handlers for
  /// flag [notifyOnlyIfChanged] - if true, listeners will be notified
  /// if new value not equals to old value
  Observable(
    super.initialValue, {
    super.notifyOnlyIfChanged,
  });

  @override
  set value(T newValue) => _updateValue(newValue);

  @override
  set v(T v) => value = v;
}

/// This default observable class is sync, based on ChangeNotifier.
/// See [ObservableAsyncReadOnly] for same functionality based on StreamController,
/// This one is read only variant, you can't set it's value
class ObservableReadOnly<T> extends ChangeNotifier implements IObservableSync<T> {
  /// Constructs a [ObservableReadOnly], pass initial value,
  /// flag [notifyOnlyIfChanged] - if true, listeners will be notified
  /// if new value not equals to old value
  ObservableReadOnly(T initialValue, {bool notifyOnlyIfChanged = true}) {
    _value = initialValue;
    _notifyOnlyIfChanged = notifyOnlyIfChanged;
  }

  late T _value;
  late bool _notifyOnlyIfChanged;

  /// if true, listeners will be notified, if new value not equals to old value
  /// Otherwise, any updated will trigger listeners
  bool get notifyOnlyIfChanged => _notifyOnlyIfChanged;

  /// Set and emit the new value.
  void _updateValue(T newValue) {
    /// Experimental start
    if (ExperimentalObservableFeatures.useExperimental && ObsTrackingContext.current != null) {
      throw Exception('You cannot modify reactive value inside Observer builder');
    }
    /// Experimental end

    if (_value != newValue || !_notifyOnlyIfChanged) {
      _value = newValue;
      notifyListeners();
    }
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
  ObservableSubscription<T> listen(void Function(T) listener, {bool fireImmediately = false}) {
    assert(ChangeNotifier.debugAssertNotDisposed(this));
    listenerWrapper() => listener(_value);
    addListener(listenerWrapper);
    if (fireImmediately) listener(_value);
    return ObservableSubscription(() => removeListener(listenerWrapper));
  }

  @override
  void notify() {
    notifyListeners();
  }

  @override
  ObservableReadOnly<R> map<R>(R Function(T value) transform) {
    final mappedObservable = Observable<R>(transform(value), notifyOnlyIfChanged: _notifyOnlyIfChanged);

    final subscription = listen((val) {
      mappedObservable.value = transform(val);
    });


    var disposer = DisposableAdapter(() {
      mappedObservable._onDispose = null;
      subscription.cancel();
      mappedObservable.dispose();
    });

    mappedObservable._onDispose = () {
      subscription.cancel();
      _mapSubs.remove(disposer);
    };

    _mapSubs.add(disposer);
    return mappedObservable;
  }

  @override
  void dispose() {
    assert(ChangeNotifier.debugAssertNotDisposed(this));
    for (var cancelable in _mapSubs) {
      cancelable.cancel();
    }
    _onDispose?.call();
    super.dispose();
  }

  void Function()? _onDispose;
}
