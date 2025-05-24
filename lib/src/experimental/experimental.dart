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
  /// WARNING: Experimental features have several limitations:
  /// - They may cause unexpected behavior
  /// - Nested contexts (like Builders) will not be tracked
  /// - Modifying observable values inside an Observe build method will cause infinite loops
  /// - Performance may be worse than using the standard Observer pattern
  static bool useExperimental = false;
}
