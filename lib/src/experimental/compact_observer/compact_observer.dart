import 'package:flutter/widgets.dart';

import '../../core/observable.dart';


/// This observer variant gives you ability to wrap any widget,
/// and all [IObservable] will be listened automatically in this widget
@Deprecated("Experimental feature, probably better not to use yet")
class Observe extends StatefulWidget {
  final Widget Function() builder;
  final List<IObservableListenable> predefinedObservables;

  Observe(this.builder, {super.key, this.predefinedObservables = const []})
      : assert(Observable.useExperimental == true, 'This experimental feature available only when useExperimental set true');

  @override
  State<Observe> createState() => _ObserveState();
}

class _ObserveState extends State<Observe> {
  final ObsTrackingContext _ctx = ObsTrackingContext();
  final List<ObservableSubscription> _subs = [];
  late Widget _cachedWidget;

  void _buildAndTrack() {
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();

    _cachedWidget = _ctx.track(() => widget.builder(), (trackedVars) {
      for (final observable in trackedVars) {
        final sub = observable.listen((_) => setState(_buildAndTrack), fireImmediately: false);
        _subs.add(sub);
      }
    });
  }

  @override
  void initState() {
    for (final observable in widget.predefinedObservables) {
      final sub = observable.listen((_) => setState(_buildAndTrack));
      _subs.add(sub);
    }
    super.initState();
    _buildAndTrack();
  }

  @override
  void didUpdateWidget(covariant Observe oldWidget) {
    super.didUpdateWidget(oldWidget);
    _buildAndTrack();
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _cachedWidget;
}
