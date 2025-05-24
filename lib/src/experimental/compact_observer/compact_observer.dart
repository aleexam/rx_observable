import 'package:flutter/widgets.dart';

import '../../core/observable.dart';
import '../experimental.dart';

/// A widget that automatically tracks and subscribes to observable values used within its builder.
///
/// This experimental widget simplifies reactive UI by automatically detecting which
/// [IObservable] instances are accessed within the builder function and subscribing
/// to them. When any of these observables change, the widget will rebuild.
///
/// Example:
/// ```dart
/// // Without Observe:
/// Observer(counter, (value) => Text('$value'))
///
/// // With Observe:
/// Observe(() => Text('${counter.value}'))
/// ```
///
/// WARNING: There are important limitations to be aware of:
/// 1. Do not modify observable values inside the builder (causes infinite loops)
/// 2. Nested contexts (like inside Builder widgets) will not bed tracked
/// 3. Performance may be worse than using standard Observer widgets
@Deprecated("Experimental feature, not recommended for production use")
class Observe extends StatefulWidget {
  /// A builder function that constructs a widget using observable values
  final Widget Function() builder;

  Observe(this.builder, {super.key})
      : assert(ExperimentalObservableFeatures.useExperimental == true,
            'This experimental feature available only when useExperimental set true');

  @override
  State<Observe> createState() => _ObserveState();
}

// ignore: deprecated_member_use_from_same_package
class _ObserveState extends State<Observe> {
  // ignore: deprecated_member_use_from_same_package
  final ObsTrackingContext _ctx = ObsTrackingContext();
  final List<ObservableSubscription> _subs = [];
  late Widget _cachedWidget;
  bool _disposed = false;

  void _buildAndTrack() {
    if (_disposed) return;
    
    // Clear existing subscriptions
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();

    try {
      // ignore: invalid_use_of_visible_for_testing_member
      _cachedWidget = _ctx.track(() => widget.builder(), (trackedVars) {
        if (_disposed) return;
        
        for (final observable in trackedVars) {
          final sub = observable.listen((_) {
            if (!_disposed && mounted) {
              setState(_buildAndTrack);
            }
          });
          _subs.add(sub);
        }
      });
    } catch (e, stack) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: Exception('Error in Observe widget builder: $e'),
        stack: stack,
        library: 'rx_observable',
        context: ErrorDescription('while building an Observe widget'),
      ));
      
      // Fall back to an error widget
      _cachedWidget = ErrorWidget.withDetails(
        message: 'Error in Observe widget: $e',
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _buildAndTrack();
  }

  @override
  // ignore: deprecated_member_use_from_same_package
  void didUpdateWidget(covariant Observe oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.builder != oldWidget.builder) {
      _buildAndTrack();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _cachedWidget;
}

extension CompactObserverExt on IObservable {

  /// Force [Observe] widget to register value for listening
  @Deprecated("Experimental feature, probably better not to use yet")
  void observe() {
    assert(ExperimentalObservableFeatures.useExperimental == true,
      "This experimental feature available only when useExperimental set true");
    value;
  }
}
