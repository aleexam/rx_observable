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

  /// Creates an [Observer2] that listens to two observables [o1] and [o2],
  /// and rebuilds the widget whenever either value changes.
  static Observer2<A, B> two<A, B>({
    Key? key,
    required IObservable<A> o1,
    required IObservable<B> o2,
    required Widget Function(BuildContext, A, B) builder,
  }) {
    return Observer2(
        observable: o1, observable2: o2, builder: builder, key: key);
  }

  /// Creates an [Observer3] that listens to three observables [o1], [o2], and [o3],
  /// and rebuilds the widget whenever any of the values change.
  static Observer3<A, B, C> three<A, B, C>({
    Key? key,
    required IObservable<A> o1,
    required IObservable<B> o2,
    required IObservable<C> o3,
    required Widget Function(BuildContext, A, B, C) builder,
  }) {
    return Observer3(
        observable: o1,
        observable2: o2,
        observable3: o3,
        builder: builder,
        key: key);
  }

  /// Creates a [MultiObserver] that listens to a list of observables,
  /// and rebuilds the widget whenever any of them changes.
  static MultiObserver multi({
    Key? key,
    required List<IObservable> observables,
    required Widget Function(BuildContext) builder,
  }) {
    return MultiObserver(observables: observables, builder: builder, key: key);
  }

  /// Creates an [ObserverSelect] that listens to changes from an observable,
  /// and only rebuilds the widget when the selected value (from [selector]) changes.
  static ObserverSelect<T, R> select<T, R>({
    Key? key,
    required IObservable<T> observable,
    required R Function(T) selector,
    required Widget Function(BuildContext, R) builder,
  }) {
    return ObserverSelect(
      key: key,
      observable: observable,
      selector: selector,
      builder: builder,
    );
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
    _sub = _subscribeAndUpdate(widget.observable);
  }

  @override
  void didUpdateWidget(covariant Observer<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.observable != widget.observable) {
      _sub.cancel();
      _sub = _subscribeAndUpdate(widget.observable);
    }
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

/// A widget that listens to two [IObservable]s and rebuilds whenever
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

  @override
  void initState() {
    super.initState();
    _subA = _subscribeAndUpdate(widget.observable);
    _subB = _subscribeAndUpdate(widget.observable2);
  }

  @override
  void didUpdateWidget(covariant Observer2<A, B> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.observable != widget.observable) {
      _subA.cancel();
      _subA = _subscribeAndUpdate(widget.observable);
    }
    if (oldWidget.observable2 != widget.observable2) {
      _subB.cancel();
      _subB = _subscribeAndUpdate(widget.observable2);
    }
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

/// A widget that listens to three [IObservable]s and rebuilds
/// whenever any one of them emits a new value.
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

  @override
  void initState() {
    super.initState();
    _subA = _subscribeAndUpdate(widget.observable);
    _subB = _subscribeAndUpdate(widget.observable2);
    _subC = _subscribeAndUpdate(widget.observable3);
  }

  @override
  void didUpdateWidget(covariant Observer3<A, B, C> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.observable != widget.observable) {
      _subA.cancel();
      _subA = _subscribeAndUpdate(widget.observable);
    }
    if (oldWidget.observable2 != widget.observable2) {
      _subB.cancel();
      _subB = _subscribeAndUpdate(widget.observable2);
    }
    if (oldWidget.observable3 != widget.observable3) {
      _subC.cancel();
      _subC = _subscribeAndUpdate(widget.observable3);
    }
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
    _subscription = _subscribeAndUpdate(_group);
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

extension _SubscribeExt on State {
  ObservableSubscription<T> _subscribeAndUpdate<T>(
      IObservableListenable<T> observable) {
    return observable.listen((_) {
      if (mounted) {
        // ignore: invalid_use_of_protected_member
        setState(() {});
      }
    });
  }
}

class ObserverSelect<T, R> extends StatefulWidget {
  final IObservable<T> observable;
  final R Function(T) selector;
  final Widget Function(BuildContext context, R value) builder;

  const ObserverSelect({
    super.key,
    required this.observable,
    required this.selector,
    required this.builder,
  });

  @override
  State<ObserverSelect<T, R>> createState() => _ObserverSelectState<T, R>();
}

class _ObserverSelectState<T, R> extends State<ObserverSelect<T, R>> {
  late ObservableSubscription _sub;
  late R _lastValue;

  @override
  void initState() {
    super.initState();
    _lastValue = widget.selector(widget.observable.value);
    _sub = _subscribe();
  }

  @override
  void didUpdateWidget(covariant ObserverSelect<T, R> oldWidget) {
    super.didUpdateWidget(oldWidget);

    final shouldResubscribe = oldWidget.observable != widget.observable;
    final shouldReselect = oldWidget.selector != widget.selector;

    if (shouldResubscribe) {
      _sub.cancel();
      _sub = _subscribe();
    }

    if (shouldResubscribe || shouldReselect) {
      final newValue = widget.selector(widget.observable.value);
      if (newValue != _lastValue) {
        _lastValue = newValue;
        if (mounted) setState(() {});
      }
    }
  }

  ObservableSubscription _subscribe() {
    return widget.observable.listen((newVal) {
      final selected = widget.selector(newVal);
      if (selected != _lastValue) {
        _lastValue = selected;
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _lastValue);
  }
}
