import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:rx_observable/rx_observable.dart';

/// ✅
void main() {
  group('Basic Functionality', () {
    test('initial value set and updates correctly', () {
      final obs = ObservableAsync<int>(25);
      expect(obs.value, 25);
      obs.value = 1;
      expect(obs.value, 1);

      obs.v = 2;
      expect(obs.v, 2);
      expect(obs.value, 2);
    });

    test('adding value through StreamController.add works', () {
      final obs = ObservableAsync<int>(99);
      obs.add(56);
      expect(obs.value, 56);
    });

    test('alwaysNotify=false notifies only on actual changes', () async {
      final obs = ObservableAsync<int>(99, alwaysNotify: false);
      var notificationCount = 0;

      obs.listen((value) {
        notificationCount++;
      });

      obs.value = 99; // Same value
      await Future.delayed(Duration.zero);
      expect(notificationCount, 0);

      obs.value = 58; // Different value
      await Future.delayed(Duration.zero);
      expect(notificationCount, 1);
    });

    test('alwaysNotify=true notifies on every set', () async {
      final obs = ObservableAsync<int>(99, alwaysNotify: true);
      var notificationCount = 0;

      obs.listen((value) {
        notificationCount++;
      });

      expect(obs.alwaysNotify, true);
      obs.value = 99; // Same value
      await Future.delayed(Duration.zero);
      expect(notificationCount, 1);

      obs.value = 99; // Same value again
      await Future.delayed(Duration.zero);
      expect(notificationCount, 2);
    });

    test('notify() forces notification regardless of value change', () async {
      final obs = ObservableAsync<int>(99, alwaysNotify: false);
      var notificationCount = 0;

      obs.listen((value) {
        notificationCount++;
      });

      obs.notify();
      await Future.delayed(Duration.zero);
      expect(notificationCount, 1);
    });
  });
  group('Listeners and Subscriptions', () {
    test('listen callback is called with current value', () async {
      final obs = ObservableAsync<int>(99);
      var lastValue = 0;

      obs.listen((value) {
        lastValue = value;
      });

      obs.value = 58;
      await Future.delayed(Duration.zero);
      expect(lastValue, 58);
    });

    test('listen with preFire calls listener immediately', () async {
      final obs = ObservableAsync<int>(99);
      var lastValue = 0;

      obs.listen(
        (value) {
          lastValue = value;
        },
        preFire: true,
      );

      await Future.delayed(Duration.zero);
      expect(lastValue, 99);
    });
  });
  group('Transformation and Mapping', () {
    test('map creates new observable that updates with transform', () async {
      final obs = ObservableAsync<int>(99);
      final mapped = obs.map((value) => value.toString());

      expect(mapped.value, '99');

      obs.value = 58;
      await Future.delayed(Duration.zero);
      expect(mapped.value, '58');
    });

    test('mapped observable respects alwaysNotify', () async {
      final obs = ObservableAsync<int>(99, alwaysNotify: false);
      final mapped = obs.map((value) => value > 40 ? 'high' : 'low');
      var notificationCount = 0;

      mapped.listen((value) {
        notificationCount++;
      });

      obs.value = 58; // Still 'high', shouldn't notify
      await Future.delayed(Duration.zero);
      expect(notificationCount, 0);

      obs.value = 39; // Changes to 'low', should notify
      await Future.delayed(Duration.zero);
      expect(notificationCount, 1);
    });

    test('map creates new observable that updates with transform', () async {
      final obs = ObservableAsync<int>(99);
      final mapped = obs.map((value) => value.toString());

      expect(mapped.value, '99');

      obs.value = 58;
      await Future.delayed(Duration.zero);
      expect(mapped.value, '58');
    });

    test('mapped observable respects alwaysNotify', () async {
      final obs = ObservableAsync<int>(99, alwaysNotify: false);
      final mapped = obs.map((value) => value > 40 ? 'high' : 'low');
      var notificationCount = 0;

      mapped.listen((value) {
        notificationCount++;
      });

      obs.value = 58;
      await Future.delayed(Duration.zero);
      expect(notificationCount, 0);

      obs.value = 39;
      await Future.delayed(Duration.zero);
      expect(notificationCount, 1);
    });
  });
  group('Lifecycle and Disposal', () {
    test('subscription can be cancelled', () async {
      final obs = ObservableAsync<int>(99);
      var notificationCount = 0;

      final subscription = obs.listen((value) {
        notificationCount++;
      });

      obs.value = 58;
      await Future.delayed(Duration.zero);
      expect(notificationCount, 1);

      await subscription.cancel();
      obs.value = 44;
      await Future.delayed(Duration.zero);
      expect(notificationCount, 1);
    });

    test('disposal cleans up all subscriptions and mapped observables', () {
      final obs = ObservableAsync<int>(99);
      final mapped = obs.map((value) => value.toString());

      obs.listen((_) {});

      obs.dispose();

      expect(obs.value, 99);
      expect(mapped.value, '99');

      expect(() => obs.value = 58, throwsStateError);
      expect(() => obs.notify(), throwsStateError);
      // expect(() => mapped.notify(), throwsStateError);
      expect(() => obs.add(44), throwsStateError);

      expect(obs.isClosed, true);
      expect(mapped.isClosed, true);
    });

    test('operations after close throw appropriate errors', () async {
      final obs = ObservableAsync<int>(99);
      await obs.close();

      expect(obs.value, 99);
      expect(obs.isClosed, true);

      expect(() => obs.value = 58, throwsStateError);
      expect(() => obs.add(44), throwsStateError);
      expect(() => obs.notify(), throwsStateError);
      expect(() => obs.addError(Exception('Test')), throwsStateError);
    });

    test('can still read value after close', () {
      final obs = ObservableAsync<int>(99);
      obs.dispose();

      expect(obs.value, 99);
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

      obs.value = null;
      await Future.delayed(Duration.zero);
      expect(notificationCount, 0);

      obs.value = 'test';
      await Future.delayed(Duration.zero);
      expect(notificationCount, 1);
      expect(obs.value, 'test');

      obs.value = null;
      await Future.delayed(Duration.zero);
      expect(notificationCount, 2);
      expect(obs.value, null);
    });

    test('handles complex objects with custom equality', () async {
      const objA = _ComplexObject(1, 'A');
      const objB = _ComplexObject(2, 'B');
      const objC = _ComplexObject(1, 'A'); // Equal to objA

      final obs =
          ObservableAsync<_ComplexObject>(objA, alwaysNotify: false);
      var notificationCount = 0;

      obs.listen((value) {
        notificationCount++;
      });

      obs.value = objC;
      await Future.delayed(Duration.zero);
      expect(notificationCount, 0);

      obs.value = objB;
      await Future.delayed(Duration.zero);
      expect(notificationCount, 1);
    });

    test('sync flag works as expected', () async {
      final syncObs = ObservableAsync<int>(99, sync: true);
      var syncNotified = false;

      syncObs.listen((value) {
        syncNotified = true;
      });

      syncObs.value = 58;
      expect(syncNotified, true);

      final asyncObs = ObservableAsync<int>(99, sync: false);
      var asyncNotified = false;

      asyncObs.listen((value) {
        asyncNotified = true;
      });

      asyncObs.value = 58;
      expect(asyncNotified, false);
      await Future.delayed(Duration.zero);
      expect(asyncNotified, true);
    });

    test('onListen callback is invoked when first listener is added', () {
      var onListenCalled = false;
      final obs = ObservableAsync<int>(99, onListen: () {
        onListenCalled = true;
      });

      expect(onListenCalled, false);

      obs.listen((value) {});
      expect(onListenCalled, true);
    });

    test('onCancel callback is invoked when last listener is removed',
        () async {
      var onCancelCalled = false;
      final obs = ObservableAsync<int>(99, onCancel: () {
        onCancelCalled = true;
      });

      final sub = obs.listen((value) {});
      expect(onCancelCalled, false);

      await sub.cancel();
      expect(onCancelCalled, true);
    });

    test('addError forwards errors to listeners', () async {
      final obs = ObservableAsync<int>(99);
      dynamic caughtError;

      obs.stream.listen((value) {}, onError: (error) {
        caughtError = error;
      });

      final testError = Exception('Test error');
      obs.addError(testError);

      await Future.delayed(Duration.zero);
      expect(caughtError, testError);
    });

    test('ObservableAsyncReadOnly cannot modify value', () {
      final readOnly = ObservableAsyncReadOnly<int>(99);
      expect(() => (readOnly as dynamic).value = 58, throwsNoSuchMethodError);
      expect(() => (readOnly as dynamic).add(58), throwsNoSuchMethodError);
      expect(() => (readOnly as dynamic).sink.add(58), throwsNoSuchMethodError);
    });

    test('stream property provides direct access to the underlying stream',
        () async {
      final obs = ObservableAsync<int>(99);
      var streamValue = 0;

      obs.stream.listen((value) {
        streamValue = value;
      });

      obs.value = 58;
      await Future.delayed(Duration.zero);
      expect(streamValue, 58);
    });

    test('addStream forwards values from another stream', () async {
      final obs = ObservableAsync<int>(0);
      final receivedValues = <int>[];

      obs.listen((value) {
        receivedValues.add(value);
      });

      final values = [1, 2, 3];
      final stream = Stream.fromIterable(values);

      await obs.addStream(stream);
      await Future.delayed(Duration.zero);

      expect(receivedValues, [1, 2, 3]);
      expect(obs.value, 3);
    });

    test('addStream updates value even without listeners', () async {
      final obs = ObservableAsync<int>(0);
      final stream = Stream.value(99);

      await obs.addStream(stream);
      expect(obs.value, 99);
    });

    test('addStream with errors properly forwards errors', () async {
      final obs = ObservableAsync<int>(0);
      dynamic receivedError;

      obs.stream.listen((_) {}, onError: (error) {
        receivedError = error;
      });

      final controller = StreamController<int>();

      Future.microtask(() {
        controller.addError('Test error');
        controller.close();
      });

      await obs.addStream(controller.stream).catchError((_) {
        // Catch error to prevent test failure
      });

      await Future.delayed(Duration.zero);

      expect(receivedError, 'Test error');
    });

    test('hasListener is updated with listener registration', () {
      final obs = ObservableAsync<int>(99);

      expect(obs.hasListener, false);

      final sub = obs.listen((value) {});
      expect(obs.hasListener, true);

      sub.cancel();
    });

    test('done future completes when observable is closed', () async {
      final obs = ObservableAsync<int>(99);

      obs.listen((value) {});

      var doneCompleted = false;
      obs.done.then((_) {
        doneCompleted = true;
      });

      expect(doneCompleted, false);

      obs.dispose();

      await Future.delayed(Duration.zero);

      expect(doneCompleted, true);
    });

    test('handles rapid value changes correctly', () async {
      final obs = ObservableAsync<int>(0, sync: true);
      final receivedValues = <int>[];

      obs.listen((value) {
        receivedValues.add(value);
      });

      for (int i = 1; i <= 100; i++) {
        obs.value = i;
      }

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
      expect(lateListener, [3]);
    });

    test('disposing observable during stream processing', () async {
      final obs = ObservableAsync<int>(0);
      final receivedValues = <int>[];

      obs.listen((value) {
        receivedValues.add(value);
        if (value == 5) {
          obs.dispose();
        }
      });

      for (int i = 1; i <= 10; i++) {
        try {
          obs.value = i;
          await Future.delayed(Duration.zero);
        } catch (e) {
          // Expecting errors after dispose
        }
      }

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

      obs.sink.add(1);
      obs.sink.add(2);
      obs.sink.add(3);

      await Future.delayed(Duration.zero);

      expect(receivedValues, [1, 2, 3]);
      expect(obs.value, 3);
    });

    test('cancelOnError parameter in addStream', () async {
      final obs = ObservableAsync<int>(0);
      var completed = false;

      final controller = StreamController<int>();
      controller.add(1);
      controller.add(2);

      obs.addStream(controller.stream, cancelOnError: true).then((_) {
        completed = true;
      }).catchError((_) {
        completed = true;
      });

      await Future.delayed(Duration.zero);
      expect(completed, false);

      controller.addError('Test error');

      await Future.delayed(Duration.zero);
      expect(completed, true);

      controller.close();
    });

    // StreamController compatibility tests
    test('can be used as a drop-in replacement for StreamController', () async {
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

      final obs = ObservableAsync<int>(0);
      final values = await collectStreamValues(obs);

      expect(values, [1, 2, 3]);
    });

    test('matches StreamController behavior with sink.addStream', () async {
      final obs = ObservableAsync<int>(0);
      final controller = StreamController<int>.broadcast();

      final obsValues = <int>[];
      final controllerValues = <int>[];

      obs.listen((value) => obsValues.add(value));
      controller.stream.listen((value) => controllerValues.add(value));

      final source = Stream.fromIterable([1, 2, 3]);

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

      await Future.wait([obs.close(), controller.close()]);

      await Future.delayed(Duration.zero);

      expect(obsDone, controllerDone);
      expect(obs.isClosed, controller.isClosed);
    });

    test('difference between close() and dispose() methods', () async {
      final obsWithClose = ObservableAsync<int>(0);
      final obsWithDispose = ObservableAsync<int>(0);

      final mappedFromClose = obsWithClose.map((v) => v.toString());
      final mappedFromDispose = obsWithDispose.map((v) => v.toString());

      mappedFromClose.listen((_) {});
      mappedFromDispose.listen((_) {});

      await obsWithClose.close();
      obsWithDispose.dispose();

      expect(obsWithClose.isClosed, true);
      expect(obsWithDispose.isClosed, true);

      expect(() => obsWithClose.value = 1, throwsStateError);
      expect(() => obsWithDispose.value = 1, throwsStateError);

      expect(mappedFromClose.isClosed, true);
      expect(mappedFromDispose.isClosed, true);

      // expect(() => mappedFromClose.notify(), throwsStateError);
      // expect(() => mappedFromDispose.notify(), throwsStateError);
    });

    test('chained mapping propagates values through entire chain', () async {
      final source = ObservableAsync<int>(0);

      final step1 = source.map((v) => v * 2); // 0 -> 0
      final step2 = step1.map((v) => v + 10); // 0 -> 10
      final step3 = step2.map((v) => v.toString()); // 10 -> "10"
      final step4 = step3.map((v) => 'Value is: $v'); // "10" -> "Value is: 10"
      final step5 = step4.map((v) => v.length); // "Value is: 10" -> 12

      expect(step1.value, 0);
      expect(step2.value, 10);
      expect(step3.value, "10");
      expect(step4.value, "Value is: 10");
      expect(step5.value, 12);

      source.value = 5;
      await Future.delayed(Duration.zero);

      expect(step1.value, 10); // 5 * 2
      expect(step2.value, 20); // 10 + 10
      expect(step3.value, "20");
      expect(step4.value, "Value is: 20");
      expect(step5.value, 12);

      source.dispose();

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

      expect(receivedValues.length, 5);
      expect(receivedValues.toSet(), {1, 2, 3, 4, 5});

      expect([1, 2, 3, 4, 5].contains(obs.value), true);
    });

    test('error propagation in observable', () async {
      final source = ObservableAsync<int>(10);
      var errorReceived = false;

      source.stream.listen((_) {}, onError: (e) {
        errorReceived = true;
      });

      source.addError(Exception('Test error'));
      await Future.delayed(Duration.zero);

      expect(errorReceived, true);
      expect(source.value, 10);
    });

    test('can be used in place of StreamController for broadcast stream',
        () async {
      final obs = ObservableAsync<int>(0, sync: true);
      final stream = obs.stream.asBroadcastStream();

      final values1 = <int>[];
      final values2 = <int>[];

      stream.listen((v) => values1.add(v));
      stream.listen((v) => values2.add(v));

      obs.value = 1;
      obs.value = 2;

      await Future.delayed(Duration.zero);

      expect(values1, [1, 2]);
      expect(values2, [1, 2]);
    });

    test('can use addError like StreamController', () async {
      final obs = ObservableAsync<int>(0);
      dynamic error1;
      dynamic error2;

      obs.stream.listen((_) {}, onError: (e) => error1 = e);
      obs.stream.listen((_) {}, onError: (e) => error2 = e);

      final testError = Exception('Stream error');
      obs.addError(testError);

      await Future.delayed(Duration.zero);

      expect(error1, testError);
      expect(error2, testError);
    });

    test('supports close as StreamController and notifies onDone', () async {
      final obs = ObservableAsync<int>(1);
      var doneCalled = false;

      obs.stream.listen((_) {}, onDone: () => doneCalled = true);

      await obs.close();
      expect(doneCalled, true);
      expect(obs.isClosed, true);
    });

    test('sink.addError behaves like StreamController sink', () async {
      final obs = ObservableAsync<int>(0);
      dynamic receivedError;

      obs.stream.listen((_) {}, onError: (e) => receivedError = e);

      final err = Exception('Sink error');
      obs.sink.addError(err);

      await Future.delayed(Duration.zero);

      expect(receivedError, err);
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
