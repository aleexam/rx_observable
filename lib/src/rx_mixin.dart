import 'dart:async';

import 'package:rx_observable/src/obs_core_extensions.dart';

/// Mixin for simplified subscription/sink handling for classes that include streams subscriptions/sinks
mixin RxSubsMixin {
  final List<StreamSubscription> rxSubs = [];
  final List<StreamSink> rxSinks = [];

  /// Register object that require close when this class will be destroyed
  regSink(StreamSink sink) {
    rxSinks.add(sink);
  }

  /// Register list of objects that require close when this class will be destroyed
  regSinks(List<StreamSink> sinks) {
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