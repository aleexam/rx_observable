part of '../observable.dart';

/// ObservableComputed represents a computed read-only observable value.
/// It automatically recalculates its value whenever its dependencies change.
/// This one based on [ChangeNotifier], should be always disposed properly
class ObservableComputed<T> extends ObservableReadOnly<T> {
  late final T Function() _compute;
  final List<ObservableSubscription> _subscriptions = [];

  /// Constructor takes a compute function and a list of dependent observables.
  /// Recomputes the value and notifies listeners when any dependency changes.
  ObservableComputed(
    List<IObservable> observables, {
    required final T Function() computer,
    super.notifyOnlyIfChanged,
  }) : super(computer()) {
    _compute = computer;
    for (final observable in observables) {
      final sub = observable.listen((_) {
        try {
          _updateValue(_compute());
        } catch (e, s) {
          reportObservableFlutterError(e, s, this);
        }
      });
      _subscriptions.add(sub);
    }
  }

  /// Cancels all subscriptions and disposes of this computed observable.
  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    super.dispose();
  }
}

/// ObservableComputed represents a computed read-only observable value.
/// It automatically recalculates its value whenever its dependencies change.
/// This one based on [StreamController], should be always disposed properly
class ObservableComputedAsync<T> extends ObservableAsyncReadOnly<T> {
  late final T Function() _compute;
  final List<ObservableSubscription> _subscriptions = [];

  /// Constructor takes a compute function and a list of dependent observables.
  /// Recomputes the value and notifies listeners when any dependency changes.
  ObservableComputedAsync(
    List<IObservable> observables, {
    required final T Function() computer,
    super.onListen,
    super.onCancel,
    super.notifyOnlyIfChanged,
  }) : super(computer()) {
    _compute = computer;
    for (final observable in observables) {
      final sub = observable.listen((_) {
        try {
          _updateValue(_compute());
        } catch (e, s) {
          super._addError(e, s);
        }
      });
      _subscriptions.add(sub);
    }
  }

  /// Cancels all subscriptions and disposes of this computed observable.
  @override
  Future<void> dispose() async {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    super.dispose();
  }
}
