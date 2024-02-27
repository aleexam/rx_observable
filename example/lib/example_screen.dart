import 'package:flutter/material.dart';
import 'package:rx_observable/rx_observable.dart';
import 'package:rx_observable/widgets.dart';

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  ExampleScreenState createState() => ExampleScreenState();
}

class ExampleScreenState extends State<ExampleScreen> {

  var reactiveValue = "Hello".obs;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    reactiveValue.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          /// Use Observer widget directly to update UI with values
          Observer(reactiveValue, (v) => Text(v)),
          /// Use extensions which creates same observer widget
          reactiveValue.observer((v) => Text(v)),
          /// Use big builder version
          Observer.builder(
              observable: reactiveValue,
              builder: (context, v) {
                return Text(v);
              }
          )
        ],
      ),
    );
  }
}