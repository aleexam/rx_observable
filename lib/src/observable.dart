// ignore_for_file: implementation_imports

import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/transformers/start_with_error.dart';
import 'package:rxdart/src/utils/empty.dart';

part 'obs_extensions/obs_string.dart';
part 'obs_extensions/obs_num.dart';

/// Class for observable value (stream + current value). Based on [BehaviorSubject]
class Observable<T> extends Subject<T> implements ValueStream<T> {
  final _Wrapper<T> _wrapper;

  final T _initialValue;

  /// If true, listeners will be notified if new value not equals to old value
  /// Default true
  final bool notifyOnlyIfChanged;

  Observable._(this._initialValue, this.notifyOnlyIfChanged,
      StreamController<T> controller,
      Stream<T> stream,
      this._wrapper,
      ) : super(controller, stream);

  /// Constructs a [Observable], optionally pass initial value, handlers for
  /// [onListen], [onCancel], flag to handle events [sync] and
  /// flag [notifyOnlyIfChanged] - if true, listeners will be notified
  /// if new value not equals to old value
  ///
  /// See also [BehaviorSubject], and [StreamController.broadcast]
  factory Observable(T initialValue,{
    void Function()? onListen,
    void Function()? onCancel,
    bool sync = false,
    bool notifyOnlyIfChanged = true
  }) {
    // ignore: close_sinks
    final controller = StreamController<T>.broadcast(
      onListen: onListen,
      onCancel: onCancel,
      sync: sync,
    );

    final wrapper = _Wrapper<T>.seeded(initialValue);

    return Observable<T>._(initialValue, notifyOnlyIfChanged,
        controller,
        Rx.defer<T>(_deferStream(wrapper, controller, sync), reusable: true),
        wrapper);
  }


  static Stream<T> Function() _deferStream<T>(
      _Wrapper<T> wrapper, StreamController<T> controller, bool sync) =>
          () {
        final errorAndStackTrace = wrapper.errorAndStackTrace;
        if (errorAndStackTrace != null && !wrapper.isValue) {
          return controller.stream.transform(
            StartWithErrorStreamTransformer(
              errorAndStackTrace.error,
              errorAndStackTrace.stackTrace,
            ),
          );
        }

        final value = wrapper.value;
        if (isNotEmpty(value) && wrapper.isValue) {
          return controller.stream
              .transform(StartWithStreamTransformer(value as T));
        }

        return controller.stream;
      };

  @override
  void onAdd(T event) {
    if (!notifyOnlyIfChanged || event != value) {
      _wrapper.setValue(event);
    }
  }

  @override
  void onAddError(Object error, [StackTrace? stackTrace]) =>
      _wrapper.setError(error, stackTrace);

  @override
  ValueStream<T> get stream => this;

  @override
  bool get hasValue => _initialValue != null && isNotEmpty(_wrapper.value);

  @override
  T get value {
    final value = _wrapper.value;
    if (isNotEmpty(value)) {
      return value as T;
    }
    else {
      return _initialValue;
    }
  }

  T call() {
    return value;
  }

  @override
  T? get valueOrNull => unbox(_wrapper.value);

  /// Set and emit the new value.
  set value(T newValue) => add(newValue);

  @override
  bool get hasError => _wrapper.errorAndStackTrace != null;

  @override
  Object? get errorOrNull => _wrapper.errorAndStackTrace?.error;

  @override
  Object get error {
    final errorAndSt = _wrapper.errorAndStackTrace;
    if (errorAndSt != null) {
      return errorAndSt.error;
    }
    throw ValueStreamError.hasNoError();
  }

  @override
  StackTrace? get stackTrace => _wrapper.errorAndStackTrace?.stackTrace;
}

class _Wrapper<T> {
  bool isValue;
  var value = EMPTY;
  ErrorAndStackTrace? errorAndStackTrace;

  /// Non-seeded constructor
  _Wrapper() : isValue = false;

  _Wrapper.seeded(this.value) : isValue = true;

  void setValue(T event) {
    value = event;
    isValue = true;
  }

  void setError(Object error, StackTrace? stackTrace) {
    errorAndStackTrace = ErrorAndStackTrace(error, stackTrace);
    isValue = false;
  }
}
