library example;

import 'package:rx_observable/rx_observable.dart';

void main() {
  var z = Observable(0);
  z.value = 2;
  z.value += 1;

  var sz = 2.obs();
}