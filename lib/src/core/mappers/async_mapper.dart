import 'dart:async';

import '../observable.dart';

/// Proxy class for mapping Observable to another transformed one, async version
class MappedObservableAsyncReadOnly<T, M>
    implements ObservableAsyncReadOnly<M> {
  final ObservableAsyncReadOnly<T> _source;
  final StreamController<T> _sourceController;
  final M Function(T) _transform;

  MappedObservableAsyncReadOnly(
    this._source,
    this._sourceController,
    this._transform, {
    this.alwaysNotify = false,
  }) {
    _lastValue = _transform(_source.value);
  }

  @override
  bool alwaysNotify;

  @override
  M get value {
    try {
      var val = _transform(_source.value);
      _lastValue = val;
      return val;
    } catch (e, s) {
      if (_lastValue != null) {
        _sourceController.addError(e, s);
        return _lastValue!;
      } else {
        rethrow;
      }
    }
  }

  @override
  M get v => value;

  M? _lastValue;
  bool _isClosed = false;

  bool _shouldNotify(M value) {
    if ((!alwaysNotify && _lastValue == value) || _isClosed) {
      return false;
    }
    _lastValue = value;
    return true;
  }

  @override
  ObservableStreamSubscription<M> listen(
    FutureOr<void> Function(M) onData, {
    bool preFire = false,
  }) {
    if (preFire) {
      onData(value);
    }
    var subscription = _source.stream
        .map(_transform)
        .where(_shouldNotify)
        .listen((v) {
          onData(v);
        },
          onError: (e, s) {
            // ignore: invalid_use_of_visible_for_testing_member
            reportObservableFlutterError(e, s, this);
          },
        );
    return ObservableStreamSubscription<M>(subscription);
  }

  @override
  StreamSubscription<M> listenAsStream(
    void Function(M)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _source.stream
        .map(_transform)
        .where(_shouldNotify)
        .listen(
          onData,
          onError: onError,
          onDone: onDone,
          cancelOnError: cancelOnError,
        );
  }

  @override
  ObservableAsyncReadOnly<R> map<R>(
    R Function(M value) newTransform, {
    bool? alwaysNotify,
  }) {
    return _source.map(
      (value) => newTransform(_transform(value)),
      alwaysNotify: alwaysNotify ?? this.alwaysNotify,
    );
  }

  @override
  FutureOr<void> Function()? onCancel;

  @override
  void Function()? onListen;

  @override
  void Function()? onPause;

  @override
  void Function()? onResume;

  @override
  Future get done => _source.done;

  @override
  bool get hasListener => _source.hasListener;

  @override
  bool get isClosed => _source.isClosed;

  @override
  bool get isPaused => _source.isPaused;

  @override
  Stream<M> get stream => _source.stream.map(_transform);

  @override
  Future<void> dispose() async {
    _isClosed = true;
  }

  @override
  Future close() async {
    return dispose();
  }
}
