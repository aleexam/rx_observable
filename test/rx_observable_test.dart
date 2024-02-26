import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rx_observable/rx_observable.dart';

void main() {
  test('adds one to input values', () async {
    var var1 = Observable(0);
    var var2 = Observable(9);
    var1.value = 2;
    var1.value += 1;

    if (kDebugMode) {
      print(var1());
    }

    var computed = ObservableComputed<int>([var1, var2], () => var1()+var2());
    /*var computed = (() => var1() + var2() ).computed([var1, var2]);
    var computed = () {
      return var1() + var2();
    }.computed([var1, var2]);*/

    var1.listen((event) {
      print(event);
    });

    var1.value += 1;

    await Future.delayed(const Duration(seconds: 5));

    var1.close();
    var2.close();

  });
}
