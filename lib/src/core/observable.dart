import 'package:flutter/foundation.dart';

import '../i_cancelable.dart';
import '../i_disposable.dart';

part '../experimental/compact_observer/tracking_context.dart';
part 'obs_extensions/obs_num.dart';
part 'obs_extensions/obs_string.dart';
part 'observable_computed.dart';
part 'rx_subscription.dart';

abstract interface class IObservableListenable<T> implements IDisposable {
  /// Custom stream-like listen with custom subscription
  ObservableSubscription listen(void Function(T) listener, {bool fireImmediately = true});
}

abstract interface class IObservable<T> extends IObservableListenable
    implements IDisposable, ValueListenable {
  /// Returns the last emitted value or initial value.
  @override
  T get value;

  /// Custom stream-like listen with custom subscription
  @override
  ObservableSubscription listen(void Function(T) listener, {bool fireImmediately = true});
}

class Observable<T> extends ObservableReadOnly<T> {
  /// Constructs a [Observable], with value setter and getter, pass initial value, handlers for
  /// [onListen], [onCancel], flag to handle events [sync] and
  /// flag [notifyOnlyIfChanged] - if true, listeners will be notified
  /// if new value not equals to old value
  ///
  /// See also [BehaviorSubject], and [StreamController.broadcast]
  Observable(
    super.initialValue, {
    super.notifyOnlyIfChanged,
  });

  /// Set and emit the new value.
  set value(T newValue) => _updateValue(newValue);
}

/// Class for observable value (notifier + current value).
class ObservableReadOnly<T> extends ChangeNotifier implements IObservable<T> {
  /// If true, listeners will be notified if new value not equals to old value
  /// Default true
  bool notifyOnlyIfChanged;

  /// Constructs a [ObservableReadOnly], pass initial value,
  /// flag [notifyOnlyIfChanged] - if true, listeners will be notified
  /// if new value not equals to old value
  ObservableReadOnly(T initialValue, {this.notifyOnlyIfChanged = true}) {
    _value = initialValue;
  }

  late T _value;
  final _customListeners = <void Function(T)>[];

  /// Set and emit the new value.
  void _updateValue(T newValue) {
    /// Experimental start
    if (ObsTrackingContext.current != null) {
      throw Exception('You cannot modify reactive value inside Observer builder');
    }

    /// Experimental end

    if (_value != newValue || !notifyOnlyIfChanged) {
      _value = newValue;
      notifyListeners();
    }
  }

  @override
  T get value {
    ObsTrackingContext.current?._register(this);

    /// Experimental
    return _value;
  }

  @override
  ObservableSubscription listen(void Function(T) listener, {bool fireImmediately = false}) {
    _customListeners.add(listener);
    if (fireImmediately) listener(_value);
    return ObservableSubscription(() => _customListeners.remove(listener));
  }

  @override
  void notifyListeners() {
    for (final listener in List.of(_customListeners)) {
      try {
        listener(_value);
      } catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'rx_observable',
          context: ErrorDescription(
              'while dispatching rx_observable notifications for $runtimeType'),
          informationCollector: () => <DiagnosticsNode>[
            DiagnosticsProperty<ChangeNotifier>(
              'The $runtimeType sending rx_observable notification was',
              this,
              style: DiagnosticsTreeStyle.errorProperty,
            ),
          ],
        ));
      }
    }
    super.notifyListeners(); // this triggers Flutter widgets like Observer, etc.
  }

  @override
  void dispose() {
    _customListeners.clear();
    super.dispose();
  }
}
