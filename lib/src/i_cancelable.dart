import 'package:rx_observable/rx_observable.dart';

/// An interface for objects that support cancellation of ongoing operations,
/// such as subscriptions, timers, or async tasks.
/// Used mostly for closing [ObservableSubscription] but can be used with anything else
abstract class ICancelable {
  /// Cancels the operation or releases associated resources.
  void cancel();
}