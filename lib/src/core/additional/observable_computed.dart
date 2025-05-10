part of '../observable.dart';

/// ObservableComputed represents a computed read-only observable value.
/// It automatically recalculates its value whenever its dependencies change.
class ObservableComputed<T> extends ObservableReadOnly<T> {
  final T Function() _compute;
  final List<ObservableSubscription> _subscriptions = [];

  /// Constructor takes a compute function and a list of dependent observables.
  /// Recomputes the value and notifies listeners when any dependency changes.
  ObservableComputed(
    this._compute,
    List<IObservable> observables,
  ) : super(_compute()) {
    for (final observable in observables) {
      final sub = observable.listen((_) {
        super._value = _compute();
        notifyListeners();
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
    super.dispose();
  }
}
