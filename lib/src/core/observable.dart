import 'dart:async';

import 'package:get/get_rx/src/rx_types/rx_types.dart';

import '../../rx_observable.dart';

part 'obs_extensions/obs_string.dart';
part 'obs_extensions/obs_num.dart';
part 'observable_computed.dart';

class Observable<T> extends Rx<T> implements EventSink {

  /// Constructs a [Observable], with value setter and getter, pass initial value, handlers for
  /// [onListen], [onCancel], flag to handle events [sync] and
  /// flag [notifyOnlyIfChanged] - if true, listeners will be notified
  /// if new value not equals to old value
  ///
  /// See also [BehaviorSubject], and [StreamController.broadcast]
  Observable(super.initialValue);

  @override
  void add(event) {
    value = event;
  }

}