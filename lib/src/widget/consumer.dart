import 'package:flutter/material.dart';
import 'package:rx_observable/src/core/observable.dart';

/// A Flutter widget that listens to an [IObservable] and rebuilds
/// whenever the observable emits a new value.
///
/// Optionally, it can invoke a [listener] callback when updates occur,
/// allowing side effects without requiring a full rebuild.
/// To listen [Stream] use extension [ObservableStreamAdapters.asObservable]
/// to convert Stream to IObservable, or use [ObservableAsync]
class ObservableConsumer<T> extends StatefulWidget {
  /// The observable to listen to.
  final IObservable<T> observable;

  /// Optional callback triggered when the observable updates.
  final void Function(BuildContext context, T value)? listener;

  /// Builds the UI based on the current value of the observable.
  final Widget Function(BuildContext context, T value) builder;

  /// Creates an [ObservableConsumer] that rebuilds when [observable] changes.
  const ObservableConsumer({
    super.key,
    required this.observable,
    required this.builder,
    this.listener,
  });

  @override
  State<ObservableConsumer<T>> createState() => _ObservableConsumerState<T>();
}

class _ObservableConsumerState<T> extends State<ObservableConsumer<T>> {
  late ObservableSubscription _sub;

  void _subscribeAndUpdate() {
    _sub = widget.observable.listen((value) {
      if (mounted) {
        widget.listener?.call(context, value);
        if (mounted) {
          setState(() {});
        }
      }
    }, preFire: false);
  }

  @override
  void initState() {
    super.initState();
    _subscribeAndUpdate();
  }

  @override
  void didUpdateWidget(covariant ObservableConsumer<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.observable != widget.observable) {
      _sub.cancel();
      _subscribeAndUpdate();
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, widget.observable.value);
}
