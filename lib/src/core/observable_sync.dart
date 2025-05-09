part of 'observable.dart';

/// This default observable class is sync, based on ChangeNotifier.
/// See [ObservableAsync] for same functionality based on StreamController,
class Observable<T> extends ObservableReadOnly<T>
    implements IObservableMutable<T> {
  /// Constructs a [Observable], with value setter and getter, pass initial value, handlers for
  /// flag [notifyOnlyIfChanged] - if true, listeners will be notified
  /// if new value not equals to old value
  Observable(
    super.initialValue, {
    super.notifyOnlyIfChanged,
  });

  /// Set and emit the new value.
  @override
  set value(T newValue) => _updateValue(newValue);
}

/// Class for observable value (notifier + current value).
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

  /// If true, listeners will be notified if new value not equals to old value
  /// Default true
  late bool _notifyOnlyIfChanged;

  bool get notifyOnlyIfChanged => _notifyOnlyIfChanged;

  final _customListeners = <void Function(T)>[];

  /// Set and emit the new value.
  void _updateValue(T newValue) {
    /// Experimental start
    if (ExperimentalObservableFeatures.useExperimental &&
        ObsTrackingContext.current != null) {
      throw Exception(
          'You cannot modify reactive value inside Observer builder');
    }

    /// Experimental end

    if (_value != newValue || !_notifyOnlyIfChanged) {
      _value = newValue;
      notifyListeners();
    }
  }

  @override
  T get value {
    if (ExperimentalObservableFeatures.useExperimental)
      ObsTrackingContext.current?._register(this);

    /// Experimental
    return _value;
  }

  @override
  ObservableSubscription listen(void Function(T) listener,
      {bool fireImmediately = false}) {
    _customListeners.add(listener);
    if (fireImmediately) listener(_value);
    return ObservableSubscription(() => _customListeners.remove(listener));
  }

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
    super
        .notifyListeners(); // this triggers Flutter widgets like Observer, etc.
  }

  @override
  void notify() {
    notifyListeners();
  }

  @override
  void dispose() {
    _customListeners.clear();
    super.dispose();
  }
}
