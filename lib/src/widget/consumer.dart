import 'package:flutter/material.dart';
import 'package:rx_observable/src/core/observable.dart';

class ObservableConsumer<T> extends StatefulWidget {
  final IObservable<T> observable;
  final void Function(BuildContext context, T value)? listener;
  final Widget Function(BuildContext context, T value) builder;

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

  @override
  void initState() {
    super.initState();
    _sub = widget.observable.listen((value) {
      if (mounted) {
        widget.listener?.call(context, value);
        setState(() {});
      }
    }, fireImmediately: false);
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, widget.observable.value);
}
