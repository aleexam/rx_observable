import 'dart:async';
import 'package:rx_observable/src/core/async/stream_view_impl.dart';

import '../../rx_observable.dart';
import 'async/error_and_stacktrace.dart';

part 'obs_extensions/obs_string.dart';
part 'obs_extensions/obs_num.dart';
part 'observable_computed.dart';

abstract interface class IObservable<T> implements StreamWithCapturedError<T> {
  /// Returns underlying stream
  StreamWithCapturedError<T> get stream;

  /// Returns the last emitted value or initial value.
  T get value;
}

class Observable<T> extends ObservableReadOnly<T> {

  /// If true, listeners will be notified if new value not equals to old value
  /// Default true
  final bool notifyOnlyIfChanged;

  Observable(super.initialValue, {this.notifyOnlyIfChanged = true});

  /// Set and emit the new value.
  set value(T newValue) {
    if (!notifyOnlyIfChanged || newValue != value) {
      _value = newValue;
      add(value);
    }
  }

}

/// Class for observable value (stream + current value). Based on [BehaviorSubject]
class ObservableReadOnly<T> extends StreamViewImpl<T> implements IObservable<T> {

  late T _value;

  /// Constructs a [Observable], optionally pass initial value, handlers for
  /// [onListen], [onCancel], flag to handle events [sync] and
  /// flag [notifyOnlyIfChanged] - if true, listeners will be notified
  /// if new value not equals to old value
  ///
  /// See also [BehaviorSubject], and [StreamController.broadcast]
  ObservableReadOnly(T initialValue,{
    void Function()? onListen,
    void Function()? onCancel,
    bool sync = false,
  }) : super(StreamController<T>.broadcast(
    onListen: onListen,
    onCancel: onCancel,
    sync: sync,
  )) {
    _value = initialValue;
  }


  @override
  void onAdd(T event) {
    _value = event;
  }

  /// Triggers stream to send new value
  void refresh() {
    add(_value);
  }

  @override
  void onAddError(Object error, [StackTrace? stackTrace]) => setError(error, stackTrace);

  @override
  StreamWithCapturedError<T> get stream => this;

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
}