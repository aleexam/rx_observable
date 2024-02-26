// ignore_for_file: implementation_imports

import 'dart:async';
import 'package:rx_observable/src/core/async/observable_stream.dart';
import 'package:rx_observable/src/core/async/stream_view_impl.dart';
import 'package:rxdart/rxdart.dart';

import '../../rx_observable.dart';

part 'obs_extensions/obs_string.dart';
part 'obs_extensions/obs_num.dart';
part 'observable_computed.dart';

abstract interface class IObservable<T> implements ObservableStream<T> {

  /// Returns underlying stream
  ObservableStream<T> get stream;

  /// Returns the last emitted value or initial value.
  T get value;
}

class Observable<T> extends ObservableReadOnly<T> {
  Observable(super.initialValue);

  /// Set and emit the new value.
  set value(T newValue) {
    if (!notifyOnlyIfChanged || newValue != value) {
      value = newValue;
      onAdd(value);
    }
  }

}

/// Class for observable value (stream + current value). Based on [BehaviorSubject]
class ObservableReadOnly<T> extends StreamViewImpl<T> implements IObservable<T> {

  late final T _value;

  /// If true, listeners will be notified if new value not equals to old value
  /// Default true
  final bool notifyOnlyIfChanged;

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
    this.notifyOnlyIfChanged = true
  }) : super(StreamController<T>.broadcast(
    onListen: onListen,
    onCancel: onCancel,
    sync: sync,
  )) {
    _value = initialValue;
  }


  @override
  void onAdd(T event) {

  }

  @override
  void onAddError(Object error, [StackTrace? stackTrace]) => setError(error, stackTrace);

  @override
  ObservableStream<T> get stream => this;

  T call() {
    return value;
  }

  @override
  T get value => _value;

  @override
  bool get hasError => errorAndStackTrace != null;

  @override
  Object? get errorOrNull => errorAndStackTrace?.error;

  @override
  Object get error {
    final errorAndSt = errorAndStackTrace;
    if (errorAndSt != null) {
      return errorAndSt.error;
    }
    throw ValueStreamError.hasNoError();
  }

  ErrorAndStackTrace? errorAndStackTrace;
  void setError(Object error, StackTrace? stackTrace) {
    errorAndStackTrace = ErrorAndStackTrace(error, stackTrace);
  }

  @override
  StackTrace? get stackTrace => errorAndStackTrace?.stackTrace;
}