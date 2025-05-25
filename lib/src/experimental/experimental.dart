/// Provides access to experimental reactive programming features.
///
/// These features are in development and may change significantly in future releases.
/// They provide more concise syntax for reactive UI updates but have limitations
/// that you should be aware of before using them in production code.
@Deprecated("Experimental feature, not recommended for production use")
class ExperimentalObservableFeatures {
  /// Controls activation of experimental features.
  ///
  /// When true, enables:
  /// - The `Observe` widget that automatically tracks and subscribes to observable values
  ///
  /// WARNING: Experimental features have limitations, can be unstable and they not well tested
  static bool useExperimental = false;
}
