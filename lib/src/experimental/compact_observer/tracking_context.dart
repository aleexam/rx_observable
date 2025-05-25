// ignore_for_file: deprecated_member_use_from_same_package

part of '../../core/observable.dart';

/// Internal tracking context for the experimental [Observe] widget.
/// Tracks which observables are accessed during a function call.
/// Experimental feature, not recommended for production use"
class ObsTrackingContext {
  // Actually, test shows that we don't need a stack, we can just use a single context field
  // But I keep it for now, just in case there are some ways for parallel builds
  static final List<ObsTrackingContext> _stack = [];

  /// Returns the current tracking context if one exists
  static ObsTrackingContext? get current => _stack.isEmpty ? null : _stack.last;

  final Set<IObservable> _trackedVars = {};
  bool _isTracking = false;

  ObsTrackingContext()
      : assert(ExperimentalObservableFeatures.useExperimental,
            'This experimental feature is only available when ExperimentalObservableFeatures.useExperimental is set to true');

  void _register(IObservable observable) {
    if (!ExperimentalObservableFeatures.useExperimental || !_isTracking) return;
    _trackedVars.add(observable);
  }

  static void _handleModificationDuringTracking(IObservable observable) {
    if (ExperimentalObservableFeatures.useExperimental &&
        ObsTrackingContext.current != null) {
      throw Exception(
          'You cannot modify reactive value inside Observe builder');
    }
  }

  /// Tracks which observables are accessed during the execution of [trackingFunction].
  ///
  /// IMPORTANT: This method is for internal use only. Do not call it directly
  /// as it may break the [Observe] widget's tracking logic.
  @visibleForTesting
  T track<T>(T Function() trackingFunction,
      void Function(Set<IObservable>) onTrackedVars) {
    _isTracking = true;
    _stack.add(this);
    _trackedVars.clear();

    try {
      final result = trackingFunction();
      onTrackedVars(Set<IObservable>.unmodifiable(_trackedVars));
      return result;
    } finally {
      if (_stack.isNotEmpty && _stack.last == this) {
        _stack.removeLast();
      }
      _isTracking = false;
    }
  }
}

extension CompactObserverExt on IObservable {
  /// Force [Observe] widget to register value for listening,
  /// So Observer will rebuild when value changes
  /// Use like this:
  /// Observe(() {
  ///      someObservableVar.observe();
  ///      return Builder(
  ///              builder: (context) {
  ///                   return Text(someObservableVar.value);
  ///              },
  ///       );
  /// });
  @Deprecated("Experimental feature, probably better not to use yet")
  void observe() {
    assert(ExperimentalObservableFeatures.useExperimental == true,
        "This experimental feature available only when useExperimental set true");
    ObsTrackingContext.current?._register(this);
  }
}
