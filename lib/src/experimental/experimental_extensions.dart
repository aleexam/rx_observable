import '../core/observable.dart';

extension ListToUnmodifiable<T> on IObservable<List<T>> {
  IObservable<List<T>> toUnmodifiable() =>
      map((list) => List<T>.unmodifiable(list));
}

extension MapToUnmodifiable<T, T2> on IObservable<Map<T, T2>> {
  IObservable<Map<T, T2>> toUnmodifiable() =>
      map((list) => Map<T, T2>.unmodifiable(list));
}

extension SetToUnmodifiable<T> on IObservable<Set<T>> {
  IObservable<Set<T>> toUnmodifiable() =>
      map((list) => Set<T>.unmodifiable(list));
}
