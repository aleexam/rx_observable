abstract class ObservableStream<T> implements Stream<T> {
  /// Returns last emitted error, failing if there is no error.
  /// See [hasError] to determine whether [error] has already been set.
  ///
  /// Throws [ValueStreamError] if this Stream has no error.
  ///
  /// See also [errorOrNull].
  Object get error;

  /// Returns the last emitted error, or `null` if error events haven't yet been emitted.
  Object? get errorOrNull;

  /// Returns `true` when [error] is available,
  /// meaning this Stream has emitted at least one error.
  bool get hasError;

  /// Returns [StackTrace] of the last emitted error.
  ///
  /// If error events haven't yet been emitted,
  /// or the last emitted error didn't have a stack trace,
  /// the returned value is `null`.
  StackTrace? get stackTrace;
}