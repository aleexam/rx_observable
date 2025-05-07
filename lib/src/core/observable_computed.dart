part of 'observable.dart';

class ObservableComputed<T> extends ObservableReadOnly<T> {
  final T Function() _compute;
  final List<ObservableSubscription> _subscriptions = [];

  ObservableComputed(
    this._compute,
    List<IObservable> observables,
  ) : super(_compute()) {
    for (final observable in observables) {
      final sub = observable.listen((_) {
        super._value = _compute();
        notifyListeners();
      }, fireImmediately: false);
      _subscriptions.add(sub);
    }
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }
}
