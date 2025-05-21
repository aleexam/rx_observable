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

  bool get notifyOnlyIfChanged => _notifyOnlyIfChanged;

  final _customListeners = <void Function(T)>[];

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
    _customListeners.add(listener);
    if (fireImmediately) listener(_value);
    return ObservableSubscription(() => _customListeners.remove(listener));
  }

  /// Notifies [listen] listeners and common [ChangeNotifier] listeners
  /// listen listeners will get callback with value,
  /// while ChangeNotifier listeners gets VoidCallback
  /// Call all the registered listeners.
  ///
  /// Call this method whenever the object changes, to notify any clients the
  /// object may have changed. Listeners that are added during this iteration
  /// will not be visited. Listeners that are removed during this iteration will
  /// not be visited after they are removed.
  ///
  /// Exceptions thrown by listeners will be caught and reported using
  /// [FlutterError.reportError].
  ///
  /// This method must not be called after [dispose] has been called.
  ///
  /// Surprising behavior can result when reentrantly removing a listener (e.g.
  /// in response to a notification) that has been registered multiple times.
  /// See the discussion at [removeListener].
  @override
  void notifyListeners() {
    for (final listener in _customListeners) {
      try {
        listener(_value);
      } catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'rx_observable',
          context: ErrorDescription(
              'while dispatching rx_observable notifications for $runtimeType'),
          informationCollector: () => <DiagnosticsNode>[
            DiagnosticsProperty<ChangeNotifier>(
              'The $runtimeType sending rx_observable notification was',
              this,
              style: DiagnosticsTreeStyle.errorProperty,
            ),
          ],
        ));
      }
    }
    super.notifyListeners();
  }

  @override
  void notify() {
    notifyListeners();
  }

  @override
  ObservableReadOnly<R> map<R>(R Function(T value) transform) {
    final result = Observable<R>(transform(value), notifyOnlyIfChanged: _notifyOnlyIfChanged);

    final subscription = listen((val) {
      result.value = transform(val);
    });

    _mapSubs.add(DisposableAdapter(() {
      subscription.cancel();
      result.dispose();
    }));
    return result;
  }

  @override
  void dispose() {
    _customListeners.clear();
    for (var cancelable in _mapSubs) {
      cancelable.cancel();
    }
    super.dispose();
  }
}
