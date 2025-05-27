part of '../observable.dart';

/// ObservableGroup allows you to group multiple observables into one.
/// It listens to all provided observables and notifies its own listeners
/// without value, whenever any of observables changes.
/// Difference from [ObservableComputed] is that this class doesn't store any value
/// and doesn't require any function adn since it based on [ChangeNotifier], it always sync
class ObservableGroup extends ChangeNotifier
    implements IObservableListenable<void> {
  final List<IObservableListenable> _observables;
  final List<ObservableSubscription> _subscriptions = [];

  /// Constructor that sets up listeners for each observable in the group.
  ObservableGroup(this._observables) {
    _subscriptions.addAll(
      _observables.map((rx) {
        return rx.listen((_) => notifyListeners());
      }),
    );
  }

  /// This works similar to AddListener, without value,
  /// but returns subscription just like [listen] method
  ObservableSubscription listener(void Function() listener) {
    assert(ChangeNotifier.debugAssertNotDisposed(this));
    addListener(listener);
    return ObservableSubscription<void>(() => removeListener(listener));
  }

  /// For ObservableGroup better to use [addListener] or [listener] method
  /// For better code readability, since this one use callback
  /// with void parameter (similar to .then in Future void)
  @override
  ObservableSubscription listen(void Function(void) listener) {
    assert(ChangeNotifier.debugAssertNotDisposed(this));
    listenerWrapper() => listener(null);
    addListener(listenerWrapper);
    return ObservableSubscription<void>(() => removeListener(listenerWrapper));
  }

  @override
  void dispose() {
    assert(ChangeNotifier.debugAssertNotDisposed(this));
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    super.dispose();
  }
}
