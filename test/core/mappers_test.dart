import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rx_observable/rx_observable.dart';

/// ✅
void main() {
  group('SyncMapper Tests', () {
    test(
        'select creates mapped observable and updates when selected value changes',
        () {
      final person = Observable(Person('Alice', 30));
      final nameObs = person.select((p) => p.name);

      final observedValues = <String>[];

      final sub = nameObs.listen((name) {
        observedValues.add(name);
      }, preFire: true);

      // Initial value should be fired
      expect(observedValues, ['Alice']);

      // Change unrelated field — no notification
      person.value = person.value.copyWith(age: 31);
      expect(observedValues, ['Alice']); // no change

      // Change tracked field — should notify
      person.value = person.value.copyWith(name: 'Bob');
      expect(observedValues, ['Alice', 'Bob']);

      sub.cancel();
    });

    test(
        '(Async) select creates mapped observable and updates when selected value changes',
        () async {
      final person = ObservableAsync(Person('Alice', 30));
      final nameObs = person.select((p) => p.name);

      final observedValues = <String>[];

      final sub = nameObs.listen((name) {
        observedValues.add(name);
      }, preFire: true);

      // Initial value should be fired
      expect(observedValues, ['Alice']);

      // Change unrelated field — no notification
      person.value = person.value.copyWith(age: 31);
      expect(observedValues, ['Alice']); // no change

      // Change tracked field — should notify
      person.value = person.value.copyWith(name: 'Bob');
      await Future.delayed(Duration.zero);
      expect(observedValues, ['Alice', 'Bob']);

      sub.cancel();
    });

    test(
        'select notifies even if same value, when alwaysNotify is true',
        () {
      final person =
          Observable(Person('Alice', 30), alwaysNotify: true);
      final nameObs = person.select((p) => p.name, alwaysNotify: true);

      int notifyCount = 0;

      final sub = nameObs.listen((_) {
        notifyCount++;
      });

      person.value = person.value.copyWith(name: 'Alice');
      expect(notifyCount, 1);
      sub.cancel();
    });

    test(
        '(Async) select notifies even if same value, when alwaysNotify is true',
        () async {
      final person =
          ObservableAsync(Person('Alice', 30), alwaysNotify: true);
      final nameObs = person.select((p) => p.name, alwaysNotify: true);

      int notifyCount = 0;

      final sub = nameObs.listen((_) {
        notifyCount++;
      });

      person.value = person.value.copyWith(name: 'Alice');
      await Future.delayed(Duration.zero);
      expect(notifyCount, 1);
      sub.cancel();
    });

    test('map with exception handling', () async {
      final source = ObservableAsync<int>(10);
      final mapped = source.map<String>((value) {
        if (value < 0) {
          throw Exception('Negative value');
        }
        return value.toString();
      });

      expect(mapped.value, '10');

      bool errorCaught = false;
      mapped.stream.listen(
        (_) {},
        onError: (error) {
          errorCaught = true;
          expect(error, isA<Exception>());
          expect(error.toString(), 'Exception: Negative value');
        },
      );

      source.value = -5;
      await Future.delayed(Duration.zero);

      expect(errorCaught, true);
      expect(mapped.value, '10');
    });

    test('map chaining with multiple async transformations', () async {
      final source = ObservableAsync<int>(5);
      final mapped = source
          .map<int>((value) => value * 2)
          .map<String>((value) => 'Value: $value');

      expect(mapped.value, 'Value: 10');

      bool listenerCalled = false;
      mapped.listen((value) {
        listenerCalled = true;
        expect(value, 'Value: 20');
      });

      source.value = 10;
      await Future.delayed(Duration.zero);

      expect(listenerCalled, true);
    });

    test('async stream cancellation', () async {
      final source = ObservableAsync<int>(10);
      final mapped = source.map<String>((value) => value.toString());

      bool listenerCalled = false;
      final subscription = mapped.listen((value) {
        listenerCalled = true;
      });

      source.value = 20;
      await Future.delayed(Duration.zero);
      expect(listenerCalled, true);

      listenerCalled = false;
      await subscription.cancel();

      source.value = 30;
      await Future.delayed(Duration.zero);
      expect(listenerCalled, false);
    });

    test('map with same value and alwaysNotify flag', () async {
      final source = ObservableAsync<int>(10);

      final mappedDefault = source.map<String>((value) => value.toString());

      bool defaultListenerCalled = false;
      mappedDefault.listen((_) {
        defaultListenerCalled = true;
      });

      final mappedAlwaysNotify = source.map<String>((value) => value.toString(),
          alwaysNotify: true);

      bool alwaysNotifyListenerCalled = false;
      mappedAlwaysNotify.listen((_) {
        alwaysNotifyListenerCalled = true;
      });

      await Future.delayed(Duration.zero);

      defaultListenerCalled = false;
      alwaysNotifyListenerCalled = false;

      source.value = 10;
      await Future.delayed(Duration.zero);

      source.notify();
      await Future.delayed(Duration.zero);

      expect(defaultListenerCalled, false);
      expect(alwaysNotifyListenerCalled, true);

      defaultListenerCalled = false;
      alwaysNotifyListenerCalled = false;

      source.value = 11;
      await Future.delayed(Duration.zero);

      expect(defaultListenerCalled, true);
      expect(alwaysNotifyListenerCalled, true);
    });

    test('map with values', () {
      final source = Observable<int>(3);
      final mapped = source.map<String>((value) => value.toString());

      expect(mapped.value, "3");

      source.value = 99;
      expect(mapped.value, '99');

      source.value = 89;
      expect(mapped.value, "89");
    });
    test('map with null values', () {
      final source = Observable<int?>(null);
      final mapped = source.map<String?>((value) => value?.toString());

      expect(mapped.value, null);

      source.value = 99;
      expect(mapped.value, '99');

      source.value = null;
      expect(mapped.value, null);
    });

    test('map with exception handling', () {
      final source = Observable<int>(10);
      final mapped = source.map<String>((value) {
        if (value < 0) {
          throw Exception('Negative value');
        }
        return value.toString();
      });

      expect(mapped.value, '10');

      source.value = -5;

      FlutterError.onError = (details) {
        expect(details.exception, isA<Exception>());
        expect((details.exception as Exception).toString(),
            'Exception: Negative value');
      };

      expect(mapped.value, '10');
    });

    test('map chaining with multiple transformations', () {
      final source = Observable<int>(5);
      final mapped = source
          .map<int>((value) => value * 2)
          .map<String>((value) => 'Value: $value');

      expect(mapped.value, 'Value: 10');

      source.value = 10;
      expect(mapped.value, 'Value: 20');
    });

    test('map with object equality', () {
      final source = Observable<List<int>>([1, 2, 3]);
      final mapped = source.map<int>((value) => value.length);

      expect(mapped.value, 3);

      source.value.add(4);
      source.notify();

      expect(mapped.value, 4);
    });

    test('cancel behavior', () {
      final source = Observable<int>(10);
      final mapped = source.map<String>((value) => value.toString());

      bool listenerCalled = false;
      final subscription = mapped.listen((_) {
        listenerCalled = true;
      });

      source.value = 20;
      expect(listenerCalled, true);

      listenerCalled = false;
      subscription.cancel();

      source.value = 30;
      expect(listenerCalled, false);
    });

    test('map with same value and alwaysNotify flag', () async {
      final source = Observable<int>(10);

      final mappedDefault = source.map<String>((value) => value.toString());

      bool defaultListenerCalled = false;
      mappedDefault.listen((_) {
        defaultListenerCalled = true;
      });

      final mappedAlwaysNotify = source.map<String>((value) => value.toString(),
          alwaysNotify: true);

      bool alwaysNotifyListenerCalled = false;
      mappedAlwaysNotify.listen((_) {
        alwaysNotifyListenerCalled = true;
      });

      await Future.delayed(Duration.zero);

      defaultListenerCalled = false;
      alwaysNotifyListenerCalled = false;

      source.value = 10;
      await Future.delayed(Duration.zero);

      source.notify();
      await Future.delayed(Duration.zero);

      expect(defaultListenerCalled, false);
      expect(alwaysNotifyListenerCalled, true);

      defaultListenerCalled = false;
      alwaysNotifyListenerCalled = false;

      source.value = 11;
      await Future.delayed(Duration.zero);

      expect(defaultListenerCalled, true);
      expect(alwaysNotifyListenerCalled, true);
    });
  });

  group('AsyncMapper Tests', () {
    test('map with values', () {
      final source = ObservableAsync<int>(3);
      final mapped = source.map<String>((value) => value.toString());

      expect(mapped.value, "3");

      source.value = 99;
      expect(mapped.value, '99');

      source.value = 89;
      expect(mapped.value, "89");
    });
    test('map with null values', () async {
      final source = ObservableAsync<int?>(null);
      final mapped = source.map<String?>((value) => value?.toString());

      expect(mapped.value, null);

      source.value = 99;
      expect(mapped.value, '99');

      source.value = null;
      expect(mapped.value, null);
    });
  });
}

class Person {
  final String name;
  final int age;

  Person(this.name, this.age);

  Person copyWith({String? name, int? age}) {
    return Person(name ?? this.name, age ?? this.age);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Person &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          age == other.age;

  @override
  int get hashCode => name.hashCode ^ age.hashCode;
}
