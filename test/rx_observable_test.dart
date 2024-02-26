import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rx_observable/rx_observable.dart';

void main() {
  test('adds one to input values', () {
    var z = Observable(0);
    var z2 = Observable(0);
    z.value = 2;
    z.value += 1;

    if (kDebugMode) {
      print(z);
    }

    var computed = ObservableComputed(() {
      print(z()+z2());
    }, [z, z2]);

    computed.listen((event) {
      print(event);
    });

  });
}
