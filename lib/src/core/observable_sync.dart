part of 'observable.dart';

/// This default observable class is sync, based on [ChangeNotifier].
/// See [ObservableAsync] for same functionality based on StreamController,
/// You can use it like ChangeNotifier anywhere (addListener, notifyListeners, etc)
/// Or use convenient stream-like listen method
class Observable<T> extends ObservableReadOnly<T>
    implements IObservableMutable<T>, ValueNotifier<T> {
  /// Constructs a [Observable], with value setter and getter, pass initial value, handlers for
  /// flag [notifyOnlyIfChanged] - if true, listeners will be notified
  /// if new value not equals to old value
  Observable(super.initialValue, {super.notifyOnlyIfChanged});

  @override
  set value(T newValue) => _updateValue(newValue);

  @override
  set v(T v) => value = v;
}

/// This default observable class is sync, based on ChangeNotifier.
/// See [ObservableAsyncReadOnly] for same functionality based on StreamController,
/// This one is read only variant, you can't set it's value
class ObservableReadOnly<T> extends ChangeNotifier
    implements IObservableSync<T> {
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
    ObsTrackingContext._handleModificationDuringTracking(this);

    if (_value != newValue || !_notifyOnlyIfChanged) {
      _value = newValue;
      notifyListeners();
    }
  }

  @override
  T get value {
    ObsTrackingContext.current?._register(this);
    return _value;
  }

  @override
  T get v => value;

  @override
  ObservableSubscription<T> listen(
    void Function(T) listener, {
    bool fireImmediately = false,
  }) {
    assert(ChangeNotifier.debugAssertNotDisposed(this));
    listenerWrapper() => listener(_value);
    addListener(listenerWrapper);
    if (fireImmediately) listenerWrapper();
    return ObservableSubscription<T>(() => removeListener(listenerWrapper));
  }

  @override
  void notify() {
    notifyListeners();
  }

  @override
  ObservableReadOnly<R> map<R>(
    R Function(T value) transform, {
    bool? notifyOnlyIfChanged,
  }) {
    assert(ChangeNotifier.debugAssertNotDisposed(this));
    return MappedObservableReadOnly<T, R>(
      this,
      transform,
      notifyOnlyIfChanged: notifyOnlyIfChanged ?? _notifyOnlyIfChanged,
    );
  }

  @override
  void dispose() {
    assert(ChangeNotifier.debugAssertNotDisposed(this));
    super.dispose();
  }
}
