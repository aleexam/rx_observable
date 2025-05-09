// ignore_for_file: library_private_types_in_public_api

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rx_observable/src/core/obs_core_extensions.dart';
import 'package:rx_observable/src/i_cancelable.dart';

import 'i_disposable.dart';

/// Mixin for simplified subscription/sink handling for classes that include observables, streams subscriptions/sinks
mixin RxSubsMixin {
  final Set<StreamSubscription> _rxSubs = {};
  final Set<EventSink> _rxSinks = {};
  final Set<IDisposable> _disposables = {};
  final Set<ICancelable> _cancelables = {};

  /// Reg [IDisposable] or [ICancelable] or [StreamSubscription] or [EventSink]
  void reg(dynamic sinkOrSub) {
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
  void regs(List<dynamic> sinksOrSubs) {
    for (var sinkOrSub in sinksOrSubs) {
      reg(sinkOrSub);
    }
  }

  /// Register object that require close when this class will be destroyed
  void regSink(EventSink sink) {
    _rxSinks.add(sink);
  }

  /// Register list of objects that require close when this class will be destroyed
  void regSinks(List<EventSink> sinks) {
    for (var item in sinks) {
      regSink(item);
    }
  }

  /// Register subscription that require close when this class will be destroyed
  void regSub(StreamSubscription sub) {
    _rxSubs.add(sub);
  }

  /// Register list of subscriptions that require close when this class will be destroyed
  void regSubs(List<StreamSubscription> subs) {
    for (var item in subs) {
      regSub(item);
    }
  }

  /// Register [IDisposable] that require close when this class will be destroyed
  void regDisposable(IDisposable disposable) {
    _disposables.add(disposable);
  }

  /// Register list of [IDisposable] that require close when this class will be destroyed
  void regDisposables(List<IDisposable> disposableList) {
    for (var item in disposableList) {
      regDisposable(item);
    }
  }

  /// Register [ICancelable] that require close when this class will be destroyed
  void regCancelable(ICancelable cancelable) {
    _cancelables.add(cancelable);
  }

  /// Register list of [ICancelable] that require close when this class will be destroyed
  void regCancelables(List<ICancelable> cancelableList) {
    for (var item in cancelableList) {
      regCancelable(item);
    }
  }

  /// Dispose method that automatically close all sinks and cancel all subscriptions
  @mustCallSuper
  void dispose() {
    _rxSubs.cancelAll();
    _rxSinks.closeAll();
    _disposables.disposeAll();
    _cancelables.cancelAll();
    if (_rxSubs.isEmpty &&
        _rxSinks.isEmpty &&
        _disposables.isEmpty &&
        _cancelables.isEmpty) {
      if (kDebugMode) {
        print('No fields registered before dispose in $runtimeType.');
      }
    }
  }
}
