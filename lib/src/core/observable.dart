import 'dart:async';

import '../../rx_observable.dart';
import 'async/error_and_stacktrace.dart';

part 'obs_extensions/obs_string.dart';
part 'obs_extensions/obs_num.dart';
part 'observable_computed.dart';
part 'async/stream_with_value.dart';

abstract interface class IObservable<T> implements StreamSink<T>, Stream<T>, IDisposable {
  /// Returns underlying stream
  StreamWithValue<T> get stream;

  /// Returns the last emitted value or initial value.
  T get value;
}

class Observable<T> extends ObservableReadOnly<T> {

  /// Constructs a [Observable], with value setter and getter, pass initial value, handlers for
  /// [onListen], [onCancel], flag to handle events [sync] and
  /// flag [notifyOnlyIfChanged] - if true, listeners will be notified
  /// if new value not equals to old value
  ///
  /// See also [BehaviorSubject], and [StreamController.broadcast]
  Observable(super.initialValue,{
    super.onListen,
    super.onCancel,
    super.sync = false,
    super.notifyOnlyIfChanged = true,
  });

  /// Set and emit the new value.
  set value(T newValue) => add(newValue);

}

/// Class for observable value (stream + current value). Based on [BehaviorSubject]
class ObservableReadOnly<T> extends StreamWithValue<T> implements IObservable<T> {

  /// Constructs a [ObservableReadOnly], pass initial value, handlers for
  /// [onListen], [onCancel], flag to handle events [sync] and
  /// flag [notifyOnlyIfChanged] - if true, listeners will be notified
  /// if new value not equals to old value
  ///
  /// See also [BehaviorSubject], and [StreamController.broadcast]
  ObservableReadOnly(T initialValue,{
    void Function()? onListen,
    void Function()? onCancel,
    bool sync = false,
    bool notifyOnlyIfChanged = false,
  }) : super(StreamController<T>.broadcast(
    onListen: onListen,
    onCancel: onCancel,
    sync: sync,
  ), notifyOnlyIfChanged, initialValue);


  @override
  void onAdd(T event) {
    _value = event;
  }

  @override
  void onAddError(Object error, [StackTrace? stackTrace]) => setError(error, stackTrace);

  @override
  StreamWithValue<T> get stream => this;

  T call() {
    return value;
  }

  @override
  T get value => _value;

  @override
  bool get hasError => errorAndStackTrace != null;

  @override
  Object? get errorOrNull => errorAndStackTrace?.error;

  ErrorAndStackTrace? errorAndStackTrace;
  void setError(Object error, StackTrace? stackTrace) {
    errorAndStackTrace = ErrorAndStackTrace(error, stackTrace);
  }

  @override
  StackTrace? get stackTrace => errorAndStackTrace?.stackTrace;

  /// Same as close, for [IDisposable] compatibility
  @override
  void dispose() {
    close();
  }

}