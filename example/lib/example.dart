library example;

import 'package:flutter/foundation.dart';
import 'package:rx_observable/rx_observable.dart';

void main() {
  var z = Observable(0);
  z.value = 2;
  z.value += 1;

  if (kDebugMode) {
    print(z);
  }
}