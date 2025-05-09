import 'dart:async';

import 'package:rx_observable/src/i_cancelable.dart';
import 'package:rx_observable/src/i_disposable.dart';

import '../../src/core/observable.dart';
import '../typedefs.dart';
import 'obs_extensions/obs_num.dart';
import 'obs_extensions/obs_string.dart';
import 'stream_adapters/from_stream_adapter.dart';
import 'stream_adapters/to_stream_adapter.dart';

export '../../src/core/obs_extensions/bool_extensions.dart';
export '../../src/core/obs_extensions/obs_list_ext.dart';
export '../../src/core/obs_extensions/obs_map_ext.dart';
export '../../src/core/obs_extensions/obs_num.dart';
export '../../src/core/obs_extensions/obs_num_ext.dart';
export '../../src/core/obs_extensions/obs_set_ext.dart';
export '../../src/core/obs_extensions/obs_string.dart';
export '../../src/core/obs_extensions/obs_string_ext.dart';

extension StringExtension on String {
  /// Returns a `ObservableString` with [this] `String` as initial value.
  ObservableString get obs => ObservableString(this);

  ObservableAsync<String> get obsA => ObservableAsync<String>(this);

  ObservableReadOnly<String> get obsReadOnly =>
      ObservableReadOnly<String>(this);

  ObservableAsync<String> get obsAReadOnly => ObservableAsync<String>(this);
}

extension IntExtension on int {
  /// Returns a `ObservableInt` with [this] `int` as initial value.
  ObservableInt get obs => ObservableInt(this);

  ObservableAsync<int> get obsA => ObservableAsync<int>(this);

  ObservableReadOnly<int> get obsReadOnly => ObservableReadOnly<int>(this);

  ObservableAsync<int> get obsAReadOnly => ObservableAsync<int>(this);
}

extension DoubleExtension on double {
  /// Returns a `ObservableDouble` with [this] `double` as initial value.
  ObservableDouble get obs => ObservableDouble(this);

  ObservableAsync<double> get obsA => ObservableAsync<double>(this);

  ObservableReadOnly<double> get obsReadOnly =>
      ObservableReadOnly<double>(this);

  ObservableAsync<double> get obsAReadOnly => ObservableAsync<double>(this);
}

extension BoolExtension on bool {
  /// Returns a `ObservableBool` with [this] `bool` as initial value.
  Observable<bool> get obs => Observable<bool>(this);

  ObservableAsync<bool> get obsA => ObservableAsync<bool>(this);

  ObservableReadOnly<bool> get obsReadOnly => ObservableReadOnly<bool>(this);

  ObservableAsync<bool> get obsAReadOnly => ObservableAsync<bool>(this);
}

extension ObservableT<T> on T {
  /// Returns a `Observable` instance with [this] `T` as initial value.
  Observable<T> get obs => Observable<T>(this);

  ObservableAsync<T> get obsA => ObservableAsync<T>(this);

  ObservableReadOnly<T> get obsReadOnly => ObservableReadOnly<T>(this);

  ObservableAsync<T> get obsAReadOnly => ObservableAsync<T>(this);
}

extension ListExtension<T> on List<T> {
  /// Returns a `Observable` instance with [this] `List<T>` as initial value.
  Observable<List<T>> get obs => Observable<List<T>>(this);

  ObservableAsync<List<T>> get obsA => ObservableAsync<List<T>>(this);

  ObservableReadOnly<List<T>> get obsReadOnly =>
      ObservableReadOnly<List<T>>(this);

  ObservableAsync<List<T>> get obsAReadOnly => ObservableAsync<List<T>>(this);
}

extension ComputedFunction<T> on T Function() {
  ObservableComputed<T> compute(List<IObservable> observables) {
    return ObservableComputed<T>(this, observables);
  }
}

extension ObservableStreamAdapters<T> on Stream<T> {
  IObservableListenable<T> asObservable() {
    return StreamObservableAdapter<T>(this);
  }
}

extension StreamObservableAdapters<T> on IObservable<T> {
  Stream<T> asStream() {
    return ObservableStreamAdapter<T>(this);
  }
}

extension CancelSubsList on List<StreamSubscription> {
  cancelAll() {
    for (var sub in this) {
      sub.cancel();
    }
  }
}

extension CancelSubsSet on Set<StreamSubscription> {
  cancelAll() {
    for (var sub in this) {
      sub.cancel();
    }
  }
}

extension CloseStreamsList on List<StreamSink> {
  closeAll() {
    for (var sink in this) {
      sink.close();
    }
  }
}

extension CloseStreamsSet on Set<StreamSink> {
  closeAll() {
    for (var sink in this) {
      sink.close();
    }
  }
}

extension CloseEventSinksList on List<EventSink> {
  closeAll() {
    for (var sink in this) {
      sink.close();
    }
  }
}

extension CloseEventSinksSet on Set<EventSink> {
  closeAll() {
    for (var sink in this) {
      sink.close();
    }
  }
}

extension CloseDisposablesList on List<IDisposable> {
  disposeAll() {
    for (var disposable in this) {
      disposable.dispose();
    }
  }
}

extension CloseDisposablesSet on Set<IDisposable> {
  disposeAll() {
    for (var disposable in this) {
      disposable.dispose();
    }
  }
}

extension CloseCancelablesList on List<ICancelable> {
  cancelAll() {
    for (var cancelable in this) {
      cancelable.cancel();
    }
  }
}

extension CloseCancelablesSet on Set<ICancelable> {
  cancelAll() {
    for (var cancelable in this) {
      cancelable.cancel();
    }
  }
}
