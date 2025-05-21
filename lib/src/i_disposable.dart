import 'package:rx_observable/src/core/observable.dart';

/// An interface for objects that need to release resources when no longer needed,
/// such as closing streams, controllers, or unregistering listeners.
/// Used mostly for closing [IObservable] but can be used with anything else
abstract class IDisposable {
  /// Releases any held resources and performs cleanup.
  void dispose();
}

/// An interface for objects that support cancellation of ongoing operations,
/// such as subscriptions, timers, or async tasks.
/// Used mostly for closing [ObservableSubscription] but can be used with anything else
abstract class ICancelable {
  /// Cancels the operation or releases associated resources.
  void cancel();
}

/// Wrap any dispose function of incompatible types to use in [RxSubsMixin] register methods
/// For auto-dispose
/// Example: regDisposable(DisposableAdapter(() => someObject.dispose());
/// In RxSubsMixin dispose method, () => someObject.dispose() will be called
class DisposableAdapter implements IDisposable, ICancelable {

  final void Function() disposeCallback;

  DisposableAdapter(this.disposeCallback);

  @override
  void dispose() {
    disposeCallback();
  }

  @override
  void cancel() {
    disposeCallback();
  }

}