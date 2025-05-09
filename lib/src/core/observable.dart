import 'dart:async';

import 'package:flutter/foundation.dart';

import '../experimental/experimental.dart';
import '../i_cancelable.dart';
import '../i_disposable.dart';

part '../experimental/compact_observer/tracking_context.dart';
part 'additional/observable_computed.dart';
part 'additional/observable_group.dart';
part 'observable_async.dart';
part 'observable_sync.dart';
part 'rx_subscription.dart';

abstract class IObservableMutable<T> extends IObservable<T> { // Interface

  /// Set the new value and notify listeners
  set value(T value);
}

abstract class IObservableSync<T> // Interface
    implements ChangeNotifier, IObservable<T>, ValueListenable<T> {}

abstract class IObservableAsync<T> // Interface
    implements StreamController<T>, IObservable<T> {}

abstract class IObservable<T> extends IObservableListenable<T> { // Interface

  /// Returns the last emitted value or initial value.
  T get value;

  /// Notify all listeners
  void notify();
}

abstract class IObservableListenable<T> implements IDisposable { // Interface
  /// Custom stream-like listen with custom subscription
  /// More convenient than addListener API
  ObservableSubscription listen(FutureOr<void> Function(T) listener,
      {bool fireImmediately = false});

  /// Must always call dispose in [ObservableAsync]
  /// No need to call dispose in [Observable], if all
  /// listeners properly cancel their subscriptions
  @override
  void dispose();
}
