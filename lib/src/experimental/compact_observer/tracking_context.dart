part of '../../core/observable.dart';

@Deprecated("Experimental feature, probably better not to use yet")
class ObsTrackingContext {
  static final List<ObsTrackingContext> _stack = [];

  static ObsTrackingContext? get current => _stack.isEmpty ? null : _stack.last;

  final Set<IObservable> _trackedVars = {};
  bool _isTracking = false;

  void _register(IObservable notifier) {
    if (_isTracking) _trackedVars.add(notifier);
  }

  T track<T>(T Function() fn, void Function(Set<IObservable>) onTrackedVars) {
    if (_isTracking) {
      throw Exception('Nested RxContext not allowed');
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
