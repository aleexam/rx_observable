import 'dart:async';

import 'package:rx_observable/rx_observable.dart';

/// Mixin for simplified subscription/sink handling for classes that include streams subscriptions/sinks
mixin RxSubsMixin {

  final List<StreamSubscription> rxSubs = [];
  final List<EventSink> rxSinks = [];

  void registerFieldsForDispose();

  /// Reg [StreamSubscription] or [EventSink]
  reg(dynamic sinkOrSub) {
    if (sinkOrSub is EventSink) {
      regSink(sinkOrSub);
    } else if (sinkOrSub is StreamSubscription) {
      regSub(sinkOrSub);
    }
  }

  /// Reg list of [StreamSubscription] or [EventSink]
  regs(List<dynamic> sinksOrSubs) {
    for (var sinkOrSub in sinksOrSubs) {
      reg(sinkOrSub);
    }
  }

  /// Register object that require close when this class will be destroyed
  regSink(EventSink sink) {
    rxSinks.add(sink);
  }

  /// Register list of objects that require close when this class will be destroyed
  regSinks(List<EventSink> sinks) {
    rxSinks.addAll(sinks);
  }

  /// Register subscription that require close when this class will be destroyed
  regSub(StreamSubscription sub) {
    rxSubs.add(sub);
  }

  /// Register list of subscriptions that require close when this class will be destroyed
  regSubs(List<StreamSubscription> subs) {
    rxSubs.addAll(subs);
  }

  /// Dispose method that automatically close all sinks and cancel all subscriptions
  void dispose() {
    rxSubs.cancelAll();
    rxSinks.closeAll();
  }
}
