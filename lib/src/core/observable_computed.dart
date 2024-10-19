part of "observable.dart";

/// Listens few Streams
/// and invoke some function when one of them triggered
class ObservableComputed<T> extends Observable<T> with RxSubsMixin {
  final T Function() _computer;

  ObservableComputed(
    List<Stream> streams,
    this._computer, {
    notifyOnlyIfChanged = false,
  }) : super(_computer(), notifyOnlyIfChanged: notifyOnlyIfChanged) {
    value = _computer();
    for (var stream in streams) {
      regSub(stream.listen((_) {
        value = _computer();
      }));
    }
  }

  @override
  Future close() {
    dispose();
    return super.close();
  }

  @override
  void registerFieldsForDispose() {}
}
