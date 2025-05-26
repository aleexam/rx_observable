import 'dart:async';

import 'package:flutter/foundation.dart';

import '../experimental/experimental.dart';
import '../i_disposable.dart';
import 'mappers/async_mapper.dart';
import 'mappers/sync_mapper.dart';

part '../experimental/compact_observer/tracking_context.dart';
part 'additional/observable_computed.dart';
part 'additional/observable_group.dart';
part 'observable_async.dart';
part 'observable_sync.dart';
part 'rx_subscription.dart';
// part 'mappers/sync_mapper.dart';
// part 'mappers/async_mapper.dart';

/// Interface for a mutable observable value of type [T].
abstract class IObservableMutable<T> extends IObservable<T> {
  /// Set the new value and notify listeners
  set value(T value);

  /// Short version of value setter
  /// Set the new value and notify listeners
  set v(T v);
}

/// Interface for a synchronous observable of type [T].
/// Extends [IObservable] and acts as a [ChangeNotifier] and [ValueListenable].
abstract class IObservableSync<T> extends IObservable<T>
    implements ChangeNotifier, ValueListenable<T> {}

/// Interface for an asynchronous observable of type [T].
/// Extends [IObservable] and acts as a [StreamController] in mutable version [ObservableAsync].
abstract class IObservableAsync<T> extends IObservable<T> {}

/// Base interface for any observable value of type [T].
abstract class IObservable<T> extends IObservableListenable<T> {
  /// Returns the last emitted value or initial value.
  T get value;

  /// Short version of value getter
  /// Returns the last emitted value or initial value.
  T get v;

  /// Notifies all subscribed listeners of the current value.
  /// This will force unchanged value to notify listeners, even if notifyOnlyIfChanged set true
  void notify();

  /// Custom stream-like listen with custom subscription
  /// More convenient than addListener API,
  /// but works same as AddListener/RemoveListener for sync version, so expect same result
  /// For async version works just like stream.listen
  @override
  ObservableSubscription<T> listen(FutureOr<void> Function(T) listener,
      {bool fireImmediately = false});

  /// Maps an [IObservable] of type [T] to an [IObservable] of type [R].
  /// Returned observable is read-only
  /// [notifyOnlyIfChanged] - if true, will not notify
  /// if transform returns the same value as the previous transformed value
  IObservable<R> map<R>(R Function(T value) transform,
      {bool? notifyOnlyIfChanged});
}

/// Base class for observable without value.
/// This needs to allow streams to be represented as observable, for compatibility
/// [ObservableListener] for example, can work with observable or stream under the hood
abstract class IObservableListenable<T> implements IDisposable {
  /// Custom stream-like listen with custom subscription
  /// More convenient than addListener API,
  /// but works same as AddListener/RemoveListener for sync version, so expect same result
  /// For async version works just like stream.listen
  ObservableSubscription<T> listen(FutureOr<void> Function(T) listener);

  /// Must always call dispose in [ObservableAsync]
  /// No need to call dispose in [Observable], if all
  /// listeners properly cancel their subscriptions
  @override
  void dispose();
}

@visibleForTesting
@protected
void reportObservableFlutterError<R extends IObservableListenable<T>, T>(
    Object exception, StackTrace stack, R obs) {
  FlutterError.reportError(FlutterErrorDetails(
    exception: exception,
    stack: stack,
    library: 'foundation library',
    context: ErrorDescription(
        'while dispatching notifications for ${obs.runtimeType}'),
    informationCollector: () => <DiagnosticsNode>[
      DiagnosticsProperty<R>(
        'The ${obs.runtimeType} sending notification was',
        obs,
        style: DiagnosticsTreeStyle.errorProperty,
      ),
    ],
  ));
}
