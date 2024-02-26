import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rx_observable/rx_observable.dart';

void main() {
  test('adds one to input values', () async {
    var z = Observable(0);
    var z2 = Observable(9);
    z.value = 2;
    z.value += 1;

    if (kDebugMode) {
      print(z());
    }

    var computed = ObservableComputed(() {
      print(z()+z2());
    }, [z, z2]);

    z.listen((event) {
      print(event);
    });

    z.value += 1;

    await Future.delayed(const Duration(seconds: 5));

  });
}
