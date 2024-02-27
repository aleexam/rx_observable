import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rx_observable/src/widget/listener.dart';
import 'package:rx_observable/src/widget/observer.dart';
import '../core/obs_core_extensions.dart';
import '../core/observable.dart';

/// Widget that acts like [Observer] and [ObservableListener] together
class ObservableConsumer<T> extends StatelessWidget {
  const ObservableConsumer({
    super.key,
    required this.observable,
    required this.listener,
    required this.child
  });

  final Widget? child;
  final Observable<T> observable;
  final void Function(T value, BuildContext context) listener;

  @override
  Widget build(BuildContext context) {
    return _ObservableConsumer(
        observable: observable,
        listener: listener,
        child: child ?? const SizedBox()
    );
  }
}

class _ObservableConsumer<T> extends StatefulWidget {
  const _ObservableConsumer({
    super.key,
    required this.observable,
    required this.listener,
    required this.child
  });

  final Widget child;
  final Observable<T> observable;
  final void Function(T value, BuildContext context) listener;

  @override
  State<_ObservableConsumer<T>> createState() => _ObservableConsumerState<T>();
}

class _ObservableConsumerState<T> extends State<_ObservableConsumer<T>> {

  final List<StreamSubscription> rxSubs = [];

  @override
  void initState() {
    rxSubs.add(widget.observable.listen((T value) {
      widget.listener(value, context);
    }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(() => widget.child);
  }

  @override
  void dispose() {
    rxSubs.cancelAll();
    super.dispose();
  }
}
