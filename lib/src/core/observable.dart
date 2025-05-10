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

/// Interface for a mutable observable value of type [T].
abstract class IObservableMutable<T> extends IObservable<T> { // Interface

  /// Set the new value and notify listeners
  set value(T value);

  /// Short version of value setter
  set v(T v);
}

/// Interface for a synchronous observable of type [T].
/// Extends [IObservable] and acts as a [ChangeNotifier] and [ValueListenable].
abstract class IObservableSync<T> extends IObservable<T> // Interface
    implements ChangeNotifier, ValueListenable<T> {}

/// Interface for an asynchronous observable of type [T].
/// Extends [IObservable] and acts as a [StreamController].
abstract class IObservableAsync<T> extends IObservable<T> // Interface
    implements StreamController<T> {}

/// Base interface for any observable value of type [T].
abstract class IObservable<T> extends IObservableListenable<T> { // Interface

  /// Returns the last emitted value or initial value.
  T get value;

  /// Short version of value getter
  T get v;

  /// Notifies all subscribed listeners of the current value.
  /// This will force unchanged value to notify listeners, even if notifyOnlyIfChanged set true
  void notify();
}

/// Base class for observable without value.
/// This needs to allow streams to be represented as observable, for compatibility
/// [ObservableListener] for example, can work with observable or stream under the hood
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
