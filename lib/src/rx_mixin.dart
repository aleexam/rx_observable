import 'dart:async';
import 'package:rx_observable/src/core/obs_core_extensions.dart';
import 'i_disposable.dart';

abstract interface class IRegisterFieldsForDispose {
  /// Do not forget to register all async fields that must be closed/cancelled
  void registerFieldsForDispose();
}

/// Mixin for simplified subscription/sink handling for classes that include streams subscriptions/sinks
mixin RxSubsMixin implements IRegisterFieldsForDispose {

  final List<StreamSubscription> rxSubs = [];
  final List<EventSink> rxSinks = [];
  final List<IClosable> disposables = [];

  /// Reg [StreamSubscription] or [EventSink] or [IClosable]
  reg(dynamic sinkOrSub) {
    if (sinkOrSub is EventSink) {
      regSink(sinkOrSub);
    } else if (sinkOrSub is StreamSubscription) {
      regSub(sinkOrSub);
    } else if (sinkOrSub is IClosable) {
      regDisposable(sinkOrSub);
    }
  }

  /// Reg list of [StreamSubscription] or [EventSink] or [IClosable]
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

  /// Register [IClosable] that require close when this class will be destroyed
  regDisposable(IClosable disposable) {
    disposables.add(disposable);
  }

  /// Register list of [IClosable] that require close when this class will be destroyed
  regDisposables(List<IClosable> disposableList) {
    disposables.addAll(disposableList);
  }

  /// Dispose method that automatically close all sinks and cancel all subscriptions
  void dispose() {
    rxSubs.cancelAll();
    rxSinks.closeAll();
    disposables.disposeAll();
  }
}
