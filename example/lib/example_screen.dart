import 'package:flutter/material.dart';
import 'package:rx_observable/rx_observable.dart';
import 'package:rx_observable/widgets.dart';

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  ExampleScreenState createState() => ExampleScreenState();
}

class ExampleScreenState extends State<ExampleScreen> {

  var reactiveValue = Observable(1);
  var reactiveValue2 = "Hello".obs;

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
          Observer(
            observable: reactiveValue,
            builder: (context, value) {
              return Text(value.toString());
            }
          ),
          /// Use extensions which creates same observer widget
          reactiveValue2.observer((context, value) => Text(value))
        ],
      ),
    );
  }
}