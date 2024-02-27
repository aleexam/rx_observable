import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rx_observable/rx_observable.dart';
import 'package:rx_observable/widgets.dart';

import 'example_screen.dart';

void main() {

  // All constructors gives the same result
  var test1 = Observable(25);
  var test2 = Observable<int>(25);
  var test3 = Obs(25);
  var test4 = 25.obs;
  var test5 = ObservableInt(25);

  test1.listen((v) {
    if (kDebugMode) { print(v); }
  });

  /// Listen observable without UI updating
  /// Also see ObservableConsumer widget to get both
  var widgetListener = ObservableListener(
    observable: test1,
    listener: (v, context) {
      if (kDebugMode) { print(v); }
    },
    child: const SizedBox(),
  );


  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rx Observable Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ExampleScreen(),
    );
  }
}