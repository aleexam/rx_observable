import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rx_observable/rx_observable.dart';
import 'package:rx_observable/widgets.dart';

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  ExampleScreenState createState() => ExampleScreenState();
}

class ExampleScreenState extends State<ExampleScreen> with RxSubsStateMixin {
  var text = "Hello".obs;
  var text2 = "Mister".obs;
  var counter = 0.obs;

  late IObservable computed;

  @override
  void initState() {
    // Uncomment this to enable experimental features
    // ExperimentalObservableFeatures.useExperimental = true;

    text.listen((v) {
      if (kDebugMode) {
        print("New value is $v");
      }
    });

    /// Computed value example
    computed = [text, text2].compute(() => "${text.v}, ${text2.v}");

    Future.delayed(const Duration(seconds: 5)).whenComplete(() {
      text.value = "GoodBye";
    });

    /// Use widget version of RxSubsMixin to easily handle observable disposal
    /// All registered objects will be disposed automatically on widget dispose()
    regs([text, text2, counter]);

    super.initState();
  }

  void incrementCounter() {
    counter.value++;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("rx_observable Example"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Standard Observers:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Standard observer with single observable
            Observer(text, (v) => Text("Single observable: $v")),

            // Standard observer with computed observable
            Observer(computed, (v) => Text("Single observable: $v")),

            // Extension method to create an observer
            text.observer((v) => Text("Using extension: $v")),

            // Builder version for more control
            Observer.builder(
              observable: text,
              builder: (context, v) {
                return Text("Builder version: $v");
              },
            ),

            // Observing multiple values with Observer2
            Observer2(
              observable: text,
              observable2: text2,
              builder: (context, v1, v2) {
                return Text("Two observables: $v1 $v2");
              },
            ),

            const SizedBox(height: 24),
            Observer(
                counter,
                (count) => Text(
                      "Counter value: $count",
                      style: const TextStyle(fontSize: 16),
                    )),

            // Only use the experimental feature if it's enabled
            // ignore: deprecated_member_use
            if (ExperimentalObservableFeatures.useExperimental)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Experimental features:",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red)),
                    // Observe widget automatically detects and subscribes to observables
                    // ignore: deprecated_member_use
                    Observe(() =>
                        Text("Text: ${text.value} - Count: ${counter.value}")),
                    const SizedBox(height: 8),
                    // Example of manual tracking, when value not used directly in Observe
                    // ignore: deprecated_member_use
                    Observe(() {
                      // Force Observe to track text2 and rebuild on change
                      // ignore: deprecated_member_use
                      counter.observe();
                      return Builder(builder: (context) {
                        return Text(
                          "Manual tracking: ${text.v} | ${counter.value} is here",
                          style: const TextStyle(color: Colors.green),
                        );
                      });
                    }),
                  ],
                ),
              ),

            ElevatedButton(
              onPressed: incrementCounter,
              child: const Text("Increment Counter"),
            ),
          ],
        ),
      ),
    );
  }
}
