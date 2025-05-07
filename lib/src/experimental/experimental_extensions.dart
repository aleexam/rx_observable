import '../core/observable.dart';
import 'stream_adapters/from_stream_adapter.dart';
import 'stream_adapters/to_stream_adapter.dart';

extension ObservableStreamAdapters<T> on Stream<T> {
  IObservableListenable<T> toObservable() {
    return StreamObservableAdapter<T>(this);
  }
}

extension StreamObservableAdapters<T> on IObservable<T> {
  Stream<T> toStream() {
    return ObservableStreamAdapter<T>(this);
  }
}