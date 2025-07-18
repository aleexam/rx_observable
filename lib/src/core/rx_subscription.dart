part of 'observable.dart';

/// Custom subscription type for convenient listening of [IObservableSync] based on ChangeNotifier
class ObservableSubscription<T> implements ICancelable {
  final void Function() _cancel;

  ObservableSubscription(this._cancel);

  @override
  void cancel() => _cancel();
}

/// Custom subscription adapter type for [ObservableAsync] listening
/// implements both [ObservableSubscription] and [StreamSubscription]
class ObservableStreamSubscription<T> extends ObservableSubscription<T>
    implements StreamSubscription<T> {
  final StreamSubscription<T> _inner;

  ObservableStreamSubscription(this._inner) : super(() => _inner.cancel());

  @override
  Future<void> cancel() => _inner.cancel();

  @override
  void onData(void Function(T data)? handleData) => _inner.onData(handleData);

  @override
  void onError(Function? handleError) => _inner.onError(handleError);

  @override
  void onDone(void Function()? handleDone) => _inner.onDone(handleDone);

  @override
  void pause([Future<void>? resumeSignal]) => _inner.pause(resumeSignal);

  @override
  void resume() => _inner.resume();

  @override
  bool get isPaused => _inner.isPaused;

  @override
  Future<E> asFuture<E>([E? futureValue]) => _inner.asFuture(futureValue);
}
