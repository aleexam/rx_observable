import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:rx_observable/rx_observable.dart';

/// ✅
void main() {
  group('StreamToObservableAdapter', () {
    test('adapts Stream to IObservableListenable', () async {
      final controller = StreamController<int>();
      final stream = controller.stream;
      final adapter = stream.asObservable();

      int lastValue = -1;
      final subscription = adapter.listen((value) {
        lastValue = value;
      });

      controller.add(1);
      await Future.microtask(() {});
      expect(lastValue, 1);

      controller.add(33);
      await Future.microtask(() {});
      expect(lastValue, 33);

      subscription.cancel();
      controller.add(100);
      await Future.microtask(() {});
      expect(lastValue, 33); // Value unchanged

      controller.close();
    });

    test('adapter.dispose() cancels subscription', () async {
      final controller = StreamController<int>();
      final stream = controller.stream;

      final adapter = stream.asObservable();
      int callCount = 0;

      adapter.listen((value) {
        callCount++;
      });

      controller.add(1);
      await Future.microtask(() {});
      expect(callCount, 1);

      adapter.dispose();

      controller.add(2);
      await Future.microtask(() {});
      expect(callCount, 1); // Count unchanged

      controller.close();
    });

    test('adapter works with broadcast streams', () async {
      final controller = StreamController<int>.broadcast();
      final stream = controller.stream;

      final adapter = stream.asObservable();

      List<int> values1 = [];
      List<int> values2 = [];

      final sub1 = adapter.listen(values1.add);
      final sub2 = adapter.listen(values2.add);

      controller.add(1);
      controller.add(2);
      await Future.delayed(Duration.zero);

      sub1.cancel();
      await Future.delayed(Duration.zero);

      controller.add(3);
      await Future.delayed(Duration.zero);

      expect(values1, [1, 2]);
      expect(values2, [1, 2, 3]);

      sub2.cancel();
      controller.close();
    });

    test('adapter properly manages multiple subscriptions', () async {
      final controller = StreamController<int>.broadcast();
      final stream = controller.stream;

      final adapter = stream.asObservable();

      List<int> values1 = [];
      List<int> values2 = [];
      List<int> values3 = [];

      final sub1 = adapter.listen((value) => values1.add(value));
      final sub2 = adapter.listen((value) => values2.add(value));
      final sub3 = adapter.listen((value) => values3.add(value));

      controller.add(1);
      await Future.microtask(() {});
      sub2.cancel();

      controller.add(2);
      await Future.microtask(() {});

      sub1.cancel();

      controller.add(3);
      await Future.microtask(() {});

      expect(values1, [1, 2]);
      expect(values2, [1]);
      expect(values3, [1, 2, 3]);

      sub3.cancel();
      controller.close();
    });
  });

  group('Stream adapters integration', () {
    test('using adapters with RxSubsMixin', () async {
      final mixin = TestRxSubsMixin();

      final controller = StreamController<int>();
      final stream = controller.stream;

      final observable = stream.asObservable();
      mixin.regDisposable(observable);

      int lastValue = -1;
      observable.listen((value) {
        lastValue = value;
      });

      controller.add(33);
      await Future.microtask(() {});
      expect(lastValue, 33);

      mixin.dispose();

      controller.add(100);
      await Future.microtask(() {});
      expect(lastValue, 33); // Unchanged
      controller.close();
    });

    test('adapter works with ObservableAsync', () async {
      final observableAsync = ObservableAsync<int>(0);
      final controller = StreamController<int>();
      final stream = controller.stream;

      final observable = stream.asObservable();
      final subscription = observable.listen((value) {
        observableAsync.value = value;
      });

      controller.add(1);
      await Future.microtask(() {});
      expect(observableAsync.value, 1);

      controller.add(33);
      await Future.microtask(() {});
      expect(observableAsync.value, 33);

      subscription.cancel();
      controller.close();
      observableAsync.dispose();
    });
  });
}

class TestRxSubsMixin with RxSubsMixin {}
