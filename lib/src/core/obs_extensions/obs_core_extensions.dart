import 'dart:async';

import 'package:rx_observable/src/i_cancelable.dart';
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
  ObservableReadOnly<String> get obsReadOnly => ObservableReadOnly<String>(this);

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
  ObservableReadOnly<double> get obsReadOnly => ObservableReadOnly<double>(this);

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
  ObservableReadOnly<List<T>> get obsReadOnly => ObservableReadOnly<List<T>>(this);

  /// Creates a read-only asynchronous observable wrapping this list.
  ObservableAsync<List<T>> get obsAReadOnly => ObservableAsync<List<T>>(this);
}

extension ComputedFunction<T> on T Function() {
  /// Converts a function into an [ObservableComputed] with specified dependencies.
  ObservableComputed<T> compute(List<IObservable> observables) {
    return ObservableComputed<T>(this, observables);
  }

  ObservableComputedAsync<T> computeAsync(List<IObservable> observables) {
    return ObservableComputedAsync<T>(this, observables);
  }
}

extension ObservableStreamAdapters<T> on Stream<T> {
  /// Wraps a [Stream] into an [IObservableListenable].
  IObservableListenable<T> asObservable() {
    return StreamObservableAdapter<T>(this);
  }
}

extension StreamObservableAdapters<T> on IObservableSync<T> {
  /// Converts an [IObservable] into a [Stream].
  @Deprecated("Use ObservableAsync to get stream instead")
  Stream<T> asStream() {
    return ObservableStreamAdapter<T>(this);
  }
}

extension CancelSubsList on List<StreamSubscription> {
  /// Cancels all [StreamSubscription] instances in the list.
  void cancelAll() {
    for (var sub in this) {
      sub.cancel();
    }
  }
}

extension CancelSubsSet on Set<StreamSubscription> {
  /// Cancels all [StreamSubscription] instances in the set.
  void cancelAll() {
    for (var sub in this) {
      sub.cancel();
    }
  }
}

extension CloseStreamsList on List<StreamSink> {
  /// Closes all [StreamSink] instances in the list.
  void closeAll() {
    for (var sink in this) {
      sink.close();
    }
  }
}

extension CloseStreamsSet on Set<StreamSink> {
  /// Closes all [StreamSink] instances in the set.
  void closeAll() {
    for (var sink in this) {
      sink.close();
    }
  }
}

extension CloseEventSinksList on List<EventSink> {
  /// Closes all [EventSink] instances in the list.
  void closeAll() {
    for (var sink in this) {
      sink.close();
    }
  }
}

extension CloseEventSinksSet on Set<EventSink> {
  /// Closes all [EventSink] instances in the set.
  void closeAll() {
    for (var sink in this) {
      sink.close();
    }
  }
}

extension CloseDisposablesList on List<IDisposable> {
  /// Calls `dispose()` on all [IDisposable] instances in the list.
  void disposeAll() {
    for (var disposable in this) {
      disposable.dispose();
    }
  }
}

extension CloseDisposablesSet on Set<IDisposable> {
  /// Calls `dispose()` on all [IDisposable] instances in the set.
  void disposeAll() {
    for (var disposable in this) {
      disposable.dispose();
    }
  }
}

extension CloseCancelablesList on List<ICancelable> {
  /// Calls `cancel()` on all [ICancelable] instances in the list.
  void cancelAll() {
    for (var cancelable in this) {
      cancelable.cancel();
    }
  }
}

extension CloseCancelablesSet on Set<ICancelable> {
  /// Calls `cancel()` on all [ICancelable] instances in the set.
  void cancelAll() {
    for (var cancelable in this) {
      cancelable.cancel();
    }
  }
}