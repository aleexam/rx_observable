import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:rx_observable/rx_observable.dart';

void main() {
  group('Basic Functionality', () {
    test('initial value is set and updates correctly', () {
      final obs = Observable<int>(42);
      expect(obs.value, 42);
      expect(obs.v, 42);

      obs.value = 43;
      expect(obs.value, 43);
    });

    test('notifyOnlyIfChanged behavior', () {
      // True case - only notifies on changes
      final obs1 = Observable<int>(42, notifyOnlyIfChanged: true);
      var notificationCount1 = 0;
      obs1.addListener(() => notificationCount1++);

      obs1.value = 42; // Same value
      expect(notificationCount1, 0);

      obs1.value = 43; // Different value
      expect(notificationCount1, 1);

      // False case - notifies on every set
      final obs2 = Observable<int>(42, notifyOnlyIfChanged: false);
      var notificationCount2 = 0;
      obs2.addListener(() => notificationCount2++);

      obs2.value = 42; // Same value
      expect(notificationCount2, 1);
    });

    test('notify() forces notification', () {
      final obs = Observable<int>(42, notifyOnlyIfChanged: true);
      var notificationCount = 0;
      obs.addListener(() => notificationCount++);

      obs.notify();
      expect(notificationCount, 1);
    });
  });

  group('Listeners and Subscriptions', () {
    test('listen callback with and without fireImmediately', () {
      final obs = Observable<int>(42);
      var lastValue1 = 0;
      var lastValue2 = 0;

      // Without fireImmediately
      obs.listen((value) => lastValue1 = value);
      expect(lastValue1, 0); // Not called yet

      // With fireImmediately
      obs.listen((value) => lastValue2 = value, fireImmediately: true);
      expect(lastValue2, 42); // Called immediately

      // Both called on update
      obs.value = 43;
      expect(lastValue1, 43);
      expect(lastValue2, 43);
    });

    test('subscription cancellation works', () {
      final obs = Observable<int>(42);
      var notificationCount = 0;

      final subscription = obs.listen((value) => notificationCount++);
      obs.value = 43;
      expect(notificationCount, 1);

      subscription.cancel();
      obs.value = 44;
      expect(notificationCount, 1); // Should not have increased
    });

    test('multiple listeners and selective removal', () {
      final obs = Observable<int>(42);
      var count1 = 0, count2 = 0, count3 = 0;

      obs.addListener(() => count1++);

      void listener2() => count2++;
      obs.addListener(listener2);
      obs.addListener(() => count3++);

      obs.value = 43;
      expect(count1, 1);
      expect(count2, 1);
      expect(count3, 1);

      obs.removeListener(listener2);
      obs.value = 44;
      expect(count1, 2);
      expect(count2, 1); // Not incremented after removal
      expect(count3, 2);
    });
  });

  group('Transformation and Mapping', () {
    test('map creates transformed observable', () {
      final obs = Observable<int>(42);
      final mapped = obs.map((value) => value.toString());

      expect(mapped.value, '42');
      expect(mapped, isA<ObservableReadOnly<String>>());

      obs.value = 43;
      expect(mapped.value, '43');
    });

    test('chained mapping works correctly', () {
      final obs = Observable<int>(10);
      final mapped1 = obs.map((value) => value * 2);
      final mapped2 = mapped1.map((value) => value.toString());
      final mapped3 = mapped2.map((value) => 'value: $value');

      expect(mapped3.value, 'value: 20');

      obs.value = 15;
      expect(mapped1.value, 30);
      expect(mapped2.value, '30');
      expect(mapped3.value, 'value: 30');
    });

    test('mapped observable respects notifyOnlyIfChanged', () {
      final obs = Observable<int>(42, notifyOnlyIfChanged: true);
      final mapped = obs.map((value) => value > 40 ? 'high' : 'low');
      var notificationCount = 0;

      mapped.addListener(() => notificationCount++);

      obs.value = 43; // Still 'high', shouldn't notify
      expect(notificationCount, 0);

      obs.value = 39; // Changes to 'low', should notify
      expect(notificationCount, 1);
    });
  });

  group('Lifecycle and Disposal', () {
    test('disposal behavior', () {
      final obs = Observable<int>(42);
      final mapped = obs.map((value) => value.toString());
      mapped.addListener(() {});

      obs.dispose();

      // Value getters should still work after disposal
      expect(obs.value, 42);
      expect(mapped.value, '42');

      // Operations should throw after disposal
      expect(() => obs.value = 43, throwsAssertionError);
      expect(() => obs.notify(), throwsAssertionError);
      expect(() => mapped.notify(), throwsAssertionError);
      expect(() => obs.addListener(() {}), throwsAssertionError);
      expect(() => mapped.addListener(() {}), throwsAssertionError);
      expect(() => obs.listen((p0) {}), throwsAssertionError);
    });

    test('disposing mapped observable cleans up properly', () {
      final source = Observable<int>(42);
      var sourceNotified = false;

      source.addListener(() => sourceNotified = true);

      final mapped = source.map((v) => v * 2);
      var mappedNotified = false;
      mapped.addListener(() => mappedNotified = true);

      // Verify setup works
      source.value = 10;
      expect(sourceNotified, true);
      expect(mappedNotified, true);
      expect(mapped.value, 20);

      // Reset flags
      sourceNotified = false;
      mappedNotified = false;

      // Dispose mapped observable
      mapped.dispose();

      // Source should still work
      source.value = 5;
      expect(sourceNotified, true);

      // Mapped should not receive notifications
      expect(mappedNotified, false);
      expect(() => mapped.notify(), throwsAssertionError);
    });
  });

  group('Additional', () {
    test('handles null values correctly', () {
      final obs = Observable<String?>(null);
      expect(obs.value, null);

      var notificationCount = 0;
      obs.addListener(() => notificationCount++);

      obs.value = null; // Same value (null)
      expect(notificationCount, 0);

      obs.value = 'test';
      expect(notificationCount, 1);

      obs.value = null;
      expect(notificationCount, 2);
    });

    test('complex objects with custom equality', () {
      const obj1 = _ComplexObject(1, 'first');
      const obj2 = _ComplexObject(2, 'second');
      const obj3 =
          _ComplexObject(1, 'first'); // Equal to obj1 but different instance

      final obs = Observable<_ComplexObject>(obj1);
      var notificationCount = 0;
      obs.addListener(() => notificationCount++);

      obs.value = obj3; // Equal but different instance
      expect(notificationCount, 0); // Should not notify since they're equal

      obs.value = obj2; // Different object
      expect(notificationCount, 1);
    });

    test('works with collections', () {
      final obs = Observable<List<int>>([1, 2, 3]);
      var notificationCount = 0;
      obs.addListener(() => notificationCount++);

      // Modifying the original list doesn't trigger notification
      // because the list reference is the same
      final list = obs.value;
      list.add(4);
      expect(notificationCount, 0);

      // Assigning a new list triggers notification
      obs.value = [1, 2, 3, 4, 5];
      expect(notificationCount, 1);
    });

    test('handles errors in listeners gracefully', () {
      final obs = Observable<int>(0);
      var errorCount = 0;
      var successCount = 0;

      // First listener that will throw an error
      obs.addListener(() {
        if (obs.value == 1) {
          errorCount++;
          throw Exception('Test error');
        }
      });

      // Second listener should still be called even if first listener throws
      obs.addListener(() => successCount++);

      // This should trigger both listeners, first will throw but ChangeNotifier
      // catches exceptions and doesn't propagate them
      obs.value = 1;

      // Both counters should have been incremented
      expect(errorCount, 1);
      expect(successCount, 1);

      // Observable should still be usable after error
      obs.value = 2;
      expect(successCount, 2);
    });
  });

  group('Additional2', () {
    test('nested notifications are handled properly', () {
      final obs = Observable<int>(0);
      final values = <int>[];

      obs.addListener(() {
        values.add(obs.value);

        // Create nested notification
        if (obs.value == 1) {
          obs.value = 2;
        }
      });

      // Start chain
      obs.value = 1;

      // Both values should be recorded
      expect(values, [1, 2]);
      expect(obs.value, 2);
    });

    test('Observable behaves like ChangeNotifier with nested notifications',
        () {
      final changeNotifier = _TestChangeNotifier(0);
      final observable = Observable<int>(0);

      final cnValues = <int>[];
      final obsValues = <int>[];

      // Add similar listeners to both
      changeNotifier.addListener(() {
        cnValues.add(changeNotifier.value);
        if (changeNotifier.value == 1) {
          changeNotifier.value = 2;
        }
      });

      observable.addListener(() {
        obsValues.add(observable.value);
        if (observable.value == 1) {
          observable.value = 2;
        }
      });

      // Trigger initial change in both
      changeNotifier.value = 1;
      observable.value = 1;

      // They should behave identically
      expect(cnValues, obsValues);
    });

    test('listen with fireImmediately and nested changes', () {
      final obs = Observable<int>(5);
      final values = <int>[];

      obs.listen((value) {
        values.add(value);

        if (value == 5) {
          obs.value = 6;
        }
      }, fireImmediately: true);

      // Should have triggered immediately and then the nested change
      expect(values, [5, 6]);
      expect(obs.value, 6);
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

    test('read-only behavior', () {
      final original = Observable<int>(42);
      final readOnly = original.map((value) => value);
      final readOnly2 = ObservableReadOnly<int>(42);

      expect(readOnly.value, 42);
      expect(readOnly, isA<ObservableReadOnly<int>>());

      // Read-only should update when original changes
      original.value = 43;
      expect(readOnly.value, 43);

      // Read-only should not have a value setter
      expect(() => (readOnly as dynamic).value = 44, throwsNoSuchMethodError);
      expect(() => (readOnly2 as dynamic).value = 44, throwsNoSuchMethodError);
    });

    test('map error handling', () {
      final obs = Observable<int>(0);
      final mapped = obs.map<String>((value) {
        if (value == 1) {
          throw Exception('Test error in map');
        }
        return value.toString();
      });

      // Initial mapping works
      expect(mapped.value, '0');

      // Observable and mapping should still be usable after error
      obs.value = 1;
      expect(mapped.value, '0');
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

// Helper class for comparison tests
class _TestChangeNotifier extends ChangeNotifier {
  _TestChangeNotifier(this._value);

  int _value;
  int get value => _value;
  set value(int newValue) {
    if (_value != newValue) {
      _value = newValue;
      notifyListeners();
    }
  }
}
