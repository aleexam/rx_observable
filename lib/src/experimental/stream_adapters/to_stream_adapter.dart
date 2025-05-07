import 'dart:async';

import '../../../rx_observable.dart';

class ObservableStreamAdapter<T> extends Stream<T> {
  final IObservableListenable<T> observable;

  ObservableStreamAdapter(this.observable);

  @override
  StreamSubscription<T> listen(void Function(T)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final controller = StreamController<T>();

    final sub = observable.listen(controller.add);

    controller.onCancel = () {
      sub.cancel();
    };

    return controller.stream.listen(onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError ?? false,
    );
  }
}