import 'dart:async';

import 'package:flutter/material.dart';

import '../core/observable.dart';

/// A stateless widget that listens to an [observable]
/// and triggers the provided [listener] callback whenever the value changes.
///
/// Unlike [ObservableConsumer], this widget does **not rebuild** itself.
/// It is meant for side effects only (e.g., showing dialogs, triggering actions).
///
/// Usage:
/// ObservableListener<int>(
///   observable: counter,
///   listener: (context, value) {
///     if (value > 10) {
///       ScaffoldMessenger.of(context).showSnackBar(...);
///     }
///   },
///   child: MyWidget(),
/// );
class ObservableListener<T> extends StatelessWidget {

  /// Creates an [ObservableListener] that listens to [observable]
  /// and calls [listener] when its value changes.
  const ObservableListener({
    super.key,
    required this.observable,
    required this.listener,
    required this.child,
  });

  /// The child widget to render. It does **not rebuild** on value change.
  final Widget? child;

  /// The observable to listen to.
  final IObservableListenable<T> observable;

  /// The callback that is triggered when the observable emits a new value.
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
