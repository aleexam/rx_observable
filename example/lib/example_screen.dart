import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rx_observable/rx_observable.dart';
import 'package:rx_observable/widgets.dart';

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  ExampleScreenState createState() => ExampleScreenState();
}

class ExampleScreenState extends State<ExampleScreen> {
  var text = "Hello".obs;
  var text2 = "Mister".obs;

  @override
  void initState() {
    text.listen((v) {
      if (kDebugMode) {
        print("New value is $v");
      }
    });

    Future.delayed(const Duration(seconds: 3)).whenComplete(() {
      text.value = "GoodBye";
    });

    super.initState();
  }

  @override
  void dispose() {
    text.dispose();
    text2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          /// Use Observer widget directly to update UI with values
          Observer(text, (v) => Text(v)),

          /// Use extensions which creates same observer widget
          text.observer((v) => Text(v)),

          /// Use big builder version
          Observer.builder(
              observable: text,
              builder: (context, v) {
                return Text(v);
              }),

          /// Listen 2 or 3 observables
          Observer2(
              observable: text,
              observable2: text2,
              builder: (context, v1, v2) {
                return Text("$v1 $v2");
              })
        ],
      ),
    );
  }
}
