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

abstract class IObservableMutable<T> extends IObservable<T> {
  set value(T value);
}

abstract interface class IObservableSync<T>
    implements ChangeNotifier, IObservable<T>, ValueListenable<T> {}

abstract interface class IObservableAsync<T>
    implements StreamController<T>, IObservable<T> {}

abstract interface class IObservable<T> extends IObservableListenable<T> {
  /// Returns the last emitted value or initial value.
  T get value;

  /// Notify all listeners
  void notify();
}

abstract interface class IObservableListenable<T> implements IDisposable {
  /// Custom stream-like listen with custom subscription
  ObservableSubscription listen(FutureOr<void> Function(T) listener,
      {bool fireImmediately = false});

  /// Must always call dispose in [ObservableAsync]
  /// No need to call dispose in [Observable], if all
  /// listeners properly cancel their subscriptions
  @override
  void dispose();
}
