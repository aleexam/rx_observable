part of "../observable.dart";

/// Observable class for `String` Type.
class ObservableString extends Observable<String> implements Comparable<String>, Pattern {

  ObservableString._(
      super.initialValue,
      super.notifyOnlyIfChanged,
      super.controller,
      super.stream,
      super.wrapper,
      ) : super._();

  factory ObservableString(String initialValue,{
    void Function()? onListen,
    void Function()? onCancel,
    bool sync = false,
    bool notifyOnlyIfChanged = true
  }) {
    // ignore: close_sinks
    final controller = StreamController<String>.broadcast(
      onListen: onListen,
      onCancel: onCancel,
      sync: sync,
    );

    final wrapper = _Wrapper<String>.seeded(initialValue);

    return ObservableString._(initialValue, notifyOnlyIfChanged,
        controller,
        Rx.defer<String>(Observable._deferStream(wrapper, controller, sync), reusable: true),
        wrapper);
  }

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
  ObservableNullableString._(
      super.initialValue,
      super.notifyOnlyIfChanged,
      super.controller,
      super.stream,
      super.wrapper,
      ) : super._();

  factory ObservableNullableString(String? initialValue,{
    void Function()? onListen,
    void Function()? onCancel,
    bool sync = false,
    bool notifyOnlyIfChanged = true
  }) {
    // ignore: close_sinks
    final controller = StreamController<String?>.broadcast(
      onListen: onListen,
      onCancel: onCancel,
      sync: sync,
    );

    final wrapper = _Wrapper<String?>.seeded(initialValue);

    return ObservableNullableString._(initialValue, notifyOnlyIfChanged,
        controller,
        Rx.defer<String?>(Observable._deferStream(wrapper, controller, sync), reusable: true),
        wrapper);
  }

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
