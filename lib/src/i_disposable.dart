import 'package:rx_observable/src/core/observable.dart';

/// An interface for objects that need to release resources when no longer needed,
/// such as closing streams, controllers, or unregistering listeners.
/// Used mostly for closing [IObservable] but can be used with anything else
abstract class IDisposable {
  /// Releases any held resources and performs cleanup.
  void dispose();
}