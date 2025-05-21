import 'dart:async';

import '../../../rx_observable.dart';

@Deprecated("Use ObservableAsync to get stream instead")
class ObservableToStreamAdapter<T> extends Stream<T> {
  final IObservableListenable<T> observable;

  ObservableToStreamAdapter(this.observable);

  @override
  StreamSubscription<T> listen(void Function(T)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final controller = StreamController<T>(sync: true);

    final sub = observable.listen(controller.add);

    controller.onCancel = () {
      sub.cancel();
      controller.close();
    };

    return controller.stream.listen(onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError ?? false,
    );
  }
}