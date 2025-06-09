// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rx_observable/rx_observable.dart';
import 'package:rx_observable/widgets.dart';

void main() {
  group('Observer widget', () {
    testWidgets('Initial value is rendered correctly', (tester) async {
      final observable = Observable<int>(98);

      await tester.pumpWidget(
        MaterialApp(
          home: Observer<int>(
            observable,
            (val) => Text('$val', textDirection: TextDirection.ltr),
          ),
        ),
      );

      expect(find.text('98'), findsOneWidget);
    });

    testWidgets('Widget rebuilds on observable change', (tester) async {
      final observable = Observable<String>('initial');

      await tester.pumpWidget(
        MaterialApp(
          home: Observer<String>(
            observable,
            (val) => Text(val, textDirection: TextDirection.ltr),
          ),
        ),
      );

      expect(find.text('initial'), findsOneWidget);

      observable.value = 'updated';
      await tester.pump();

      expect(find.text('updated'), findsOneWidget);
    });

    testWidgets('Observer rebuilds only when necessary',
        (WidgetTester tester) async {
      final counter = Observable<int>(0, alwaysNotify: false);

      await tester.pumpWidget(
        MaterialApp(
          home: Observer(counter, (value) => Text('Count: $value')),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);

      counter.value = 0;
      await tester.pump();

      expect(find.text('Count: 0'), findsOneWidget);

      counter.value = 1;
      await tester.pump();

      expect(find.text('Count: 1'), findsOneWidget);
    });

    testWidgets('Handles change of observable instance', (tester) async {
      final observable1 = Observable<int>(10);
      final observable2 = Observable<int>(20);

      Widget build(Observable<int> obs) {
        return MaterialApp(
          home: StatefulBuilder(
            builder: (ctx, setState) => Column(
              children: [
                Observer<int>(
                  obs,
                  (val) => Text('$val', textDirection: TextDirection.ltr),
                ),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Force rebuild'),
                ),
              ],
            ),
          ),
        );
      }

      await tester.pumpWidget(build(observable1));
      expect(find.text('10'), findsOneWidget);

      // Update widget with new observable
      await tester.pumpWidget(build(observable2));
      await tester.pump();

      expect(find.text('20'), findsOneWidget);

      observable2.value = 25;
      await tester.pump();

      expect(find.text('25'), findsOneWidget);
    });

    testWidgets('Observer.select rebuilds only on selected field change',
        (tester) async {
      final person = Observable(Person('Alice', 30));

      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Observer.select<Person, String>(
            observable: person,
            selector: (p) => p.name,
            builder: (context, name) {
              buildCount++;
              return Column(
                children: [
                  Text(name),
                  Text(person.v.age.toString()),
                ],
              );
            },
          ),
        ),
      );

      expect(find.text('Alice'), findsOneWidget);
      expect(buildCount, 1);

      person.value = person.value = Person('Alice', 35);
      await tester.pump();
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      expect(buildCount, 1);

      person.value = person.value = Person('Bob', 38);
      await tester.pump();
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('38'), findsOneWidget);
      expect(buildCount, 2);
    });

    testWidgets('Observer.select reacts to new observable or selector',
        (tester) async {
      final person1 = Observable(Person('Alice', 30));
      final person2 = Observable(Person('Bob', 25));

      final widget = StatefulBuilder(
        builder: (context, setState) {
          return MaterialApp(
            home: Builder(
              builder: (context) {
                return Column(
                  children: [
                    Observer.select<Person, String>(
                      key: const ValueKey('observer'),
                      observable: person1,
                      selector: (p) => p.name,
                      builder: (_, name) =>
                          Text('Name: $name', textDirection: TextDirection.ltr),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          // Rebuild with new observable and selector
                        });
                      },
                      child: const Text('Swap'),
                    )
                  ],
                );
              },
            ),
          );
        },
      );

      await tester.pumpWidget(widget);
      expect(find.text('Name: Alice'), findsOneWidget);

      person1.value = person1.value = Person('Changed', 30);
      await tester.pump();
      expect(find.text('Name: Changed'), findsOneWidget);

      // Replace widget with different observable + selector
      await tester.pumpWidget(
        MaterialApp(
          home: Observer.select<Person, String>(
            observable: person2,
            selector: (p) => '${p.name}-${p.age}',
            builder: (_, value) =>
                Text('Changed: $value', textDirection: TextDirection.ltr),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Changed: Bob-25'), findsOneWidget);
    });

    testWidgets('Observer rebuilds only when necessary async',
        (WidgetTester tester) async {
      final counter = ObservableAsync<int>(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Observer(counter, (value) => Text('Count: $value')),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);

      counter.value = 0;
      await tester.pump();
      await tester.pump();

      expect(find.text('Count: 0'), findsOneWidget);

      counter.value = 1;
      await tester.pump();
      await tester.pump();

      expect(find.text('Count: 1'), findsOneWidget);
    });

    testWidgets('Observer unsubscribes when disposed',
        (WidgetTester tester) async {
      final counter = Observable<int>(0);
      final key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Observer(counter, (value) => Text('Count: $value', key: key)),
        ),
      );

      expect(counter.hasListeners, true);
      await tester.pumpWidget(Container());

      expect(counter.hasListeners, false);
    });
  });

  group('Other', () {
    testWidgets('Observer works with null values', (WidgetTester tester) async {
      final nullableObs = Observable<String?>(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Observer<String?>(
              nullableObs, (value) => Text('Value: ${value ?? "null"}')),
        ),
      );

      expect(find.text('Value: null'), findsOneWidget);

      nullableObs.value = 'Not null anymore';
      await tester.pump();

      expect(find.text('Value: Not null anymore'), findsOneWidget);

      nullableObs.value = null;
      await tester.pump();

      expect(find.text('Value: null'), findsOneWidget);
    });

    testWidgets('Observer handles rapid observable changes',
        (WidgetTester tester) async {
      final counter = ObservableAsync<int>(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Observer<int>(counter, (value) => Text('Count: $value')),
        ),
      );

      for (int i = 1; i <= 5; i++) {
        counter.value = i;
      }

      await tester.pump();
      expect(find.text('Count: 5'), findsOneWidget);
    });
  });

  group('Observer2 widget', () {
    testWidgets('Observer2 rebuilds when either observable changes',
        (WidgetTester tester) async {
      final counter = Observable<int>(0);
      final name = ObservableAsync<String>('Test');

      await tester.pumpWidget(
        MaterialApp(
          home: Observer2(
            observable: counter,
            observable2: name,
            builder: (context, count, userName) => Text('$userName: $count'),
          ),
        ),
      );

      expect(find.text('Test: 0'), findsOneWidget);

      counter.value = 1;
      await tester.pump();
      expect(find.text('Test: 1'), findsOneWidget);

      name.value = 'User';
      await tester.pump();
      await tester.pump();
      expect(find.text('User: 1'), findsOneWidget);
    });

    testWidgets('Observer2 unsubscribes from both observables when disposed',
        (WidgetTester tester) async {
      final counter = Observable<int>(0);
      final name = Observable<String>('Test');

      await tester.pumpWidget(
        MaterialApp(
          home: Observer2(
            observable: counter,
            observable2: name,
            builder: (context, count, userName) => Text('$userName: $count'),
          ),
        ),
      );

      expect(counter.hasListeners, true);
      expect(name.hasListeners, true);

      await tester.pumpWidget(Container());

      expect(counter.hasListeners, false);
      expect(name.hasListeners, false);
    });
  });

  group('Observer3 widget', () {
    testWidgets('Observer3 rebuilds when any of the three observables change',
        (WidgetTester tester) async {
      final counter = Observable<int>(0);
      final name = ObservableAsync<String>('Test');
      final isActive = ObservableAsync<bool>(true);

      await tester.pumpWidget(
        MaterialApp(
          home: Observer3(
            observable: counter,
            observable2: name,
            observable3: isActive,
            builder: (context, count, userName, active) => Text(
                '$userName: $count (${active == true ? "active" : "inactive"})'),
          ),
        ),
      );

      expect(find.text('Test: 0 (active)'), findsOneWidget);

      counter.value = 4;
      await tester.pump();
      expect(find.text('Test: 4 (active)'), findsOneWidget);

      name.value = 'User';
      await tester.pump();
      await tester.pump();
      expect(find.text('User: 4 (active)'), findsOneWidget);

      isActive.value = false;
      await tester.pump();
      await tester.pump();
      expect(find.text('User: 4 (inactive)'), findsOneWidget);
    });

    testWidgets('Observer3 unsubscribes from all observables when disposed',
        (WidgetTester tester) async {
      final counter = Observable<int>(0);
      final name = Observable<String>('Test');
      final isActive = Observable<bool>(true);

      await tester.pumpWidget(
        MaterialApp(
          home: Observer3(
            observable: counter,
            observable2: name,
            observable3: isActive,
            builder: (context, count, userName, active) => Text(
                '$userName: $count (${active == true ? "active" : "inactive"})'),
          ),
        ),
      );

      expect(counter.hasListeners, true);
      expect(name.hasListeners, true);
      expect(isActive.hasListeners, true);

      await tester.pumpWidget(Container());

      expect(counter.hasListeners, false);
      expect(name.hasListeners, false);
      expect(isActive.hasListeners, false);
    });
  });

  group('MultiObserver widget', () {
    testWidgets(
        'MultiObserver rebuilds when any observable in the list changes',
        (WidgetTester tester) async {
      final counter1 = Observable<int>(0);
      final counter2 = ObservableAsync<int>(10);
      final counter3 =
          [counter1, counter2].compute(() => counter2.v + counter1.v);

      final observables = [counter1, counter2, counter3];

      await tester.pumpWidget(
        MaterialApp(
          home: MultiObserver(
            observables: observables,
            builder: (context) =>
                Text('${counter1.value}, ${counter2.value}, ${counter3.value}'),
          ),
        ),
      );

      expect(find.text('0, 10, 10'), findsOneWidget);

      counter1.value = 1;
      await tester.pump();
      expect(find.text('1, 10, 11'), findsOneWidget);

      counter2.value = 20;
      await tester.pump();
      await tester.pump();
      expect(find.text('1, 20, 21'), findsOneWidget);

      counter1.value = 20;
      await tester.pump();
      expect(find.text('20, 20, 40'), findsOneWidget);
    });

    testWidgets('MultiObserver disposes properly', (WidgetTester tester) async {
      final counter1 = Observable<int>(0);
      final counter2 = Observable<int>(10);

      final observables = [counter1, counter2];

      await tester.pumpWidget(
        MaterialApp(
          home: MultiObserver(
            observables: observables,
            builder: (context) => Text('${counter1.value}, ${counter2.value}'),
          ),
        ),
      );

      expect(counter1.hasListeners, true);
      expect(counter2.hasListeners, true);

      await tester.pumpWidget(Container());

      expect(counter1.hasListeners, false);
      expect(counter2.hasListeners, false);
    });
  });
}

class Person {
  final String name;
  final int age;

  Person(this.name, this.age);
}
