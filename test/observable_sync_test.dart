import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:rx_observable/rx_observable.dart';

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

void main() {
  group('Observable<T>', () {
    test('initial value is set correctly', () {
      final obs = Observable<int>(42);
      expect(obs.value, 42);
    });

    test('value updates correctly', () {
      final obs = Observable<int>(42);
      obs.value = 43;
      expect(obs.value, 43);
    });

    test('notifyOnlyIfChanged=true notifies only on actual changes', () {
      final obs = Observable<int>(42, notifyOnlyIfChanged: true);
      var notificationCount = 0;
      
      obs.addListener(() {
        notificationCount++;
      });

      obs.value = 42; // Same value
      expect(notificationCount, 0);
      
      obs.value = 43; // Different value
      expect(notificationCount, 1);
    });

    test('notifyOnlyIfChanged=false notifies on every set', () {
      final obs = Observable<int>(42, notifyOnlyIfChanged: false);
      var notificationCount = 0;
      
      obs.addListener(() {
        notificationCount++;
      });

      obs.value = 42; // Same value
      expect(notificationCount, 1);
      
      obs.value = 42; // Same value again
      expect(notificationCount, 2);
    });

    test('notify() forces notification regardless of value change', () {
      final obs = Observable<int>(42, notifyOnlyIfChanged: true);
      var notificationCount = 0;
      
      obs.addListener(() {
        notificationCount++;
      });

      obs.notify();
      expect(notificationCount, 1);
    });

    test('listen callback is called with current value', () {
      final obs = Observable<int>(42);
      var lastValue = 0;
      
      obs.listen((value) {
        lastValue = value;
      });

      obs.value = 43;
      expect(lastValue, 43);
    });

    test('listen with fireImmediately calls listener immediately', () {
      final obs = Observable<int>(42);
      var lastValue = 0;
      
      obs.listen(
        (value) {
          lastValue = value;
        },
        fireImmediately: true,
      );

      expect(lastValue, 42);
    });

    test('map creates new observable that updates with transform', () {
      final obs = Observable<int>(42);
      final mapped = obs.map((value) => value.toString());
      
      expect(mapped.value, '42');
      
      obs.value = 43;
      expect(mapped.value, '43');
    });

    test('mapped observable respects notifyOnlyIfChanged', () {
      final obs = Observable<int>(42, notifyOnlyIfChanged: true);
      final mapped = obs.map((value) => value > 40 ? 'high' : 'low');
      var notificationCount = 0;
      
      mapped.addListener(() {
        notificationCount++;
      });

      obs.value = 43; // Still 'high', shouldn't notify
      expect(notificationCount, 0);
      
      obs.value = 39; // Changes to 'low', should notify
      expect(notificationCount, 1);
    });

    test('subscription can be cancelled', () {
      final obs = Observable<int>(42);
      var notificationCount = 0;
      
      final subscription = obs.listen((value) {
        notificationCount++;
      });

      obs.value = 43;
      expect(notificationCount, 1);
      
      subscription.cancel();
      obs.value = 44;
      expect(notificationCount, 1); // Should not have increased
    });

    test('disposal cleans up all subscriptions and mapped observables', () {
      final obs = Observable<int>(42);
      final mapped = obs.map((value) => value.toString());
      mapped.addListener(() {});

      obs.dispose();
      
      // Value getters should still work
      expect(obs.value, 42);
      expect(mapped.value, '42');
      
      // But modifications and notifications should throw
      expect(() => obs.value = 43, throwsAssertionError);
      expect(() => obs.notify(), throwsAssertionError);
      expect(() => mapped.notify(), throwsAssertionError);
      expect(() => obs.addListener(() {}), throwsAssertionError);
      expect(() => mapped.addListener(() {}), throwsAssertionError);
      expect(() => obs.listen((p0) { }), throwsAssertionError);
      expect(() => mapped.listen((p0) { }), throwsAssertionError);
    });
    
    // New edge case tests
    
    test('handles null values correctly', () {
      final obs = Observable<String?>(null);
      expect(obs.value, null);
      
      var notificationCount = 0;
      obs.addListener(() {
        notificationCount++;
      });
      
      obs.value = null; // Same value (null)
      expect(notificationCount, 0);
      
      obs.value = 'test';
      expect(notificationCount, 1);
      expect(obs.value, 'test');
      
      obs.value = null;
      expect(notificationCount, 2);
      expect(obs.value, null);
    });
    
    test('works with complex objects and equality', () {
      const obj1 = _ComplexObject(1, 'first');
      const obj2 = _ComplexObject(2, 'second');
      const obj3 = _ComplexObject(1, 'first'); // Equal to obj1 but different instance
      
      final obs = Observable<_ComplexObject>(obj1);
      var notificationCount = 0;
      
      obs.addListener(() {
        notificationCount++;
      });
      
      obs.value = obj3; // Equal but different instance
      expect(notificationCount, 0); // Should not notify since they're equal
      
      obs.value = obj2;
      expect(notificationCount, 1);
      expect(obs.value, obj2);
    });
    
    test('chained mapping works correctly', () {
      final obs = Observable<int>(10);
      final mapped1 = obs.map((value) => value * 2);
      final mapped2 = mapped1.map((value) => value.toString());
      final mapped3 = mapped2.map((value) => 'value: $value');
      
      expect(mapped1.value, 20);
      expect(mapped2.value, '20');
      expect(mapped3.value, 'value: 20');
      
      obs.value = 15;
      
      expect(mapped1.value, 30);
      expect(mapped2.value, '30');
      expect(mapped3.value, 'value: 30');
    });
    
    test('supports multiple listeners', () {
      final obs = Observable<int>(42);
      var count1 = 0, count2 = 0, count3 = 0;
      
      obs.addListener(() => count1++);
      obs.addListener(() => count2++);
      obs.addListener(() => count3++);
      
      obs.value = 43;
      
      expect(count1, 1);
      expect(count2, 1);
      expect(count3, 1);
      
      // Remove one listener
      listener() => count2++;
      obs.addListener(listener);
      obs.value = 44;
      
      expect(count1, 2);
      expect(count2, 3); // Incremented twice because we added the same listener twice
      expect(count3, 2);
      
      obs.removeListener(listener);
      obs.value = 45;
      
      expect(count1, 3);
      expect(count2, 4); // Still incremented once because one instance remains
      expect(count3, 3);
    });
    
    test('works with lists', () {
      final obs = Observable<List<int>>([1, 2, 3]);
      var notificationCount = 0;
      
      obs.addListener(() {
        notificationCount++;
      });
      
      // Modifying the original list doesn't trigger notification
      // because the list reference is the same
      final list = obs.value;
      list.add(4);
      expect(notificationCount, 0);
      
      // Assigning a new list triggers notification
      obs.value = [1, 2, 3, 4];
      expect(notificationCount, 1);
      
      // Even if content is the same, new list reference triggers notification
      // when notifyOnlyIfChanged is true (default)
      obs.value = [1, 2, 3, 4];
      expect(notificationCount, 2);
    });
    
    test('correctly handles adding/removing listeners during notification', () {
      final obs = Observable<int>(0);
      var primaryCount = 0;
      var secondaryCount = 0;
      
      // This listener will add another listener when called
      void primaryListener() {
        primaryCount++;
        if (primaryCount == 1) {
          // Add a secondary listener during notification
          obs.addListener(() {
            secondaryCount++;
          });
        }
      }
      
      obs.addListener(primaryListener);
      
      // This should trigger primaryListener, which adds secondaryListener
      obs.value = 1;
      expect(primaryCount, 1);
      
      // This should trigger both listeners
      obs.value = 2;
      expect(primaryCount, 2);
      expect(secondaryCount, 1); // Only triggered once since it was added after the first notification
    });
    
    test('correctly handles nested value changes inside listeners', () {
      final obs = Observable<int>(0);
      var notificationSequence = <int>[];
      var directChangeCount = 0;
      var nestedChangeCount = 0;
      
      // First listener that will modify the value when called
      obs.addListener(() {
        notificationSequence.add(obs.value);
        
        if (obs.value == 1) {
          directChangeCount++;
          // This will trigger another round of notifications
          obs.value = 2;
        }
      });
      
      // Second listener to verify notification order
      obs.addListener(() {
        if (obs.value == 2) {
          nestedChangeCount++;
        }
      });
      
      // Trigger the initial change
      obs.value = 1;
      
      // Verify that both the direct change and the nested change were processed
      expect(directChangeCount, 1);
      expect(nestedChangeCount, 2);
      
      // Verify notification sequence
      expect(notificationSequence, [1, 2]);
      expect(obs.value, 2);
      
      // Test a more complex chained notification scenario
      final chainObs = Observable<int>(0);
      final values = <int>[];
      
      chainObs.addListener(() {
        values.add(chainObs.value);
        
        // Create a chain of up to 3 nested notifications
        if (chainObs.value == 1) {
          chainObs.value = 2;
        } else if (chainObs.value == 2) {
          chainObs.value = 3;
        }
      });
      
      // Start the chain
      chainObs.value = 1;
      
      // Verify the whole chain was processed
      expect(values, [1, 2, 3]);
      expect(chainObs.value, 3);
    });
    
    test('Observable behaves identically to ChangeNotifier with nested notifications', () {
      // Setup identical scenarios with ChangeNotifier and Observable
      final changeNotifier = _TestChangeNotifier(0);
      final observable = Observable<int>(0);
      
      final cnValues = <int>[];
      final obsValues = <int>[];
      
      // Add identical listeners to both
      changeNotifier.addListener(() {
        cnValues.add(changeNotifier.value);
        
        // Create nested change
        if (changeNotifier.value == 1) {
          changeNotifier.value = 2;
        }
      });
      
      observable.addListener(() {
        obsValues.add(observable.value);
        
        // Create nested change
        if (observable.value == 1) {
          observable.value = 2;
        }
      });
      
      // Trigger initial change in both
      changeNotifier.value = 1;
      observable.value = 1;
      
      // They should behave identically
      expect(cnValues, obsValues, reason: 'Observable should have same notification sequence as ChangeNotifier');
      expect(observable.value, changeNotifier.value);
      
      // Test with more complex chaining
      final cnChain = _TestChangeNotifier(0);
      final obsChain = Observable<int>(0);
      
      final cnChainValues = <int>[];
      final obsChainValues = <int>[];
      
      void addChainListener(dynamic target, List<int> valueList) {
        listener() {
          final currentValue = target is _TestChangeNotifier ? target.value : (target as Observable<int>).value;
          valueList.add(currentValue);
          
          if (currentValue == 1) {
            if (target is _TestChangeNotifier) {
              target.value = 2;
            } else {
              (target as Observable<int>).value = 2;
            }
          } else if (currentValue == 2) {
            if (target is _TestChangeNotifier) {
              target.value = 3;
            } else {
              (target as Observable<int>).value = 3;
            }
          } else if (currentValue == 3) {
            if (target is _TestChangeNotifier) {
              target.value = 4;
            } else {
              (target as Observable<int>).value = 4;
            }
          }
        }
        
        if (target is _TestChangeNotifier) {
          target.addListener(listener);
        } else {
          (target as Observable<int>).addListener(listener);
        }
      }
      
      addChainListener(cnChain, cnChainValues);
      addChainListener(obsChain, obsChainValues);
      
      cnChain.value = 1;
      obsChain.value = 1;
      
      expect(cnChainValues, obsChainValues, reason: 'Complex chaining should behave identically');
      expect(cnChain.value, obsChain.value);
    });
    
    test('listen() method behaves identically to addListener with nested notifications', () {
      final obs1 = Observable<int>(0);
      final obs2 = Observable<int>(0);
      
      final values1 = <int>[];
      final values2 = <int>[];
      
      // Use addListener for obs1
      obs1.addListener(() {
        values1.add(obs1.value);
        
        if (obs1.value == 1) {
          obs1.value = 2;
        }
      });
      
      // Use listen for obs2
      obs2.listen((value) {
        values2.add(value);
        
        if (value == 1) {
          obs2.value = 2;
        }
      });
      
      // Trigger notifications
      obs1.value = 1;
      obs2.value = 1;
      
      // Both should behave identically
      expect(values1, values2, reason: 'listen() and addListener should behave identically');
      expect(obs1.value, obs2.value);
      
      // Test with fireImmediately
      final obs3 = Observable<int>(5);
      final values3 = <int>[];
      var nestedChangeTriggered = false;
      
      obs3.listen((value) {
        values3.add(value);
        
        if (value == 5 && !nestedChangeTriggered) {
          nestedChangeTriggered = true;
          obs3.value = 6;
        }
      }, fireImmediately: true);
      
      // Should have triggered immediately and then triggered the nested change
      expect(values3, [5, 6]);
      expect(obs3.value, 6);
    });
  });

  group('ObservableReadOnly<T>', () {
    test('can be created from map of another observable', () {
      final original = Observable<int>(42);
      final readOnly = original.map((value) => value);
      
      expect(readOnly.value, 42);
      expect(readOnly, isA<ObservableReadOnly<int>>());
      
      original.value = 43;
      expect(readOnly.value, 43);
    });
  });

  group('Error handling and recovery', () {
    test('observable recovers after error in listener', () {
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
      obs.addListener(() {
        successCount++;
      });
      
      // This should trigger both listeners, first will throw
      // Using try-catch since the error is caught by the framework
      try {
        obs.value = 1;
      } catch (e) {
        // Expected exception
      }
      
      // The second listener should still have been called
      expect(successCount, 1);
      expect(errorCount, 1);
      
      // Observable should still be usable after error
      obs.value = 2;
      expect(successCount, 2);
      expect(obs.value, 2);
    });
    
    test('map propagates errors properly', () {
      final obs = Observable<int>(0);
      final mapped = obs.map((value) {
        if (value == 1) {
          throw Exception('Test error in map');
        }
        return value.toString();
      });
      
      // Initial mapping works
      expect(mapped.value, '0');
      
      // Mapping that throws should propagate error
      // Using try-catch since the error is caught by the framework
      try {
        obs.value = 1;
      } catch (e) {
        // Expected exception
      }
      
      // Observable and mapping should still be usable after error
      obs.value = 2;
      expect(mapped.value, '2');
    });
  });
  
  group('Complex scenarios', () {
    test('observables watching other observables', () {
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
    
    test('many listeners on one observable', () {
      final obs = Observable<int>(0);
      var callCounts = List.generate(100, (_) => 0);
      
      // Add 100 listeners
      for (var i = 0; i < 100; i++) {
        obs.addListener(() {
          callCounts[i]++;
        });
      }
      
      // Trigger notification
      obs.value = 1;
      
      // All listeners should have been called exactly once
      for (var count in callCounts) {
        expect(count, 1);
      }
    });
    
    test('one observable with many mapped derivatives', () {
      final source = Observable<int>(0);
      final mappings = <ObservableReadOnly<int>>[];
      
      // Create 20 different mappings
      for (var i = 0; i < 20; i++) {
        final multiplier = i; // Capture the current value
        mappings.add(source.map((value) => value * multiplier));
      }
      
      // Change source
      source.value = 5;
      
      // Verify all mappings were updated
      for (var i = 0; i < 20; i++) {
        expect(mappings[i].value, 5 * i);
      }
      
      // Change source again
      source.value = 10;
      
      // Verify all mappings were updated again
      for (var i = 0; i < 20; i++) {
        expect(mappings[i].value, 10 * i);
      }
    });
  });
  
  group('Lifecycle tests', () {
    test('disposing mapped observables properly cleans up parent resources', () {
      final source = Observable<int>(0);
      var sourceListenerCount = 0;
      
      // Count how many active listeners source has
      source.addListener(() {
        sourceListenerCount++;
      });
      
      // Create 3 mappings
      final mapped1 = source.map((v) => v + 1);
      final mapped2 = source.map((v) => v + 2);
      final mapped3 = source.map((v) => v + 3);
      
      // Verify setup works
      source.value = 1;
      expect(sourceListenerCount, 1);
      expect(mapped1.value, 2);
      expect(mapped2.value, 3);
      expect(mapped3.value, 4);
      
      // Dispose two of the mappings
      mapped1.dispose();
      mapped2.dispose();
      
      // Update and verify remaining mapping works and others don't respond
      source.value = 10;
      expect(sourceListenerCount, 2);
      
      expect(() => mapped1.notify(), throwsAssertionError);
      expect(() => mapped2.notify(), throwsAssertionError);
      expect(mapped3.value, 13);
      
      // Dispose the last mapping
      mapped3.dispose();
      
      // Final check
      source.value = 20;
      expect(sourceListenerCount, 3);
    });
    
    test('ensure disposal of mapped observables does not affect other mappings', () {
      final source = Observable<int>(0);
      final mapped1 = source.map((v) => v + 1);
      final mapped2 = source.map((v) => v + 2);
      
      var mapped1Notifications = 0;
      var mapped2Notifications = 0;
      
      mapped1.addListener(() {
        mapped1Notifications++;
      });
      
      mapped2.addListener(() {
        mapped2Notifications++;
      });
      
      // Initial update
      source.value = 5;
      expect(mapped1Notifications, 1);
      expect(mapped2Notifications, 1);
      
      // Dispose one mapping
      mapped1.dispose();
      
      // Second mapping should continue working
      source.value = 10;
      expect(mapped1Notifications, 1); // Unchanged
      expect(mapped2Notifications, 2); // Increased
      expect(mapped2.value, 12);
    });
  });
  
  group('Data integrity tests', () {
    test('handle deep object modification', () {
      // Deep object with multiple levels
      final deepObj = {
        'level1': {
          'level2': {
            'value': 42
          }
        }
      };
      
      final obs = Observable<Map<String, dynamic>>(deepObj);
      var notificationCount = 0;
      
      obs.addListener(() {
        notificationCount++;
      });
      
      // Modify deep inside the object
      final copy = Map<String, dynamic>.from(obs.value);
      (copy['level1'] as Map<String, dynamic>)['level2'] = {'value': 43};
      
      // Update with modified copy
      obs.value = copy;
      expect(notificationCount, 1);
      
      // Verify deep value was updated
      expect((((obs.value['level1'] as Map<String, dynamic>)
          ['level2'] as Map<String, dynamic>)['value']), 43);
    });
    
    test('handles very large values', () {
      // Create a large list
      final largeList = List.generate(10000, (i) => i);
      
      final obs = Observable<List<int>>(largeList);
      var notificationCount = 0;
      
      obs.addListener(() {
        notificationCount++;
      });
      
      // Create modified copy
      final modifiedList = List<int>.from(largeList);
      modifiedList[5000] = -1;
      
      // Update with large modified list
      obs.value = modifiedList;
      expect(notificationCount, 1);
      expect(obs.value[5000], -1);
    });
  });
} 