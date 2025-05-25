part of '../observable.dart';

/// ObservableGroup allows you to group multiple observables into one.
/// It listens to all provided observables and notifies its own listeners
/// whenever any of them changes.
class ObservableGroup extends IObservableListenable<void> {
  final List<IObservableListenable> _observables;

  final Set<void Function(void)> _listeners = {};

  final List<ObservableSubscription> _subscriptions = [];

  /// Constructor that sets up listeners for each observable in the group.
  ObservableGroup(this._observables) {
    _subscriptions.addAll(_observables.map((rx) {
      return rx.listen((_) => _notifyListeners());
    }));
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener(null);
    }
  }

  @override
  ObservableSubscription listen(void Function(void) listener) {
    _listeners.add(listener);
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
