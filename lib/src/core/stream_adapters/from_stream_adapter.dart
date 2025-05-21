import 'dart:async';

import '../../../rx_observable.dart';

/// Adapter that wraps a Stream<T> and exposes IObservableListenable<T>
class StreamToObservableAdapter<T> implements IObservableListenable<T> {
  final Stream<T> _stream;
  StreamSubscription<T>? _subscription;

  StreamToObservableAdapter(this._stream);

  @override
  ObservableSubscription<T> listen(void Function(T) listener, {
    bool fireImmediately = false
  }) {
    _subscription = _stream.listen(listener);
    return ObservableSubscription(() {
      dispose();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
  }
}
