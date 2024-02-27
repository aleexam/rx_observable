part of "../observable.dart";

class ObservableNum extends Observable<num> {
  ObservableNum(super.initialValue);

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
  ObservableNullableNum(super.initialValue);

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
  ObservableInt(super.initialValue);

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
  ObservableNullableInt(super.initialValue);

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