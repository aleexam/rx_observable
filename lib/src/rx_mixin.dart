import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:rx_observable/src/core/obs_extensions/obs_core_extensions.dart';

import 'i_disposable.dart';

/// Mixin for simplified subscription/sink handling for classes that include observables, streams subscriptions/sinks
mixin RxSubsMixin {
  final _mixinRoot = _RxSubsMixinObject();

  /// Reg [IDisposable] or [ICancelable] or [StreamSubscription] or [EventSink]
  void reg<C extends Object>(C sinkOrSub) {
    _mixinRoot.reg(sinkOrSub);
  }

  /// Reg list of [StreamSubscription] or [EventSink] or [IDisposable]
  void regs<C extends Object>(List<C> sinksOrSubs) {
    _mixinRoot.regs(sinksOrSubs);
  }

  /// Register object that require close when this class will be destroyed
  void regSink(EventSink sink) {
    _mixinRoot.regSink(sink);
  }

  /// Register list of objects that require close when this class will be destroyed
  void regSinks(List<EventSink> sinks) {
    _mixinRoot.regSinks(sinks);
  }

  /// Register subscription that require close when this class will be destroyed
  void regSub(StreamSubscription sub) {
    _mixinRoot.regSub(sub);
  }

  /// Register list of subscriptions that require close when this class will be destroyed
  void regSubs(List<StreamSubscription> subs) {
    _mixinRoot.regSubs(subs);
  }

  /// Register [IDisposable] that require close when this class will be destroyed
  void regDisposable(IDisposable disposable) {
    _mixinRoot.regDisposable(disposable);
  }

  /// Register list of [IDisposable] that require close when this class will be destroyed
  void regDisposables(List<IDisposable> disposableList) {
    _mixinRoot.regDisposables(disposableList);
  }

  /// Register [ICancelable] that require close when this class will be destroyed
  void regCancelable(ICancelable cancelable) {
    _mixinRoot.regCancelable(cancelable);
  }

  /// Register list of [ICancelable] that require close when this class will be destroyed
  void regCancelables(List<ICancelable> cancelableList) {
    _mixinRoot.regCancelables(cancelableList);
  }

  /// Dispose method that automatically close all sinks and cancel all subscriptions
  @mustCallSuper
  void dispose() {
    _mixinRoot.dispose();
  }
}

/// Mixin for simplified subscription/sink handling for classes that include observables, streams subscriptions/sinks
/// This specially for widgets dispose compatibility
mixin RxSubsStateMixin<T extends StatefulWidget> on State<T> {
  final _mixinRoot = _RxSubsMixinObject();

  /// Reg [IDisposable] or [ICancelable] or [StreamSubscription] or [EventSink]
  void reg<C extends Object>(C sinkOrSub) {
    _mixinRoot.reg(sinkOrSub);
  }

  /// Reg list of [StreamSubscription] or [EventSink] or [IDisposable]
  void regs<C extends Object>(List<C> sinksOrSubs) {
    _mixinRoot.regs(sinksOrSubs);
  }

  /// Register object that require close when this class will be destroyed
  void regSink(EventSink sink) {
    _mixinRoot.regSink(sink);
  }

  /// Register list of objects that require close when this class will be destroyed
  void regSinks(List<EventSink> sinks) {
    _mixinRoot.regSinks(sinks);
  }

  /// Register subscription that require close when this class will be destroyed
  void regSub(StreamSubscription sub) {
    _mixinRoot.regSub(sub);
  }

  /// Register list of subscriptions that require close when this class will be destroyed
  void regSubs(List<StreamSubscription> subs) {
    _mixinRoot.regSubs(subs);
  }

  /// Register [IDisposable] that require close when this class will be destroyed
  void regDisposable(IDisposable disposable) {
    _mixinRoot.regDisposable(disposable);
  }

  /// Register list of [IDisposable] that require close when this class will be destroyed
  void regDisposables(List<IDisposable> disposableList) {
    _mixinRoot.regDisposables(disposableList);
  }

  /// Register [ICancelable] that require close when this class will be destroyed
  void regCancelable(ICancelable cancelable) {
    _mixinRoot.regCancelable(cancelable);
  }

  /// Register list of [ICancelable] that require close when this class will be destroyed
  void regCancelables(List<ICancelable> cancelableList) {
    _mixinRoot.regCancelables(cancelableList);
  }

  /// Dispose method that automatically close all sinks and cancel all subscriptions
  @override
  @mustCallSuper
  void dispose() {
    _mixinRoot.dispose();
    super.dispose();
  }
}

/// Have to do like this, because older dart versions doesn't support [mixin class] declaration
class _RxSubsMixinObject {
  final Set<StreamSubscription> _rxSubs = {};
  final Set<EventSink> _rxSinks = {};
  final Set<IDisposable> _disposables = {};
  final Set<ICancelable> _cancelables = {};
  final Set<ChangeNotifier> _changeNotifiers = {};

  void reg(dynamic sinkOrSub) {
    if (sinkOrSub is List) {
      regs(sinkOrSub);
    } else if (sinkOrSub is EventSink) {
      regSink(sinkOrSub);
    } else if (sinkOrSub is StreamSubscription) {
      regSub(sinkOrSub);
    } else if (sinkOrSub is IDisposable) {
      regDisposable(sinkOrSub);
    } else if (sinkOrSub is ICancelable) {
      regCancelable(sinkOrSub);
    } else if (sinkOrSub is ChangeNotifier) {
      regNotifier(sinkOrSub);
    } else {
      throw UnimplementedError(
          "Object with type ${sinkOrSub.runtimeType} with value ${sinkOrSub.toString()} "
          "is not supported for automatic register in RxSubsMixin. "
          "Please use DisposableAdapter() or close/dispose it manually in dispose method.");
    }
  }

  void regs(List<dynamic> sinksOrSubs) {
    for (var sinkOrSub in sinksOrSubs) {
      reg(sinkOrSub);
    }
  }

  void regSink(EventSink sink) {
    _rxSinks.add(sink);
  }

  void regSinks(List<EventSink> sinks) {
    for (var item in sinks) {
      regSink(item);
    }
  }

  void regSub(StreamSubscription sub) {
    _rxSubs.add(sub);
  }

  void regSubs(List<StreamSubscription> subs) {
    for (var item in subs) {
      regSub(item);
    }
  }

  void regDisposable(IDisposable disposable) {
    _disposables.add(disposable);
  }

  void regDisposables(List<IDisposable> disposableList) {
    for (var item in disposableList) {
      regDisposable(item);
    }
  }

  void regCancelable(ICancelable cancelable) {
    _cancelables.add(cancelable);
  }

  void regCancelables(List<ICancelable> cancelableList) {
    for (var item in cancelableList) {
      regCancelable(item);
    }
  }

  void regNotifier(ChangeNotifier notifier) {
    _changeNotifiers.add(notifier);
  }

  void regNotifiers(List<ChangeNotifier> notifiersList) {
    for (var item in notifiersList) {
      regNotifier(item);
    }
  }

  @mustCallSuper
  void dispose() {
    _rxSubs.cancelAll();
    _rxSinks.closeAll();
    _disposables.disposeAll();
    _cancelables.cancelAll();
    _changeNotifiers.disposeAll();
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
