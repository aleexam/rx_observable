import 'dart:async';

import '../../../rx_observable.dart';

/// Adapter that wraps a Stream<T> and exposes IObservableListenable<T>
class StreamToObservableAdapter<T> implements IObservableListenable<T> {
  final Stream<T> _stream;
  final List<StreamSubscription<T>> _subscriptions = [];

  StreamToObservableAdapter(this._stream);

  @override
  ObservableSubscription<T> listen(
    void Function(T) listener, {
    bool fireImmediately = false,
  }) {
    var subscription = _stream.listen(listener);
    _subscriptions.add(subscription);
    return ObservableSubscription(() {
      subscription.cancel();
      _subscriptions.remove(subscription);
    });
  }

  /// If all listeners properly cancel their subscriptions
  /// no need to call dispose in [StreamToObservableAdapter],
  @override
  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
  }
}
