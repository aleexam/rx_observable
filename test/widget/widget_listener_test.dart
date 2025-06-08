// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rx_observable/rx_observable.dart';
import 'package:rx_observable/widgets.dart';

void main() {
  group('ObservableListener widget', () {
    testWidgets('ObservableListener calls listener when observable changes',
        (WidgetTester tester) async {
      final counter = Observable<int>(0);
      int listenerCallCount = 0;
      int lastValue = -1;

      await tester.pumpWidget(
        MaterialApp(
          home: ObservableListener<int>(
            observable: counter,
            listener: (context, value) {
              listenerCallCount++;
              lastValue = value;
            },
            child: const Text('Child Widget'),
          ),
        ),
      );

      expect(listenerCallCount, 0);
      expect(lastValue, -1);

      counter.value = 7;
      await tester.pump();

      expect(listenerCallCount, 1);
      expect(lastValue, 7);

      counter.value = 7;
      await tester.pump();

      expect(listenerCallCount, 1);

      counter.value = 65;
      await tester.pump();

      expect(listenerCallCount, 2);
      expect(lastValue, 65);
    });

    testWidgets('ObservableListener switches observable correctly',
        (WidgetTester tester) async {
      final observableA = Observable<int>(0);
      final observableB = ObservableAsync<int>(100);
      int lastSeen = -1;

      late StateSetter setState;
      IObservableListenable<int> current = observableA;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (ctx, setStateFunc) {
              setState = setStateFunc;
              return ObservableListener<int>(
                observable: current,
                listener: (context, value) {
                  lastSeen = value;
                },
                child: const Placeholder(),
              );
            },
          ),
        ),
      );

      observableA.value = 1;
      await tester.pump();
      expect(lastSeen, 1);

      setState(() {
        current = observableB;
      });
      await tester.pump();

      observableB.value = 200;
      await tester.pump();
      expect(lastSeen, 200);

      // A больше не должен влиять
      observableA.value = 999;
      await tester.pump();
      expect(lastSeen, 200); // Не изменился
    });

    testWidgets('ObservableListener unsubscribes when disposed',
        (WidgetTester tester) async {
      final counter = Observable<int>(0);
      int listenerCallCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: ObservableListener<int>(
            observable: counter,
            listener: (context, value) {
              listenerCallCount++;
            },
            child: const Text('Child Widget'),
          ),
        ),
      );

      expect(counter.hasListeners, true);

      await tester.pumpWidget(Container());

      expect(counter.hasListeners, false);

      counter.value = 7;
      await tester.pump();

      expect(listenerCallCount, 0);
    });

    testWidgets('ObservableListener renders child correctly',
        (WidgetTester tester) async {
      final counter = Observable<int>(0);

      await tester.pumpWidget(
        MaterialApp(
          home: ObservableListener<int>(
            observable: counter,
            listener: (context, value) {},
            child: const Text('Child Widget'),
          ),
        ),
      );

      expect(find.text('Child Widget'), findsOneWidget);

      counter.value = 7;
      await tester.pump();

      expect(find.text('Child Widget'), findsOneWidget);
    });

    testWidgets('ObservableListener works with async observable',
        (WidgetTester tester) async {
      final counter = ObservableAsync<int>(0);
      int lastValue = -1;

      await tester.pumpWidget(
        MaterialApp(
          home: ObservableListener<int>(
            observable: counter,
            listener: (context, value) {
              lastValue = value;
            },
            child: const Text('Child Widget'),
          ),
        ),
      );

      counter.value = 7;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 10)); // Wait for async

      expect(lastValue, 7);

      counter.dispose();
    });
  });

  group('ObservableListener edge cases', () {
    testWidgets('ObservableListener works with null values',
        (WidgetTester tester) async {
      final nullableObs = Observable<String?>(null);
      String? lastValue = "not set";

      await tester.pumpWidget(
        MaterialApp(
          home: ObservableListener<String?>(
            observable: nullableObs,
            listener: (context, value) {
              lastValue = value;
            },
            child: const Text('Child Widget'),
          ),
        ),
      );

      expect(lastValue, "not set");

      nullableObs.value = null;
      await tester.pump();
      expect(lastValue, "not set");

      nullableObs.value = "Hello";
      await tester.pump();
      expect(lastValue, "Hello");

      nullableObs.value = null;
      await tester.pump();
      expect(lastValue, null);
    });

    testWidgets(
        'ObservableListener handles notifyOnlyIfChanged=false correctly',
        (WidgetTester tester) async {
      final counter = Observable<int>(0, notifyOnlyIfChanged: false);
      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: ObservableListener<int>(
            observable: counter,
            listener: (context, value) {
              callCount++;
            },
            child: const Text('Child Widget'),
          ),
        ),
      );

      counter.value = 0;
      await tester.pump();
      expect(callCount, 1);

      counter.value = 0;
      await tester.pump();
      expect(callCount, 2);
    });

    testWidgets('ObservableListener handles notify() calls',
        (WidgetTester tester) async {
      final counter = Observable<int>(0);
      int callCount = 0;
      int lastValue = -1;

      await tester.pumpWidget(
        MaterialApp(
          home: ObservableListener<int>(
            observable: counter,
            listener: (context, value) {
              callCount++;
              lastValue = value;
            },
            child: const Text('Child Widget'),
          ),
        ),
      );

      counter.notify();
      await tester.pump();

      expect(callCount, 1);
      expect(lastValue, 0);
    });

    testWidgets('ObservableListener handles rapid changes',
        (WidgetTester tester) async {
      final counter = Observable<int>(0);
      List<int> receivedValues = [];

      await tester.pumpWidget(
        MaterialApp(
          home: ObservableListener<int>(
            observable: counter,
            listener: (context, value) {
              receivedValues.add(value);
            },
            child: const Text('Child Widget'),
          ),
        ),
      );

      for (int i = 1; i <= 5; i++) {
        counter.value = i;
        await tester.pump(Duration.zero);
      }

      expect(receivedValues, [1, 2, 3, 4, 5]);
    });
  });
}
