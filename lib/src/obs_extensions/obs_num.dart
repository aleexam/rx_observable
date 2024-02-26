part of "../observable.dart";

typedef ObservableDouble = Observable<double>;
typedef ObservableNullableDouble = Observable<double?>;

class ObservableNum extends Observable<num> {
  ObservableNum._(
      super.initialValue,
      super.notifyOnlyIfChanged,
      super.controller,
      super.stream,
      super.wrapper,
      ) : super._();

  factory ObservableNum(num initialValue,{
    void Function()? onListen,
    void Function()? onCancel,
    bool sync = false,
    bool notifyOnlyIfChanged = true
  }) {
    // ignore: close_sinks
    final controller = StreamController<num>.broadcast(
      onListen: onListen,
      onCancel: onCancel,
      sync: sync,
    );

    final wrapper = _Wrapper<num>.seeded(initialValue);

    return ObservableNum._(initialValue, notifyOnlyIfChanged,
        controller,
        Rx.defer<num>(Observable._deferStream(wrapper, controller, sync), reusable: true),
        wrapper);
  }

  num operator +(num other) {
    value += other;
    return value;
  }

  /// Subtraction operator.
  num operator -(num other) {
    value -= other;
    return value;
  }
}

class ObservableNullableNum extends Observable<num?> {
  ObservableNullableNum._(
      super.initialValue,
      super.notifyOnlyIfChanged,
      super.controller,
      super.stream,
      super.wrapper,
      ) : super._();

  factory ObservableNullableNum(num? initialValue,{
    void Function()? onListen,
    void Function()? onCancel,
    bool sync = false,
    bool notifyOnlyIfChanged = true
  }) {
    // ignore: close_sinks
    final controller = StreamController<num?>.broadcast(
      onListen: onListen,
      onCancel: onCancel,
      sync: sync,
    );

    final wrapper = _Wrapper<num?>.seeded(initialValue);

    return ObservableNullableNum._(initialValue, notifyOnlyIfChanged,
        controller,
        Rx.defer<num?>(Observable._deferStream(wrapper, controller, sync), reusable: true),
        wrapper);
  }

  num? operator +(num other) {
    if (value != null) {
      value = value! + other;
      return value;
    }
    return null;
  }

  /// Subtraction operator.
  num? operator -(num other) {
    if (value != null) {
      value = value! - other;
      return value;
    }
    return null;
  }
}

class ObservableInt extends Observable<int> {
  ObservableInt._(
      super.initialValue,
      super.notifyOnlyIfChanged,
      super.controller,
      super.stream,
      super.wrapper,
      ) : super._();

  factory ObservableInt(int initialValue,{
    void Function()? onListen,
    void Function()? onCancel,
    bool sync = false,
    bool notifyOnlyIfChanged = true
  }) {
    // ignore: close_sinks
    final controller = StreamController<int>.broadcast(
      onListen: onListen,
      onCancel: onCancel,
      sync: sync,
    );

    final wrapper = _Wrapper<int>.seeded(initialValue);

    return ObservableInt._(initialValue, notifyOnlyIfChanged,
        controller,
        Rx.defer<int>(Observable._deferStream(wrapper, controller, sync), reusable: true),
        wrapper);
  }

  /// Addition operator.
  ObservableInt operator +(int other) {
    value = value + other;
    return this;
  }

  /// Subtraction operator.
  ObservableInt operator -(int other) {
    value = value - other;
    return this;
  }
}

class ObservableNullableInt extends Observable<int?> {
  ObservableNullableInt._(
      super.initialValue,
      super.notifyOnlyIfChanged,
      super.controller,
      super.stream,
      super.wrapper,
      ) : super._();

  factory ObservableNullableInt(int? initialValue,{
    void Function()? onListen,
    void Function()? onCancel,
    bool sync = false,
    bool notifyOnlyIfChanged = true
  }) {
    // ignore: close_sinks
    final controller = StreamController<int?>.broadcast(
      onListen: onListen,
      onCancel: onCancel,
      sync: sync,
    );

    final wrapper = _Wrapper<int?>.seeded(initialValue);

    return ObservableNullableInt._(initialValue, notifyOnlyIfChanged,
        controller,
        Rx.defer<int?>(Observable._deferStream(wrapper, controller, sync), reusable: true),
        wrapper);
  }

  /// Addition operator.
  ObservableNullableInt operator +(int other) {
    if (value != null) {
      value = value! + other;
    }
    return this;
  }

  /// Subtraction operator.
  ObservableNullableInt operator -(int other) {
    if (value != null) {
      value = value! - other;
    }
    return this;
  }
}