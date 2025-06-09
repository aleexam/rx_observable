import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:rx_observable/src/i_disposable.dart';

import '../observable.dart';
import '../../typedefs.dart';
import '../stream_adapters/from_stream_adapter.dart';
import '../stream_adapters/to_stream_adapter.dart';

// Extensions for primitive types to quickly wrap them in observables.

extension StringExtension on String {
  /// Creates an [ObservableString] initialized with this String value.
  ObservableString get obs => ObservableString(this);

  /// Creates an [ObservableAsync<String>] initialized with this String value.
  ObservableAsync<String> get obsA => ObservableAsync<String>(this);

  /// Creates a read-only observable wrapping this String value.
  ObservableReadOnly<String> get obsReadOnly =>
      ObservableReadOnly<String>(this);

  /// Creates a read-only asynchronous observable wrapping this String value.
  ObservableAsync<String> get obsAReadOnly => ObservableAsync<String>(this);
}

extension IntExtension on int {
  /// Creates an [ObservableInt] initialized with this int value.
  ObservableInt get obs => ObservableInt(this);

  /// Creates an [ObservableAsync<int>] initialized with this int value.
  ObservableAsync<int> get obsA => ObservableAsync<int>(this);

  /// Creates a read-only observable wrapping this int value.
  ObservableReadOnly<int> get obsReadOnly => ObservableReadOnly<int>(this);

  /// Creates a read-only asynchronous observable wrapping this int value.
  ObservableAsync<int> get obsAReadOnly => ObservableAsync<int>(this);
}

extension DoubleExtension on double {
  /// Creates an [ObservableDouble] initialized with this double value.
  ObservableDouble get obs => ObservableDouble(this);

  /// Creates an [ObservableAsync<double>] initialized with this double value.
  ObservableAsync<double> get obsA => ObservableAsync<double>(this);

  /// Creates a read-only observable wrapping this double value.
  ObservableReadOnly<double> get obsReadOnly =>
      ObservableReadOnly<double>(this);

  /// Creates a read-only asynchronous observable wrapping this double value.
  ObservableAsync<double> get obsAReadOnly => ObservableAsync<double>(this);
}

extension BoolExtension on bool {
  /// Creates a generic [Observable<bool>] initialized with this boolean value.
  Observable<bool> get obs => Observable<bool>(this);

  /// Creates an [ObservableAsync<bool>] initialized with this boolean value.
  ObservableAsync<bool> get obsA => ObservableAsync<bool>(this);

  /// Creates a read-only observable wrapping this boolean value.
  ObservableReadOnly<bool> get obsReadOnly => ObservableReadOnly<bool>(this);

  /// Creates a read-only asynchronous observable wrapping this boolean value.
  ObservableAsync<bool> get obsAReadOnly => ObservableAsync<bool>(this);
}

extension ObservableT<T> on T {
  /// Creates a generic [Observable<T>] initialized with this value.
  Observable<T> get obs => Observable<T>(this);

  /// Creates an [ObservableAsync<T>] initialized with this value.
  ObservableAsync<T> get obsA => ObservableAsync<T>(this);

  /// Creates a read-only observable wrapping this value.
  ObservableReadOnly<T> get obsReadOnly => ObservableReadOnly<T>(this);

  /// Creates a read-only asynchronous observable wrapping this value.
  ObservableAsync<T> get obsAReadOnly => ObservableAsync<T>(this);
}

extension ListExtension<T> on List<T> {
  /// Creates an [Observable<List<T>>] wrapping this list.
  Observable<List<T>> get obs => Observable<List<T>>(this);

  /// Creates an [ObservableAsync<List<T>>] wrapping this list.
  ObservableAsync<List<T>> get obsA => ObservableAsync<List<T>>(this);

  /// Creates a read-only observable wrapping this list.
  ObservableReadOnly<List<T>> get obsReadOnly =>
      ObservableReadOnly<List<T>>(this);

  /// Creates a read-only asynchronous observable wrapping this list.
  ObservableAsync<List<T>> get obsAReadOnly => ObservableAsync<List<T>>(this);
}

extension ListObservableExtension on List<IObservable> {
  /// Creates an [ObservableComputed] that depends on all [IObservable] items in the list.
  ///
  /// This simplifies reactive computations based on multiple observables.
  /// The provided [computer] function will be re-evaluated automatically whenever
  /// any of the observables in the list change.
  ///
  /// Example:
  /// final userInfo = [firstName, age].compute(() {
  ///   return "${firstName.value} ${age.value}";
  /// });
  ///
  /// In this example, `userInfo` will automatically update when either `firstName` or `age` changes.
  ObservableComputed<T> compute<T>(T Function() computer) {
    return ObservableComputed<T>(this, computer: computer);
  }

  /// Creates an [ObservableComputedAsync] that depends on all [IObservable] items in the list.
  ///
  /// This simplifies reactive computations based on multiple observables.
  /// The provided [computer] function will be re-evaluated automatically whenever
  /// any of the observables in the list change.
  ///
  /// Example:
  /// final userInfo = [firstName, age].compute(() {
  ///   return "${firstName.value} ${age.value}";
  /// });
  ///
  /// In this example, `userInfo` will automatically update when either `firstName` or `age` changes.
  ObservableComputedAsync<T> computeA<T>(T Function() computer) {
    return ObservableComputedAsync<T>(this, computer: computer);
  }

  /// Creates ObservableGroup, that allows you to group multiple observables into one.
  ObservableGroup group() {
    return ObservableGroup(this);
  }
}

extension ComputedFunction<T> on T Function() {
  /// Converts a function into an [ObservableComputed] with specified dependencies.
  ObservableComputed<T> computeWith(List<IObservable> observables) {
    return ObservableComputed<T>(observables, computer: this);
  }

  /// Converts a function into an [ObservableComputedAsync] with specified dependencies.
  ObservableComputedAsync<T> computeWithAsync(List<IObservable> observables) {
    return ObservableComputedAsync<T>(observables, computer: this);
  }
}

extension ObservableStreamAdapters<T> on Stream<T> {
  /// Wraps a [Stream] into an [IObservableListenable].
  StreamToObservableAdapter<T> asObservable() {
    return StreamToObservableAdapter<T>(this);
  }
}

extension StreamObservableAdapters<T> on IObservableSync<T> {
  /// Converts an [IObservable] into a [Stream].
  @Deprecated("Use ObservableAsync to get stream instead")
  Stream<T> asStream() {
    return ObservableToStreamAdapter<T>(this);
  }
}

extension CancelSubsList on List<StreamSubscription> {
  /// Cancels all [StreamSubscription] instances in the list.
  void cancelAll() {
    for (var sub in this) {
      sub.cancel();
    }
    clear();
  }
}

extension CancelSubsSet on Set<StreamSubscription> {
  /// Cancels all [StreamSubscription] instances in the set.
  Future<void> cancelAll() async {
    for (var sub in this) {
      await sub.cancel();
    }
    clear();
  }
}

extension CloseStreamsList on List<StreamSink> {
  /// Closes all [StreamSink] instances in the list.
  Future<void> closeAll() async {
    for (var sink in this) {
      await sink.close();
    }
    clear();
  }
}

extension CloseStreamsSet on Set<StreamSink> {
  /// Closes all [StreamSink] instances in the set.
  Future<void> closeAll() async {
    for (var sink in this) {
      await sink.close();
    }
    clear();
  }
}

extension CloseEventSinksList on List<EventSink> {
  /// Closes all [EventSink] instances in the list.
  void closeAll() {
    for (var sink in this) {
      sink.close();
    }
    clear();
  }
}

extension CloseEventSinksSet on Set<EventSink> {
  /// Closes all [EventSink] instances in the set.
  void closeAll() {
    for (var sink in this) {
      sink.close();
    }
    clear();
  }
}

extension CloseDisposablesList on List<IDisposable> {
  /// Calls `dispose()` on all [IDisposable] instances in the list.
  void disposeAll() {
    for (var disposable in this) {
      disposable.dispose();
    }
    clear();
  }
}

extension CloseDisposablesSet on Set<IDisposable> {
  /// Calls `dispose()` on all [IDisposable] instances in the set.
  void disposeAll() {
    for (var disposable in this) {
      disposable.dispose();
    }
    clear();
  }
}

extension CloseCancelablesList on List<ICancelable> {
  /// Calls `cancel()` on all [ICancelable] instances in the list.
  void cancelAll() {
    for (var cancelable in this) {
      cancelable.cancel();
    }
    clear();
  }
}

extension CloseCancelablesSet on Set<ICancelable> {
  /// Calls `cancel()` on all [ICancelable] instances in the set.
  void cancelAll() {
    for (var cancelable in this) {
      cancelable.cancel();
    }
    clear();
  }
}

extension DisposeChangeNotifiersSet on Set<ChangeNotifier> {
  /// Calls `cancel()` on all [ICancelable] instances in the set.
  void disposeAll() {
    for (var notifier in this) {
      notifier.dispose();
    }
    clear();
  }
}

extension ObservableSelectExt<T> on ObservableReadOnly<T> {
  /// Selects a derived observable value using [selector].
  ///
  /// Similar to [map], but more semantic for selecting a field.
  /// Notifies listeners only if the selected value has changed,
  /// unless [alwaysNotify] is explicitly set to false.
  ObservableReadOnly<R> select<R>(
    R Function(T value) selector, {
    bool? alwaysNotify,
  }) {
    return map(
      selector,
      alwaysNotify: alwaysNotify,
    );
  }
}

extension ObservableAsyncSelectExt<T> on ObservableAsyncReadOnly<T> {
  /// Selects a derived observable value using [selector].
  ///
  /// Similar to [map], but more semantic for selecting a field.
  /// Notifies listeners only if the selected value has changed,
  /// unless [alwaysNotify] is explicitly set to false.
  ObservableAsyncReadOnly<R> select<R>(
    R Function(T value) selector, {
    bool? alwaysNotify,
  }) {
    return map(
      selector,
      alwaysNotify: alwaysNotify,
    );
  }
}