part of '../../core/observable.dart';

/// This needs for experimental [Observe] widget
@Deprecated("Experimental feature, probably better not to use yet")
class ObsTrackingContext {
  static final List<ObsTrackingContext> _stack = [];

  static ObsTrackingContext? get current => _stack.isEmpty ? null : _stack.last;

  final Set<IObservable> _trackedVars = {};
  bool _isTracking = false;

  ObsTrackingContext()
      : assert(ExperimentalObservableFeatures.useExperimental == true,
            'This experimental feature available only when useExperimental set true');

  void _register(IObservable observable) {
    if (_isTracking) _trackedVars.add(observable);
  }

  /// Do not ever call this method, it can break [Observe] widget logic
  T track<T>(T Function() fn, void Function(Set<IObservable>) onTrackedVars) {
    if (_isTracking) {
      throw Exception('Nested ObsTrackingContext not allowed');
    }
    _isTracking = true;
    _stack.add(this);
    _trackedVars.clear();
    try {
      final result = fn();
      onTrackedVars(Set.of(_trackedVars));
      return result;
    } finally {
      _stack.removeLast();
      _isTracking = false;
    }
  }
}
