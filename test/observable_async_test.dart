import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:rx_observable/rx_observable.dart';

void main() {
  group('Basic Functionality', () {
    test('initial value set and updates correctly', () {
      final obs = ObservableAsync<int>(25);
      expect(obs.value, 25);

      // Test value setter
      obs.value = 1;
      expect(obs.value, 1);

      // Test v setter
      obs.v = 2;
      expect(obs.v, 2);
      expect(obs.value, 2);
    });

    test('adding value through StreamController.add works', () {
      final obs = ObservableAsync<int>(42);
      obs.add(43);
      expect(obs.value, 43);
    });

    test('notifyOnlyIfChanged=true notifies only on actual changes', () async {
      final obs = ObservableAsync<int>(42, notifyOnlyIfChanged: true);
      var notificationCount = 0;

      obs.listen((value) {
        notificationCount++;
      });

      obs.value = 42; // Same value
      await Future.delayed(Duration.zero); // Wait for stream to process
      expect(notificationCount, 0);

      obs.value = 43; // Different value
      await Future.delayed(Duration.zero); // Wait for stream to process
      expect(notificationCount, 1);
    });

    test('notifyOnlyIfChanged=false notifies on every set', () async {
      final obs = ObservableAsync<int>(42, notifyOnlyIfChanged: false);
      var notificationCount = 0;

      obs.listen((value) {
        notificationCount++;
      });

      obs.value = 42; // Same value
      await Future.delayed(Duration.zero); // Wait for stream to process
      expect(notificationCount, 1);

      obs.value = 42; // Same value again
      await Future.delayed(Duration.zero); // Wait for stream to process
      expect(notificationCount, 2);
    });

    test('notify() forces notification regardless of value change', () async {
      final obs = ObservableAsync<int>(42, notifyOnlyIfChanged: true);
      var notificationCount = 0;

      obs.listen((value) {
        notificationCount++;
      });

      obs.notify();
      await Future.delayed(Duration.zero); // Wait for stream to process
      expect(notificationCount, 1);
    });
  });
  group('Listeners and Subscriptions', () {
    test('listen callback is called with current value', () async {
      final obs = ObservableAsync<int>(42);
      var lastValue = 0;

      obs.listen((value) {
        lastValue = value;
      });

      obs.value = 43;
      await Future.delayed(Duration.zero); // Wait for stream to process
      expect(lastValue, 43);
    });

    test('listen with fireImmediately calls listener immediately', () async {
      final obs = ObservableAsync<int>(42);
      var lastValue = 0;

      obs.listen(
        (value) {
          lastValue = value;
        },
        fireImmediately: true,
      );

      await Future.delayed(Duration.zero); // Wait for stream to process
      expect(lastValue, 42);
    });
  });
  group('Transformation and Mapping', () {
    test('map creates new observable that updates with transform', () async {
      final obs = ObservableAsync<int>(42);
      final mapped = obs.map((value) => value.toString());

      expect(mapped.value, '42');

      obs.value = 43;
      await Future.delayed(Duration.zero); // Wait for stream to process
      expect(mapped.value, '43');
    });

    test('mapped observable respects notifyOnlyIfChanged', () async {
      final obs = ObservableAsync<int>(42, notifyOnlyIfChanged: true);
      final mapped = obs.map((value) => value > 40 ? 'high' : 'low');
      var notificationCount = 0;

      mapped.listen((value) {
        notificationCount++;
      });

      obs.value = 43; // Still 'high', shouldn't notify
      await Future.delayed(Duration.zero); // Wait for stream to process
      expect(notificationCount, 0);

      obs.value = 39; // Changes to 'low', should notify
      await Future.delayed(Duration.zero); // Wait for stream to process
      expect(notificationCount, 1);
    });

    test('map creates new observable that updates with transform', () async {
      final obs = ObservableAsync<int>(42);
      final mapped = obs.map((value) => value.toString());

      expect(mapped.value, '42');

      obs.value = 43;
      await Future.delayed(Duration.zero); // Wait for stream to process
      expect(mapped.value, '43');
    });

    test('mapped observable respects notifyOnlyIfChanged', () async {
      final obs = ObservableAsync<int>(42, notifyOnlyIfChanged: true);
      final mapped = obs.map((value) => value > 40 ? 'high' : 'low');
      var notificationCount = 0;

      mapped.listen((value) {
        notificationCount++;
      });

      obs.value = 43; // Still 'high', shouldn't notify
      await Future.delayed(Duration.zero); // Wait for stream to process
      expect(notificationCount, 0);

      obs.value = 39; // Changes to 'low', should notify
      await Future.delayed(Duration.zero); // Wait for stream to process
      expect(notificationCount, 1);
    });
  });
  group('Lifecycle and Disposal', () {
    test('subscription can be cancelled', () async {
      final obs = ObservableAsync<int>(42);
      var notificationCount = 0;

      final subscription = obs.listen((value) {
        notificationCount++;
      });

      obs.value = 43;
      await Future.delayed(Duration.zero); // Wait for stream to process
      expect(notificationCount, 1);

      await subscription.cancel();
      obs.value = 44;
      await Future.delayed(Duration.zero); // Wait for stream to process
      expect(notificationCount, 1); // Should not have increased
    });

    test('disposal cleans up all subscriptions and mapped observables', () {
      final obs = ObservableAsync<int>(42);
      final mapped = obs.map((value) => value.toString());

      // Get a subscription to test
      obs.listen((_) {});

      obs.dispose();

      // Value getters should still work
      expect(obs.value, 42);
      expect(mapped.value, '42');

      // But modifications and notifications should throw
      expect(() => obs.value = 43, throwsStateError);
      expect(() => obs.notify(), throwsStateError);
      expect(() => mapped.notify(), throwsStateError);
      expect(() => obs.add(44), throwsStateError);

      // Check that the observable is closed
      expect(obs.isClosed, true);
      expect(mapped.isClosed, true);
    });

    // Add tests for edge cases after close/dispose
    test('operations after close throw appropriate errors', () async {
      final obs = ObservableAsync<int>(42);
      await obs.close();

      // Value should still be accessible
      expect(obs.value, 42);
      expect(obs.isClosed, true);

      // Operations that should throw
      expect(() => obs.value = 43, throwsStateError);
      expect(() => obs.add(44), throwsStateError);
      expect(() => obs.notify(), throwsStateError);
      expect(() => obs.addError(Exception('Test')), throwsStateError);
    });

    // Testing only the basic behavior of mapping after close
    test('can still read value after close', () {
      final obs = ObservableAsync<int>(42);
      obs.dispose();

      // Value should still be accessible after dispose
      expect(obs.value, 42);
      expect(obs.isClosed, true);
    });
  });
  group('Additional', () {
    test('handles null values correctly', () async {
      final obs = ObservableAsync<String?>(null);
      expect(obs.value, null);

      var notificationCount = 0;
      obs.listen((value) {
        notificationCount++;
      });

      obs.value = null; // Same value (null)
      await Future.delayed(Duration.zero); // Wait for stream to process
      expect(notificationCount, 0);

      obs.value = 'test';
      await Future.delayed(Duration.zero); // Wait for stream to process
      expect(notificationCount, 1);
      expect(obs.value, 'test');

      obs.value = null;
      await Future.delayed(Duration.zero); // Wait for stream to process
      expect(notificationCount, 2);
      expect(obs.value, null);
    });

    test('handles complex objects with custom equality', () async {
      const objA = _ComplexObject(1, 'A');
      const objB = _ComplexObject(2, 'B');
      const objC = _ComplexObject(1, 'A'); // Equal to objA

      final obs =
          ObservableAsync<_ComplexObject>(objA, notifyOnlyIfChanged: true);
      var notificationCount = 0;

      obs.listen((value) {
        notificationCount++;
      });

      obs.value = objC; // Equal to objA, shouldn't notify
      await Future.delayed(Duration.zero); // Wait for stream to process
      expect(notificationCount, 0);

      obs.value = objB; // Different, should notify
      await Future.delayed(Duration.zero); // Wait for stream to process
      expect(notificationCount, 1);
    });

    test('sync flag works as expected', () async {
      final syncObs = ObservableAsync<int>(42, sync: true);
      var syncNotified = false;

      syncObs.listen((value) {
        syncNotified = true;
      });

      syncObs.value = 43;
      // With sync=true, notification happens synchronously
      expect(syncNotified, true);

      final asyncObs = ObservableAsync<int>(42, sync: false);
      var asyncNotified = false;

      asyncObs.listen((value) {
        asyncNotified = true;
      });

      asyncObs.value = 43;
      // With sync=false (default), notification happens asynchronously
      expect(asyncNotified, false);
      await Future.delayed(Duration.zero); // Wait for stream to process
      expect(asyncNotified, true);
    });

    test('onListen callback is invoked when first listener is added', () {
      var onListenCalled = false;
      final obs = ObservableAsync<int>(42, onListen: () {
        onListenCalled = true;
      });

      expect(onListenCalled, false);

      obs.listen((value) {});
      expect(onListenCalled, true);
    });

    test('onCancel callback is invoked when last listener is removed',
        () async {
      var onCancelCalled = false;
      final obs = ObservableAsync<int>(42, onCancel: () {
        onCancelCalled = true;
      });

      final sub = obs.listen((value) {});
      expect(onCancelCalled, false);

      await sub.cancel();
      expect(onCancelCalled, true);
    });

    test('addError forwards errors to listeners', () async {
      final obs = ObservableAsync<int>(42);
      dynamic caughtError;

      // Use the standard stream subscription to catch errors
      obs.stream.listen((value) {}, onError: (error) {
        caughtError = error;
      });

      final testError = Exception('Test error');
      obs.addError(testError);

      await Future.delayed(Duration.zero); // Wait for stream to process
      expect(caughtError, testError);
    });

    test('ObservableAsyncReadOnly cannot modify value', () {
      final readOnly = ObservableAsyncReadOnly<int>(42);
      expect(() => (readOnly as dynamic).value = 43, throwsNoSuchMethodError);
      expect(() => (readOnly as dynamic).add(43), throwsNoSuchMethodError);
      expect(() => (readOnly as dynamic).sink.add(43), throwsNoSuchMethodError);
    });

    test('stream property provides direct access to the underlying stream',
        () async {
      final obs = ObservableAsync<int>(42);
      var streamValue = 0;

      obs.stream.listen((value) {
        streamValue = value;
      });

      obs.value = 43;
      await Future.delayed(Duration.zero);
      expect(streamValue, 43);
    });

    test('addStream forwards values from another stream', () async {
      final obs = ObservableAsync<int>(0);
      final receivedValues = <int>[];

      // Listen to the observable
      obs.listen((value) {
        receivedValues.add(value);
      });

      // Create a simple stream of integers
      final values = [1, 2, 3];
      final stream = Stream.fromIterable(values);

      // Add the stream to our observable
      await obs.addStream(stream);

      // Wait for all events to be processed
      await Future.delayed(Duration.zero);

      // Check that all values were received by listeners
      expect(receivedValues, [1, 2, 3]);

      // Verify that the observable's value is updated to the last value from the stream
      expect(obs.value, 3);
    });

    test('addStream updates value even without listeners', () async {
      final obs = ObservableAsync<int>(0);

      // Create a stream with a single value
      final stream = Stream.value(42);

      // Add the stream to our observable
      await obs.addStream(stream);

      // The observable's value should be updated
      expect(obs.value, 42);
    });

    test('addStream with errors properly forwards errors', () async {
      final obs = ObservableAsync<int>(0);
      dynamic receivedError;

      // Listen to the observable
      obs.stream.listen((_) {}, onError: (error) {
        receivedError = error;
      });

      // Create a stream that will emit an error
      final controller = StreamController<int>();
      controller.addError('Test error');
      controller.close();

      // Add the stream to our observable
      await obs.addStream(controller.stream).catchError((_) {
        // Catch error to prevent test failure
      });

      // Wait for all events to be processed
      await Future.delayed(Duration.zero);

      // Check that the error was forwarded
      expect(receivedError, 'Test error');
    });

    test('hasListener is updated with listener registration', () {
      final obs = ObservableAsync<int>(42);

      expect(obs.hasListener, false);

      final sub = obs.listen((value) {});
      expect(obs.hasListener, true);

      sub.cancel();
      // Note: in some StreamController implementations, hasListener might not
      // update synchronously after cancellation
    });

    test('done future completes when observable is closed', () async {
      final obs = ObservableAsync<int>(42);

      // Create a listener to ensure the stream is active
      obs.listen((value) {});

      // Create a separate future to check when done completes
      var doneCompleted = false;
      obs.done.then((_) {
        doneCompleted = true;
      });

      expect(doneCompleted, false);

      // Close the observable
      obs.dispose();

      // Wait for microtask to complete
      await Future.delayed(Duration.zero);

      expect(doneCompleted, true);
    });

    // Additional edge cases and complex scenarios

    test('handles rapid value changes correctly', () async {
      final obs = ObservableAsync<int>(0, sync: true);
      final receivedValues = <int>[];

      obs.listen((value) {
        receivedValues.add(value);
      });

      // Rapidly update values
      for (int i = 1; i <= 100; i++) {
        obs.value = i;
      }

      // With sync=true, all values should be received immediately
      expect(receivedValues.length, 100);
      expect(receivedValues.last, 100);
    });

    test('multiple listeners receive the same values', () async {
      final obs = ObservableAsync<int>(0);
      final list1 = <int>[];
      final list2 = <int>[];
      final list3 = <int>[];

      obs.listen((value) => list1.add(value));
      obs.listen((value) => list2.add(value));
      obs.listen((value) => list3.add(value));

      obs.value = 1;
      obs.value = 2;
      obs.value = 3;

      await Future.delayed(Duration.zero);

      expect(list1, [1, 2, 3]);
      expect(list2, [1, 2, 3]);
      expect(list3, [1, 2, 3]);
    });

    test('late listeners only receive new values', () async {
      final obs = ObservableAsync<int>(0);
      final earlyListener = <int>[];

      obs.listen((value) => earlyListener.add(value));

      obs.value = 1;
      obs.value = 2;

      await Future.delayed(Duration.zero);

      final lateListener = <int>[];
      obs.listen((value) => lateListener.add(value));

      obs.value = 3;

      await Future.delayed(Duration.zero);

      expect(earlyListener, [1, 2, 3]);
      expect(lateListener, [3]); // Should only get values after subscription
    });

    test('disposing observable during stream processing', () async {
      final obs = ObservableAsync<int>(0);
      final receivedValues = <int>[];

      obs.listen((value) {
        receivedValues.add(value);
        if (value == 5) {
          obs.dispose(); // Dispose during stream processing
        }
      });

      // Add values
      for (int i = 1; i <= 10; i++) {
        try {
          obs.value = i;
          await Future.delayed(Duration.zero);
        } catch (e) {
          // Expecting errors after dispose
        }
      }

      // Should only receive values up to 5
      expect(receivedValues.length, 5);
      expect(receivedValues.last, 5);
      expect(obs.isClosed, true);
    });

    test('using sink to add values', () async {
      final obs = ObservableAsync<int>(0);
      final receivedValues = <int>[];

      obs.listen((value) {
        receivedValues.add(value);
      });

      // Use sink instead of direct add
      obs.sink.add(1);
      obs.sink.add(2);
      obs.sink.add(3);

      await Future.delayed(Duration.zero);

      expect(receivedValues, [1, 2, 3]);
      expect(obs.value, 3); // Value should be updated with sink as well
    });

    test('cancelOnError parameter in addStream', () async {
      final obs = ObservableAsync<int>(0);
      var completed = false;

      // Stream that will emit values then an error
      final controller = StreamController<int>();
      controller.add(1);
      controller.add(2);

      // Start adding the stream but don't await
      obs.addStream(controller.stream, cancelOnError: true).then((_) {
        completed = true;
      }).catchError((_) {
        completed = true;
      });

      await Future.delayed(Duration.zero);
      expect(completed, false);

      // Now add an error
      controller.addError('Test error');

      await Future.delayed(Duration.zero);
      // With cancelOnError: true, the addStream operation should complete
      expect(completed, true);

      controller.close();
    });

    // StreamController compatibility tests

    test('can be used as a drop-in replacement for StreamController', () async {
      // Create a function that expects a StreamController
      Future<List<int>> collectStreamValues(
          StreamController<int> controller) async {
        final values = <int>[];
        final subscription = controller.stream.listen((value) {
          values.add(value);
        });

        controller.add(1);
        controller.add(2);
        controller.add(3);

        await Future.delayed(Duration.zero);
        await subscription.cancel();
        return values;
      }

      // Use our ObservableAsync as the StreamController
      final obs = ObservableAsync<int>(0);
      final values = await collectStreamValues(obs);

      expect(values, [1, 2, 3]);
    });

    test('matches StreamController behavior with sink.addStream', () async {
      // Compare behavior between ObservableAsync and StreamController
      final obs = ObservableAsync<int>(0);
      final controller = StreamController<int>.broadcast();

      final obsValues = <int>[];
      final controllerValues = <int>[];

      obs.listen((value) => obsValues.add(value));
      controller.stream.listen((value) => controllerValues.add(value));

      // Create a source stream
      final source = Stream.fromIterable([1, 2, 3]);

      // Add to both using sink.addStream
      await Future.wait([
        obs.sink.addStream(source),
        controller.sink.addStream(source),
      ]);

      await Future.delayed(Duration.zero);

      expect(obsValues, controllerValues);

      controller.close();
    });

    test('handles error events the same as StreamController', () async {
      final obs = ObservableAsync<int>(0);
      final controller = StreamController<int>.broadcast();

      dynamic obsError;
      dynamic controllerError;

      obs.stream.listen((_) {}, onError: (e) => obsError = e);

      controller.stream.listen((_) {}, onError: (e) => controllerError = e);

      final error = Exception('Test error');
      obs.addError(error);
      controller.addError(error);

      await Future.delayed(Duration.zero);

      expect(obsError.toString(), controllerError.toString());

      controller.close();
    });

    test('closing behavior matches StreamController', () async {
      final obs = ObservableAsync<int>(0);
      final controller = StreamController<int>.broadcast();

      var obsDone = false;
      var controllerDone = false;

      obs.stream.listen((_) {}, onDone: () => obsDone = true);

      controller.stream.listen((_) {}, onDone: () => controllerDone = true);

      // Close both
      await Future.wait([obs.close(), controller.close()]);

      await Future.delayed(Duration.zero);

      expect(obsDone, controllerDone);
      expect(obs.isClosed, controller.isClosed);
    });

    test('difference between close() and dispose() methods', () async {
      // Setup two observables for comparison
      final obsWithClose = ObservableAsync<int>(0);
      final obsWithDispose = ObservableAsync<int>(0);

      // Create mapped observables from both to verify cleanup behavior
      final mappedFromClose = obsWithClose.map((v) => v.toString());
      final mappedFromDispose = obsWithDispose.map((v) => v.toString());

      // Add listeners to both mapped observables
      mappedFromClose.listen((_) {});
      mappedFromDispose.listen((_) {});

      // Close the first one
      await obsWithClose.close();

      // Dispose the second one
      obsWithDispose.dispose();

      // Both should be marked as closed
      expect(obsWithClose.isClosed, true);
      expect(obsWithDispose.isClosed, true);

      // Both should throw on value changes
      expect(() => obsWithClose.value = 1, throwsStateError);
      expect(() => obsWithDispose.value = 1, throwsStateError);

      // The mapped observables should be closed in both cases
      // This matches the current implementation behavior where close() calls dispose()
      expect(mappedFromClose.isClosed, true);
      expect(mappedFromDispose.isClosed, true);

      // Additional verification to test that close() behaves like dispose()
      expect(() => mappedFromClose.notify(), throwsStateError);
      expect(() => mappedFromDispose.notify(), throwsStateError);
    });

    test('chained mapping propagates values through entire chain', () async {
      final source = ObservableAsync<int>(0);

      // Create a chain of transformations
      final step1 = source.map((v) => v * 2); // 0 -> 0
      final step2 = step1.map((v) => v + 10); // 0 -> 10
      final step3 = step2.map((v) => v.toString()); // 10 -> "10"
      final step4 = step3.map((v) => 'Value is: $v'); // "10" -> "Value is: 10"
      final step5 = step4.map((v) => v.length); // "Value is: 10" -> 12

      // Verify initial transformation chain
      expect(step1.value, 0);
      expect(step2.value, 10);
      expect(step3.value, "10");
      expect(step4.value, "Value is: 10");
      // "Value is: 10" has 12 characters (verified with print statement)
      expect(step5.value, 12);

      // Update the source
      source.value = 5;
      await Future.delayed(Duration.zero);

      // Verify the value propagated through the entire chain
      expect(step1.value, 10); // 5 * 2
      expect(step2.value, 20); // 10 + 10
      expect(step3.value, "20");
      expect(step4.value, "Value is: 20");
      // "Value is: 20" has 12 characters too (verified with print statement)
      expect(step5.value, 12);

      // Test disposing the source
      source.dispose();

      // All mapped observables should be disposed
      expect(step1.isClosed, true);
      expect(step2.isClosed, true);
      expect(step3.isClosed, true);
      expect(step4.isClosed, true);
      expect(step5.isClosed, true);
    });

    test(
        'concurrently adding values from multiple isolates handles race conditions',
        () async {
      final obs = ObservableAsync<int>(0);
      final receivedValues = <int>[];

      obs.listen((value) {
        receivedValues.add(value);
      });

      // Simulate concurrent updates using microtasks
      Future<void> simulateConcurrentUpdates() async {
        await Future.wait([
          Future.microtask(() => obs.value = 1),
          Future.microtask(() => obs.value = 2),
          Future.microtask(() => obs.value = 3),
          Future.microtask(() => obs.value = 4),
          Future.microtask(() => obs.value = 5),
        ]);
      }

      await simulateConcurrentUpdates();
      await Future.delayed(Duration.zero);

      // Should have received all values (order may vary but should have 5 values)
      expect(receivedValues.length, 5);
      expect(receivedValues.toSet(), {1, 2, 3, 4, 5});

      // Final value should be one of the values (typically the last one processed)
      expect([1, 2, 3, 4, 5].contains(obs.value), true);
    });

    test('error propagation in observable', () async {
      final source = ObservableAsync<int>(10);
      var errorReceived = false;

      // Listen for errors
      source.stream.listen((_) {}, onError: (e) {
        errorReceived = true;
      });

      // Propagate an error
      source.addError(Exception('Test error'));
      await Future.delayed(Duration.zero);

      // Error should be received by listener
      expect(errorReceived, true);

      // Value should remain unchanged
      expect(source.value, 10);
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
