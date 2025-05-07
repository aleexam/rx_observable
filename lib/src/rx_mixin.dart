import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:rx_observable/src/core/obs_core_extensions.dart';
import 'package:rx_observable/src/i_cancelable.dart';

import 'i_disposable.dart';

abstract interface class IRegisterFieldsForDispose {
  /// Do not forget to register all async fields that must be closed/cancelled
  void registerFieldsForDispose();
}

/// Mixin for simplified subscription/sink handling for classes that include streams subscriptions/sinks
mixin RxSubsMixin implements IRegisterFieldsForDispose {
  final List<StreamSubscription> rxSubs = [];
  final List<EventSink> rxSinks = [];
  final List<IDisposable> disposables = [];
  final List<ICancelable> cancelables = [];

  /// Reg [StreamSubscription] or [EventSink] or [IDisposable]
  reg(dynamic sinkOrSub) {
    if (sinkOrSub is EventSink) {
      regSink(sinkOrSub);
    } else if (sinkOrSub is StreamSubscription) {
      regSub(sinkOrSub);
    } else if (sinkOrSub is IDisposable) {
      regDisposable(sinkOrSub);
    } else if (sinkOrSub is ICancelable) {
      regCancelable(sinkOrSub);
    } else {
      throw UnimplementedError(
          "Object with type ${sinkOrSub.runtimeType} with value ${sinkOrSub.toString()} "
          "is not supported for automatic register in RxSubsMixin. "
          "Please close/dispose it manually in dispose method.");
    }
  }

  /// Reg list of [StreamSubscription] or [EventSink] or [IDisposable]
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

  /// Register [IDisposable] that require close when this class will be destroyed
  regDisposable(IDisposable disposable) async {
    disposables.add(disposable);
  }

  /// Register list of [IDisposable] that require close when this class will be destroyed
  regDisposables(List<IDisposable> disposableList) {
    disposables.addAll(disposableList);
  }

  /// Register [ICancelable] that require close when this class will be destroyed
  regCancelable(ICancelable cancelable) async {
    cancelables.add(cancelable);
  }

  /// Register list of [ICancelable] that require close when this class will be destroyed
  regCancelables(List<ICancelable> cancelable) async {
    cancelables.addAll(cancelable);
  }

  /// Dispose method that automatically close all sinks and cancel all subscriptions
  @mustCallSuper
  void dispose() {
    rxSubs.cancelAll();
    rxSinks.closeAll();
    disposables.disposeAll();
    cancelables.cancelAll();
  }
}
