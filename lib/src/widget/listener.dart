import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rx_observable/rx_observable.dart';
import '../core/obs_core_extensions.dart';

/// Widget that listen to an [observable] and call [listener] function.
class ObservableListener<T> extends StatelessWidget {
  const ObservableListener({
    super.key,
    required this.observable,
    required this.listener,
    required this.child
  });

  final Widget? child;
  final Stream<T> observable;
  final void Function(T value, BuildContext context) listener;

  @override
  Widget build(BuildContext context) {
    return _ObservableListener(
        observable: observable,
        listener: listener,
        child: child ?? const SizedBox()
    );
  }
}

class _ObservableListener<T> extends StatefulWidget {
  const _ObservableListener({
    super.key,
    required this.observable,
    required this.listener,
    required this.child
  });

  final Widget child;
  final Stream<T> observable;
  final void Function(T value, BuildContext context) listener;

  @override
  State<_ObservableListener<T>> createState() => _ObservableListenerState<T>();
}

class _ObservableListenerState<T> extends State<_ObservableListener<T>> {

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
    return widget.child;
  }

  @override
  void dispose() {
    rxSubs.cancelAll();
    super.dispose();
  }
}
