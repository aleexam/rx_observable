part of "observable.dart";

/// Listens few Streams
/// and invoke some function when one of them triggered
class ObservableComputed<T> with RxSubsMixin implements StreamSink<T> {

  late final Observable<T> value;
  final T Function() _computer;

  Stream<T> get stream => value.stream;

  ObservableComputed(this._computer, List<Stream> streams) {
    value = Observable(_computer());
    for (var stream in streams) {
      regSub(stream.listen((_) {
        value.value = _computer();
      }));
    }
  }

  Observable<T> call() {
    return value;
  }

  @override
  void add(event) {
    value.add(event);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    return value.addError(error, stackTrace);
  }

  @override
  Future addStream(Stream<T> stream) {
    return value.addStream(stream);
  }

  StreamSubscription<T> listen(void Function(T) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError}) {
    return value.stream.listen(onData,
          cancelOnError: cancelOnError,
          onDone: onDone,
          onError: onError,
    );
  }

  @override
  Future close() {
    dispose();
    return value.close();
  }

  @override
  Future get done => value.done;
}