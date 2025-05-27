import 'package:flutter/foundation.dart';
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
/// IMPORTANT! Be sure that no nested [Observe] is watching for same value,
/// this can lead to lot of wasted builds
/// WARNING: There are important limitations to be aware of:
/// 1. Do not modify observable values inside the builder (causes infinite loops)
/// 2. Nested contexts (like inside Builder widgets) will not be tracked
/// 3. Asynchronous operations inside the builder won't be tracked properly\
/// 4. Performance is also questionable (especially nested [Observe], especially with same values
@Deprecated("Experimental feature, not recommended for production use")
class Observe extends StatefulWidget {
  /// A builder function that constructs a widget using observable values
  final Widget Function() builder;

  Observe(this.builder, {super.key})
    : assert(
        ExperimentalObservableFeatures.useExperimental,
        'This experimental feature is only available when ExperimentalObservableFeatures.useExperimental is set to true',
      );

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
  bool _isRebuilding = false;

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

  void _buildAndTrack() {
    if (_disposed || !mounted) return;

    // Prevent multiple rebuilds happening simultaneously
    if (_isRebuilding) return;
    _isRebuilding = true;

    // Clear existing subscriptions
    _clearSubscriptions();

    try {
      // Track observables accessed during build
      // ignore: invalid_use_of_visible_for_testing_member
      _cachedWidget = _ctx.track(() => widget.builder(), (trackedVars) {
        if (_disposed) return;

        // Subscribe to all tracked observables
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
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: Exception('Error in Observe widget builder'),
          stack: stack,
          library: 'rx_observable',
          context: ErrorDescription('while building an Observe widget'),
          informationCollector:
              () => <DiagnosticsNode>[
                DiagnosticsProperty<String>(
                  'Exception details',
                  e.toString(),
                  style: DiagnosticsTreeStyle.errorProperty,
                ),
              ],
        ),
      );

      // Fall back to an error widget
      _cachedWidget = ErrorWidget.withDetails(
        message: 'Error in Observe widget: $e',
      );
    } finally {
      _isRebuilding = false;
    }
  }

  void _clearSubscriptions() {
    for (final sub in _subs) {
      sub.cancel();
    }
    _subs.clear();
  }

  @override
  void dispose() {
    _disposed = true;
    _clearSubscriptions();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _cachedWidget;
}
