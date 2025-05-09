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
  var test6 = ObservableReadOnly(25);

  /// You can only read this value

  test1.value;

  test1.dispose();
  test2.dispose();
  test3.dispose();
  test4.dispose();
  test5.dispose();
  test6.dispose();

  /// Actually no need to dispose, if no listeners attached.
  /// Observable acts just like ChangeNotifier

  runApp(const ExampleApp());
}

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  var test1 = Observable(25);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rx Observable Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      /// Listen observable without UI updating
      /// Also see ObservableConsumer widget to get both
      home: ObservableListener(
          observable: test1,
          listener: (v, context) {
            if (kDebugMode) {
              print(v);
            }
          },

          /// See other examples on [ExampleScreen]
          child: const ExampleScreen()),
    );
  }
}
