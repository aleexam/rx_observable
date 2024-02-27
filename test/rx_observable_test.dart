import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rx_observable/rx_observable.dart';

void main() {
  test('adds one to input values', () async {
    var var1 = Observable(4);
    var var2 = 1.obsReadOnly;
    var test = Observable<int?>(null);

    if (kDebugMode) {
      print("0: ${var1()}");
    }

    var2.add(3);

    var1.listen((value) {
      print("1: ${var1()}");
    });

    await Future.delayed(const Duration(milliseconds: 1));
    var1.value = 2;
    await Future.delayed(const Duration(milliseconds: 1));
    var1.value += 1;

    var computed = ObservableComputed<int>([var1, var2], () => var1()+var2());
    /*var computed = (() => var1() + var2() ).computed([var1, var2]);
    var computed = () {
      return var1() + var2();
    }.computed([var1, var2]);*/

    computed.listen((event) {
      print("2: ${event}");
    });

    await Future.delayed(const Duration(milliseconds: 1));

    var1.value += 1;

    var1.close();
    var2.close();
    test.close();

  });
}
