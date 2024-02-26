part of "../observable.dart";

/// Observable class for `String` Type.
class ObservableString extends Observable<String> implements Comparable<String>, Pattern {

  ObservableString(super.initialValue);

  @override
  Iterable<Match> allMatches(String string, [int start = 0]) {
    return value.allMatches(string, start);
  }

  @override
  Match? matchAsPrefix(String string, [int start = 0]) {
    return value.matchAsPrefix(string, start);
  }

  @override
  int compareTo(String other) {
    return value.compareTo(other);
  }
}

/// Observable class for `String` Type.
class ObservableNullableString extends Observable<String?> implements Comparable<String>, Pattern {
  ObservableNullableString(super.initialValue);

  @override
  Iterable<Match> allMatches(String string, [int start = 0]) {
    return value!.allMatches(string, start);
  }

  @override
  Match? matchAsPrefix(String string, [int start = 0]) {
    return value!.matchAsPrefix(string, start);
  }

  @override
  int compareTo(String other) {
    return value!.compareTo(other);
  }
}
