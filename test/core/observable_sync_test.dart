import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:rx_observable/rx_observable.dart';

/// ✅
void main() {
  group('Basic Functionality', () {
    test('initial value is set and updates correctly', () {
        final obs = Observable<int>(99);
        expect(obs.value, equals(99));
        expect(obs.v, equals(99));

        obs.value = 75;
        expect(obs.value, equals(75));
      });

    test('notifyOnlyIfChanged behavior', () {
      final obs1 = Observable<int>(99, notifyOnlyIfChanged: true);
      int notificationCount1 = 0;
      obs1.addListener(() => notificationCount1++);

      obs1.value = 99;
      expect(notificationCount1, equals(0));

      obs1.value = 75;
      expect(notificationCount1, equals(1));

      final obs2 = Observable<int>(99, notifyOnlyIfChanged: false);
      int notificationCount2 = 0;
      obs2.addListener(() => notificationCount2++);

      obs2.value = 99;
      expect(notificationCount2, equals(1));
    });

    test('notify() forces notification', () {
      final obs = Observable<int>(99, notifyOnlyIfChanged: true);
      int notificationCount = 0;
      obs.addListener(() => notificationCount++);

      obs.notify();
      expect(notificationCount, equals(1));
    });

    test('read-only behavior', () {
      final original = Observable<int>(99);
      final readOnly = original.map((value) => value);
      final readOnly2 = ObservableReadOnly<int>(99);

      expect(readOnly.value, 99);
      expect(readOnly, isA<ObservableReadOnly<int>>());

      // Read-only should update when original changes
      original.value = 75;
      expect(readOnly.value, 75);

      // Read-only should not have a value setter
      expect(() => (readOnly as dynamic).value = 44, throwsNoSuchMethodError);
      expect(() => (readOnly2 as dynamic).value = 44, throwsNoSuchMethodError);
    });
  });

  group('Listeners and Subscriptions', () {
    test('listen callback with and without fireImmediately', () {
      final obs = Observable<int>(99);
      int lastValue1 = 0;
      int lastValue2 = 0;

      obs.listen((value) => lastValue1 = value);
      expect(lastValue1, equals(0));

      obs.listen((value) => lastValue2 = value, fireImmediately: true);
      expect(lastValue2, equals(99));

      obs.value = 75;
      expect(lastValue1, equals(75));
      expect(lastValue2, equals(75));
    });

    test('subscription cancellation works', () {
      final obs = Observable<int>(99);
      int notificationCount = 0;

      final subscription = obs.listen((value) => notificationCount++);
      obs.value = 75;
      expect(notificationCount, equals(1));

      subscription.cancel();
      obs.value = 44;
      expect(notificationCount, equals(1));
    });

    test('multiple listeners and selective removal', () {
      final obs = Observable<int>(99);
      int count1 = 0, count2 = 0, count3 = 0;

      obs.addListener(() => count1++);

      void listener2() => count2++;
      obs.addListener(listener2);
      obs.addListener(() => count3++);

      obs.value = 75;
      expect(count1, equals(1));
      expect(count2, equals(1));
      expect(count3, equals(1));

      obs.removeListener(listener2);
      obs.value = 44;
      expect(count1, equals(2));
      expect(count2, equals(1));
      expect(count3, equals(2));
    });


    test('Observable should not call removed listener', () {
      final observable = Observable<int>(0);

      int callCount = 0;

      late VoidCallback unsubscribe;

      unsubscribe = observable.listen((value) {
        callCount++;
      }).cancel;

      observable.value = 1;
      expect(callCount, 1);

      unsubscribe();

      observable.value = 2;
      expect(callCount, 1);
    });

    test('observables chaining and dependency tracking', () {
      final obs1 = Observable<int>(1);
      final obs2 = Observable<int>(2);
      final obs3 = Observable<int>(3);

      var chain = <String>[];

      // Create a chain of observers
      obs1.addListener(() {
        chain.add('obs1: ${obs1.value}');
        obs2.value = obs1.value * 2;
      });

      obs2.addListener(() {
        chain.add('obs2: ${obs2.value}');
        obs3.value = obs2.value + 1;
      });

      obs3.addListener(() {
        chain.add('obs3: ${obs3.value}');
      });

      // Trigger the chain
      obs1.value = 5;

      // Check the chain of notifications
      expect(chain, ['obs1: 5', 'obs2: 10', 'obs3: 11']);
      expect(obs1.value, 5);
      expect(obs2.value, 10);
      expect(obs3.value, 11);
    });
  });

  group('Transformation and Mapping', () {
    test('map creates transformed observable', () {
      final obs = Observable<int>(99);
      final mapped = obs.map((value) => value.toString());

      expect(mapped.value, equals('99'));
      expect(mapped, isA<ObservableReadOnly<String>>());

      obs.value = 75;
      expect(mapped.value, equals('75'));
    });

    test('chained mapping works correctly', () {
      final obs = Observable<int>(10);
      final mapped1 = obs.map((value) => value * 2);
      final mapped2 = mapped1.map((value) => value.toString());
      final mapped3 = mapped2.map((value) => 'value: $value');

      expect(mapped3.value, equals('value: 20'));

      obs.value = 15;
      expect(mapped1.value, equals(30));
      expect(mapped2.value, equals('30'));
      expect(mapped3.value, equals('value: 30'));
    });

    test('mapped observable respects notifyOnlyIfChanged', () {
      final obs = Observable<int>(99, notifyOnlyIfChanged: true);
      final mapped = obs.map((value) => value > 40 ? 'high' : 'low');
      int notificationCount = 0;

      mapped.addListener(() => notificationCount++);

      obs.value = 75;
      expect(notificationCount, equals(0));

      obs.value = 39;
      expect(notificationCount, equals(1));
    });
  });

  group('Lifecycle and Disposal', () {
    test('disposal behavior', () {
      final obs = Observable<int>(99);
      final mapped = obs.map((value) => value.toString());
      mapped.addListener(() {});

      obs.dispose();

      expect(obs.value, equals(99));
      expect(mapped.value, equals('99'));

      expect(() => obs.value = 75, throwsAssertionError);
      expect(() => obs.notify(), throwsAssertionError);
      expect(() => mapped.notify(), throwsAssertionError);
      expect(() => obs.addListener(() {}), throwsAssertionError);
      expect(() => mapped.addListener(() {}), throwsAssertionError);
      expect(() => obs.listen((_) {}), throwsAssertionError);
    });

    test('disposing mapped observable cleans up properly', () {
      final source = Observable<int>(99);
      bool sourceNotified = false;

      source.addListener(() => sourceNotified = true);

      final mapped = source.map((v) => v * 2);
      bool mappedNotified = false;
      mapped.addListener(() => mappedNotified = true);

      source.value = 10;
      expect(sourceNotified, isTrue);
      expect(mappedNotified, isTrue);
      expect(mapped.value, equals(20));

      sourceNotified = false;
      mappedNotified = false;

      mapped.dispose();

      source.value = 5;
      expect(sourceNotified, isTrue);
      expect(mappedNotified, isFalse);
      expect(() => mapped.notify(), throwsAssertionError);
    });
  });

  group('Additional', () {
    test('handles null values correctly', () {
      final obs = Observable<String?>(null);
      expect(obs.value, isNull);

      int notificationCount = 0;
      obs.addListener(() => notificationCount++);

      obs.value = null;
      expect(notificationCount, equals(0));

      obs.value = 'test';
      expect(notificationCount, equals(1));

      obs.value = null;
      expect(notificationCount, equals(2));
    });

    test('complex objects with custom equality', () {
      const obj1 = _ComplexObject(1, 'first');
      const obj2 = _ComplexObject(2, 'second');
      const obj3 = _ComplexObject(1, 'first');

      final obs = Observable<_ComplexObject>(obj1);
      int notificationCount = 0;
      obs.addListener(() => notificationCount++);

      obs.value = obj3;
      expect(notificationCount, equals(0));

      obs.value = obj2;
      expect(notificationCount, equals(1));
    });

    test('works with collections', () {
      final obs = Observable<List<int>>([1, 2, 3]);
      int notificationCount = 0;
      obs.addListener(() => notificationCount++);

      final list = obs.value;
      list.add(4);
      expect(notificationCount, equals(0));

      obs.value = [1, 2, 3, 4, 5];
      expect(notificationCount, equals(1));
    });

    test('handles errors in listeners gracefully', () {
      final obs = Observable<int>(0);
      int errorCount = 0;
      int successCount = 0;

      obs.addListener(() {
        if (obs.value == 1) {
          errorCount++;
          throw Exception('Test error');
        }
      });

      obs.addListener(() => successCount++);

      obs.value = 1;

      expect(errorCount, equals(1));
      expect(successCount, equals(1));

      obs.value = 2;
      expect(successCount, equals(2));
    });
  });

  group('Compatibility with ChangeNotifier', () {
    test('Observable matches ChangeNotifier behavior for nested notifications',
        () {
      final observable = Observable<int>(0);
      final notifier = ChangeNotifier();

      int notifierValue = 0;
      int observableValue = 0;

      notifier.addListener(() {
        notifierValue++;
        if (notifierValue == 1) {
          notifier.notifyListeners();
        }
      });

      observable.addListener(() {
        observableValue++;
        if (observableValue == 1) {
          observable.notify();
        }
      });

      notifier.notifyListeners();
      observable.notify();

      expect(observableValue, equals(notifierValue));
      expect(observableValue, equals(2));
    });

    test('Observable behaves like ValueNotifier', () {
      final valueNotifier = ValueNotifier<int>(0);
      final observable = Observable<int>(0);

      final vnLog = <int>[];
      final obsLog = <int>[];

      valueNotifier.addListener(() {
        vnLog.add(valueNotifier.value);
      });

      observable.addListener(() {
        obsLog.add(observable.value);
      });

      valueNotifier.value = 1;
      observable.value = 1;

      valueNotifier.value = 2;
      observable.value = 2;

      expect(obsLog, equals(vnLog));
      expect(obsLog, equals([1, 2]));
    });

    test('Observable implements ValueListenable', () {
      final observable = Observable<int>(10);

      ValueListenable<int> asListenable = observable;
      int? valueFromListenable;
      asListenable.addListener(() {
        valueFromListenable = asListenable.value;
      });

      observable.value = 99;

      expect(valueFromListenable, equals(99));
      expect(asListenable.value, equals(99));
    });
  });
}

class _ComplexObject {
  final int id;
  final String name;

  const _ComplexObject(this.id, this.name);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _ComplexObject && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
