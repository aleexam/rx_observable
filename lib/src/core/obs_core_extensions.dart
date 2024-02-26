import 'dart:async';

import 'observable.dart';

export 'obs_extensions/bool_extensions.dart';
export 'obs_extensions/obs_string_ext.dart';
export 'obs_extensions/obs_num_ext.dart';

extension StringExtension on String {
  /// Returns a `ObservableString` with [this] `String` as initial value.
  ObservableString get obs => ObservableString(this);
  ObservableReadOnly<String> get obsReadOnly => ObservableReadOnly<String>(this);
}

extension IntExtension on int {
  /// Returns a `ObservableInt` with [this] `int` as initial value.
  ObservableInt get obs => ObservableInt(this);
  ObservableReadOnly<int> get obsReadOnly => ObservableReadOnly<int>(this);
}

extension DoubleExtension on double {
  /// Returns a `ObservableDouble` with [this] `double` as initial value.
  ObservableDouble get obs => ObservableDouble(this);
  ObservableReadOnly<double> get obsReadOnly => ObservableReadOnly<double>(this);
}

extension BoolExtension on bool {
  /// Returns a `ObservableBool` with [this] `bool` as initial value.
  Observable<bool> get obs => Observable<bool>(this);
  ObservableReadOnly<bool> get obsReadOnly => ObservableReadOnly<bool>(this);
}

extension ObservableT<T> on T {
  /// Returns a `Observable` instance with [this] `T` as initial value.
  Observable<T> get obs => Observable<T>(this);
  ObservableReadOnly<T> get obsReadOnly => ObservableReadOnly<T>(this);
}

extension ListExtension<T> on List<T> {
  /// Returns a `Observable` instance with [this] `List<T>` as initial value.
  Observable<List<T>> get obs => Observable<List<T>>(this);
  ObservableReadOnly<List<T>> get obsReadOnly => ObservableReadOnly<List<T>>(this);
}

extension CancelSubs on List<StreamSubscription> {
  cancelAll() {
    for (var sub in this) {
      sub.cancel();
    }
  }
}

extension CloseStreams on List<StreamSink> {
  closeAll() {
    for (var sink in this) {
      sink.close();
    }
  }
}
