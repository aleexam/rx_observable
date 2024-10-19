import 'package:flutter/material.dart';
import 'package:rx_observable/src/core/observable.dart';

/// Widget that listen to an [observable], build [builder] when its changed
/// and provides [observable] value to builder.
class Observer<T> extends StatelessWidget {
  const Observer.context(this.observable, this.builder, {super.key});

  factory Observer(
    IObservable<T> observable,
    Widget? Function(T v) builder, {
    Key? key,
  }) {
    return Observer.context(observable, (context, v) {
      return builder(v);
    }, key: key);
  }

  factory Observer.builder({
    Key? key,
    required IObservable<T> observable,
    required Widget? Function(BuildContext context, T v) builder,
  }) {
    return Observer.context(observable, builder, key: key);
  }

  final IObservable<T> observable;
  final Widget? Function(BuildContext context, T v) builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
        stream: observable.stream,
        builder: (context, _) {
          return builder(context, observable.value) ?? const SizedBox.shrink();
        });
  }
}

/// Same as [Observer] for 2 observables
class Observer2<T, T2> extends StatelessWidget {
  const Observer2.context(
    this.observable,
    this.observable2,
    this.builder, {
    super.key,
  });

  factory Observer2(IObservable<T> observable, IObservable<T2> observable2,
      Widget? Function(T v1, T2 v2) builder,
      {Key? key}) {
    return Observer2.context(observable, observable2, (context, v1, v2) {
      return builder(v1, v2);
    }, key: key);
  }

  factory Observer2.builder({
    Key? key,
    required IObservable<T> observable,
    required IObservable<T2> observable2,
    required Widget? Function(BuildContext context, T v1, T2 v2) builder,
  }) {
    return Observer2.context(observable, observable2, builder, key: key);
  }

  final IObservable<T> observable;
  final IObservable<T2> observable2;
  final Widget? Function(BuildContext, T v1, T2 v2) builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
        stream: observable.stream,
        builder: (context, _) {
          return StreamBuilder<T2>(
              stream: observable2.stream,
              builder: (context, _) {
                return builder(context, observable.value, observable2.value) ??
                    const SizedBox.shrink();
              });
        });
  }
}

/// Same as [Observer] for 3 observables
class Observer3<T, T2, T3> extends StatelessWidget {
  const Observer3.context(
    this.observable,
    this.observable2,
    this.observable3,
    this.builder, {
    super.key,
  });

  factory Observer3(
    IObservable<T> observable,
    IObservable<T2> observable2,
    IObservable<T3> observable3,
    Widget? Function(T v1, T2 v2, T3 v3) builder, {
    Key? key,
  }) {
    return Observer3.context(observable, observable2, observable3,
        (context, v1, v2, v3) {
      return builder(v1, v2, v3);
    }, key: key);
  }

  factory Observer3.builder({
    Key? key,
    required IObservable<T> observable,
    required IObservable<T2> observable2,
    required IObservable<T3> observable3,
    required Widget? Function(BuildContext context, T v1, T2 v2, T3 v3) builder,
  }) {
    return Observer3.context(observable, observable2, observable3, builder,
        key: key);
  }

  final IObservable<T> observable;
  final IObservable<T2> observable2;
  final IObservable<T3> observable3;
  final Widget? Function(BuildContext, T v1, T2 v2, T3 v3) builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
        stream: observable.stream,
        builder: (context, _) {
          return StreamBuilder<T2>(
              stream: observable2.stream,
              builder: (context, _) {
                return StreamBuilder<T3>(
                    stream: observable3.stream,
                    builder: (context, _) {
                      return builder(context, observable.value,
                              observable2.value, observable3.value) ??
                          const SizedBox.shrink();
                    });
              });
        });
  }
}
