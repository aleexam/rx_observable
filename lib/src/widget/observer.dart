import 'package:flutter/material.dart';

import '../core/observable.dart';

/// A widget that rebuilds whenever the given [observable] emits a new value.
///
/// Similar to [ValueListenableBuilder], but built around custom [IObservable].
/// Useful for simple UI bindings with minimal boilerplate.
///
/// Example usage:
/// Observer(counter, (count) => Text('Count: $count'));
/// or:
/// Observer.builder(
///   observable: counter,
///   builder: (context, value) => Text('Count: $value'),
/// );
class Observer<T> extends StatefulWidget {
  /// The observable to listen to.
  final IObservable<T> observable;

  /// The builder function that builds the UI based on the observable value.
  final Widget Function(BuildContext, T) builder;

  /// Shorthand constructor for when you don't need [BuildContext] in your builder.
  factory Observer(
    IObservable<T> observable,
    Widget Function(T v) builder, {
    Key? key,
  }) {
    return Observer._context(observable, (ctx, val) {
      return builder(val);
    }, key: key);
  }

  /// Builder constructor with access to both [BuildContext] and value.
  factory Observer.builder({
    Key? key,
    required IObservable<T> observable,
    required Widget Function(BuildContext ctx, T val) builder,
  }) {
    return Observer._context(observable, builder, key: key);
  }

  const Observer._context(this.observable, this.builder, {super.key});

  @override
  State<Observer<T>> createState() => _ObserverState<T>();
}

class _ObserverState<T> extends State<Observer<T>> {
  late ObservableSubscription _sub;

  @override
  void initState() {
    super.initState();
    _sub = widget.observable.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) =>
      widget.builder(ctx, widget.observable.value);
}

/// A widget that listens to **two** [IObservable]s and rebuilds whenever
/// either one of them emits a new value.
///
/// Useful when your UI depends on the combined state of two observables.
///
/// Example:
/// Observer2(
///   observable: counter,
///   observable2: isLoggedIn,
///   builder: (context, count, loggedIn) {
///     return Text('$count | Logged in: $loggedIn');
///   },
/// );
class Observer2<A, B> extends StatefulWidget {
  /// First observable value.
  final IObservable<A> observable;

  /// Second observable value.
  final IObservable<B> observable2;

  /// Builder function that uses both observable values to build the widget.
  final Widget Function(BuildContext context, A o, B o2) builder;

  /// Creates an [Observer2] widget to observe two observables.
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

  void _setStateIfMounted() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _subA = widget.observable.listen((_) => _setStateIfMounted());
    _subB = widget.observable2.listen((_) => _setStateIfMounted());
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

/// A widget that listens to **three** [IObservable]s and rebuilds
/// whenever **any one** of them emits a new value.
///
/// Useful when a widget depends on multiple reactive values.
///
/// Example:
/// Observer3(
///   observable: firstName,
///   observable2: lastName,
///   observable3: age,
///   builder: (context, f, l, a) {
///     return Text('$f $l, Age: $a');
///   },
/// );
class Observer3<A, B, C> extends StatefulWidget {
  /// The first observable value.
  final IObservable<A> observable;

  /// The second observable value.
  final IObservable<B> observable2;

  /// The third observable value.
  final IObservable<C> observable3;

  /// Builds the widget using values from all three observables.
  final Widget Function(BuildContext context, A o, B o2, C o3) builder;

  /// Creates an [Observer3] to watch and react to three observables.
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

  void _setStateIfMounted() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _subA = widget.observable.listen((_) => _setStateIfMounted());
    _subB = widget.observable2.listen((_) => _setStateIfMounted());
    _subC = widget.observable3.listen((_) => _setStateIfMounted());
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
    ctx,
    widget.observable.value,
    widget.observable2.value,
    widget.observable3.value,
  );
}

class MultiObserver extends StatefulWidget {
  final List<IObservableListenable> observables;
  final WidgetBuilder builder;

  const MultiObserver({
    super.key,
    required this.observables,
    required this.builder,
  });

  @override
  State<MultiObserver> createState() => _MultiObserverState();
}

class _MultiObserverState extends State<MultiObserver> {
  late ObservableGroup _group;
  ObservableSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _group = ObservableGroup(widget.observables);
    _subscription = _group.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _group.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}
