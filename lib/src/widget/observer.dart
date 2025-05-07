import 'package:flutter/material.dart';

import '../core/observable.dart';

class Observer<T> extends StatefulWidget {
  final IObservable<T> observable;
  final Widget Function(BuildContext, T) builder;

  factory Observer(
    IObservable<T> observable,
    Widget Function(T v) builder, {
    Key? key,
  }) {
    return Observer.context(observable, (ctx, val) {
      return builder(val);
    }, key: key);
  }

  factory Observer.builder({
    Key? key,
    required IObservable<T> observable,
    required Widget Function(BuildContext ctx, T val) builder,
  }) {
    return Observer.context(observable, builder, key: key);
  }

  const Observer.context(this.observable, this.builder, {super.key});

  @override
  State<Observer<T>> createState() => _ObserverState<T>();
}

class _ObserverState<T> extends State<Observer<T>> {
  late ObservableSubscription _sub;

  @override
  void initState() {
    super.initState();
    _sub = widget.observable.listen((_) => setState(() {}));
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) => widget.builder(ctx, widget.observable.value);
}

class Observer2<A, B> extends StatefulWidget {
  final IObservable<A> observable;
  final IObservable<B> observable2;
  final Widget Function(BuildContext context, A a, B b) builder;

  const Observer2({
    super.key,
    required this.observable,
    required this.observable2,
    required this.builder,
  });

  @override
  State<Observer2<A, B>> createState() => _Observer2State<A, B>();
}

class _Observer2State<A, B> extends State<Observer2<A, B>> {
  late ObservableSubscription _subA;
  late ObservableSubscription _subB;

  @override
  void initState() {
    super.initState();
    _subA = widget.observable.listen((_) => setState(() {}));
    _subB = widget.observable2.listen((_) => setState(() {}));
  }

  @override
  void dispose() {
    _subA.cancel();
    _subB.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) =>
      widget.builder(ctx, widget.observable.value, widget.observable2.value);
}

class Observer3<A, B, C> extends StatefulWidget {
  final IObservable<A> observable;
  final IObservable<B> observable2;
  final IObservable<C> observable3;
  final Widget Function(BuildContext context, A a, B b, C c) builder;

  const Observer3({
    super.key,
    required this.observable,
    required this.observable2,
    required this.observable3,
    required this.builder,
  });

  @override
  State<Observer3<A, B, C>> createState() => _Observer3State<A, B, C>();
}

class _Observer3State<A, B, C> extends State<Observer3<A, B, C>> {
  late ObservableSubscription _subA;
  late ObservableSubscription _subB;
  late ObservableSubscription _subC;

  @override
  void initState() {
    super.initState();
    _subA = widget.observable.listen((_) => setState(() {}));
    _subB = widget.observable2.listen((_) => setState(() {}));
    _subC = widget.observable3.listen((_) => setState(() {}));
  }

  @override
  void dispose() {
    _subA.cancel();
    _subB.cancel();
    _subC.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) => widget.builder(
      ctx, widget.observable.value, widget.observable2.value, widget.observable3.value);
}
