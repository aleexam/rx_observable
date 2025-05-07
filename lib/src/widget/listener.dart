import 'dart:async';

import 'package:flutter/material.dart';

import '../core/observable.dart';

/// Widget that listen to an [observable] or [Stream] and call [listener] function.
class ObservableListener<T> extends StatelessWidget {
  const ObservableListener({
    super.key,
    required this.observable,
    required this.listener,
    required this.child,
  });

  final Widget? child;
  final IObservableListenable<T> observable;
  final void Function(BuildContext context, T value) listener;

  @override
  Widget build(BuildContext context) {
    return _ObservableListener(
      observable: observable,
      listener: listener,
      child: child ?? const SizedBox(),
    );
  }
}

class _ObservableListener<T> extends StatefulWidget {
  final IObservableListenable<T> observable;
  final void Function(BuildContext context, T value) listener;
  final Widget child;

  const _ObservableListener({
    super.key,
    required this.observable,
    required this.listener,
    required this.child,
  });

  @override
  State<_ObservableListener<T>> createState() => _ObservableListenerState<T>();
}

class _ObservableListenerState<T> extends State<_ObservableListener<T>> {
  late ObservableSubscription _sub;

  @override
  void initState() {
    super.initState();
    _sub = widget.observable.listen((value) {
      widget.listener(context, value);
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
