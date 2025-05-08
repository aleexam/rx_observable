part of 'observable.dart';

class ObservableGroup extends IObservableListenable<void> {
  final List<IObservableListenable> _observables;

  final Set<void Function(void)> _listeners = {};

  final List<ObservableSubscription> _subscriptions = [];

  ObservableGroup(this._observables) {
    _subscriptions.addAll(_observables.map((rx) {
      return rx.listen(
            (_) => _notifyListeners(),
        fireImmediately: false,
      );
    }));
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener(null);
    }
  }

  @override
  ObservableSubscription listen(void Function(void) listener, {bool fireImmediately = true}) {
    _listeners.add(listener);
    if (fireImmediately) {
      listener(null);
    }

    return ObservableSubscription(() {
      _listeners.remove(listener);
    });
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _listeners.clear();
  }
}