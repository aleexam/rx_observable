import 'package:flutter/foundation.dart';

import '../observable.dart';

/// Proxy class for mapping Observable to another transformed one, sync version
class MappedObservableReadOnly<T, M>
    implements ObservableReadOnly<M>, ChangeNotifier {
  final ObservableReadOnly<T> _source;
  final M Function(T) _transform;
  final Map<int, VoidCallback> _listeners = {};

  MappedObservableReadOnly(
    this._source,
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
        // ignore: invalid_use_of_visible_for_testing_member
        reportObservableFlutterError(e, s, this);
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

  @override
  ObservableSubscription<M> listen(
    void Function(M) listener, {
    bool preFire = false,
  }) {
    assert(_debugAssertNotDisposed());
    _lastValue = value;
    void wrapper() {
      if ((!alwaysNotify && _lastValue == value) || _isClosed) return;
      _lastValue = value;
      listener(value);
    }

    _source.addListener(wrapper);
    if (preFire) listener(value);
    return ObservableSubscription<M>(() => _source.removeListener(wrapper));
  }

  @override
  ObservableReadOnly<M2> map<M2>(
    M2 Function(M value) transform, {
    bool? alwaysNotify,
  }) {
    assert(_debugAssertNotDisposed());
    return _source.map(
      (value) => transform(_transform(value)),
      alwaysNotify: alwaysNotify ?? this.alwaysNotify,
    );
  }

  @override
  void notify() {
    assert(_debugAssertNotDisposed());
    _source.notify();
  }

  @override
  void addListener(VoidCallback listener) {
    assert(_debugAssertNotDisposed());
    _lastValue = value;
    void wrapper() {
      if ((!alwaysNotify && _lastValue == value) || _isClosed) return;
      _lastValue = value;
      listener();
    }

    _listeners[listener.hashCode] = wrapper;
    _source.addListener(wrapper);
  }

  @override
  bool get hasListeners => _source.hasListeners;

  @override
  void notifyListeners() {
    _source.notifyListeners();
  }

  @override
  void removeListener(VoidCallback listener) {
    assert(_debugAssertNotDisposed());
    var wrapper = _listeners[listener.hashCode];
    if (wrapper != null) _source.removeListener(wrapper);
  }

  @override
  void dispose() {
    _isClosed = true;
  }

  bool _debugAssertNotDisposed() {
    assert(() {
      if (_isClosed) {
        throw FlutterError(
          'A $runtimeType was used after being disposed.\n'
          'Once you have called dispose() on a $runtimeType, it '
          'can no longer be used.',
        );
      }
      return true;
    }());
    return true;
  }
}
