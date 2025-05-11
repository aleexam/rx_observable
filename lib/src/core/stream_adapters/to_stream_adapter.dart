import 'dart:async';

import '../../../rx_observable.dart';

/// Adapter that wraps a IObservable<T> and exposes Stream<T>
class ObservableStreamAdapter<T> extends Stream<T> {
  final IObservableListenable<T> _observable;

  ObservableStreamAdapter(this._observable);

  @override
  StreamSubscription<T> listen(
    void Function(T)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _ObservableStreamSubscription<T>(
      _observable,
      onData,
      onDone,
      onError,
      cancelOnError
    );
  }
}

/// Custom StreamSubscription that delegates cancellation to the observable.
class _ObservableStreamSubscription<T> extends StreamSubscription<T> {
  final IObservableListenable<T> _observable;

  void Function(T)? _onData;
  void Function()? _onDone;

  late final ObservableSubscription _observableSub;

  bool _isCanceled = false;
  bool _isPaused = false;
  final _pendingValues = <T>[];

  _ObservableStreamSubscription(
      this._observable,
      void Function(T)? onData,
      void Function()? onDone,
      Function? onError,
      bool? cancelOnError,
  ) {
    _onData = onData;
    _onDone = onDone;

    _observableSub = _observable.listen((val) {
      if (_isPaused) {
        _pendingValues.add(val);
      } else {
        _onData?.call(val);
      }
    });
  }

  @override
  void onData(void Function(T data)? handleData) {
    _onData = handleData;
  }

  @override
  void onDone(void Function()? handleDone) {
    _onDone = handleDone;
  }

  /// Not supported: This StreamSubscription based
  /// on [IObservableListenable], which doesn't emit errors
  /// This method will never fire an error
  @override
  void onError(Function? handleError) {}

  @override
  void pause([Future<void>? resumeSignal]) {
    _isPaused = true;
    resumeSignal?.then((_) => resume());
  }

  @override
  void resume() {
    _isPaused = false;
    for (var val in _pendingValues) {
      _onData?.call(val);
    }
    _pendingValues.clear();
  }

  @override
  bool get isPaused => _isPaused;

  @override
  Future<void> cancel() async {
    if (!_isCanceled) {
      _observableSub.cancel();
      _onDone?.call();
      _isCanceled = true;
    }
  }

  @override
  Future<E> asFuture<E>([E? futureValue]) {
    final completer = Completer<E>();
    completer.complete(futureValue);
    return completer.future;
  }
}
