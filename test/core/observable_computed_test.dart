import 'package:flutter_test/flutter_test.dart';
import 'package:rx_observable/rx_observable.dart';

/// ✅
void main() {
  group('ObservableComputed', () {
    group('Basic Computation and Updates', () {
      test('computes initial value from dependencies', () {
        final a = Observable<int>(2);
        final b = Observable<int>(3);
        final computed =
            ObservableComputed([a, b], computer: () => a.value + b.value);
        expect(computed.value, 5);
      });

      test('updates when a dependency changes', () {
        final a = Observable<int>(2);
        final b = Observable<int>(3);
        final computed =
            ObservableComputed([a, b], computer: () => a.value * b.value);

        int? lastValue;
        computed.listen((v) => lastValue = v);

        expect(computed.value, 6);

        a.value = 4;
        expect(computed.value, 12);
        expect(lastValue, 12);

        b.value = 5;
        expect(computed.value, 20);
        expect(lastValue, 20);
      });

      test('works with multiple dependencies', () {
        final a = Observable<int>(1);
        final b = Observable<int>(2);
        final c = Observable<int>(3);
        final computed = ObservableComputed([a, b, c],
            computer: () => a.value + b.value + c.value);

        expect(computed.value, 6);

        a.value = 2;
        expect(computed.value, 7);
        b.value = 5;
        expect(computed.value, 10);
        c.value = 0;
        expect(computed.value, 7);
      });

      test('computed value is always consistent with dependencies', () {
        final a = Observable<int>(1);
        final b = Observable<int>(2);
        final computed =
            ObservableComputed([a, b], computer: () => a.value + b.value);

        a.value = 10;
        b.value = 20;
        expect(computed.value, 30);
      });

      test('computed created via list extension updates properly', () {
        final firstName = 'John'.obs;
        final age = 25.obs;
        final userInfo =
            [firstName, age].compute(() => "${firstName.value}, ${age.value}");

        expect(userInfo.value, 'John, 25');

        firstName.value = 'Jane';
        expect(userInfo.value, 'Jane, 25');

        age.value = 30;
        expect(userInfo.value, 'Jane, 30');
      });

      test('computed created via list extension triggers listeners', () {
        final city = 'London'.obs;
        final country = 'UK'.obs;
        final location =
            [city, country].compute(() => "${city.value}, ${country.value}");

        final values = <String>[];
        location.listen(values.add, preFire: true);

        expect(values, ['London, UK']);

        city.value = 'Paris';
        expect(values.last, 'Paris, UK');

        country.value = 'France';
        expect(values.last, 'Paris, France');
      });

      test('computed extension listen provides expected values', () {
        final name = 'Alice'.obs;
        final greeting = [name].compute(() => "Hello, ${name.value}!");

        final received = <String>[];
        greeting.listen(received.add, preFire: true);

        expect(received, ['Hello, Alice!']);

        name.value = 'Bob';
        expect(received.last, 'Hello, Bob!');

        name.value = 'Charlie';
        expect(received.last, 'Hello, Charlie!');
      });

      test('computed extension listen handles multiple updates', () {
        final first = 'A'.obs;
        final second = '1'.obs;
        final combined =
            [first, second].compute(() => "${first.value}-${second.value}");

        final log = <String>[];
        combined.listen(log.add, preFire: true);

        expect(log, ['A-1']);

        second.value = '2';
        expect(log.last, 'A-2');

        first.value = 'B';
        expect(log.last, 'B-2');

        second.value = '3';
        expect(log.last, 'B-3');
      });
    });

    group('Notifications', () {
      test('notifies only if computed value changes (alwaysNotify=false)',
          () {
        final a = Observable<int>(1);
        final computed = ObservableComputed(
          [a],
          computer: () => a.value > 0 ? 1 : 0,
          alwaysNotify: false
        );

        int notifyCount = 0;
        computed.listen((_) => notifyCount++);

        a.value = 2; // computed stays 1
        expect(notifyCount, 0);

        a.value = -1; // computed changes to 0
        expect(notifyCount, 1);
      });

      test('notifies on every dependency change (alwaysNotify=true)',
          () {
        final a = Observable<int>(1);
        final computed = ObservableComputed(
          [a],
          computer: () => a.value.isEven ? 0 : 1,
          alwaysNotify: true
        );

        int notifyCount = 0;
        computed.listen((_) => notifyCount++);

        a.value = 3; // still 1
        expect(notifyCount, 1);

        a.value = 4; // changes to 0
        expect(notifyCount, 2);
      });

      test('listener receives value immediately if preFire is true',
          () {
        final a = Observable<int>(5);
        final computed = ObservableComputed([a], computer: () => a.value * 2);

        int? received;
        computed.listen((v) => received = v, preFire: true);
        expect(received, 10);
      });

      test(
          'canceling a subscription stops further notifications for that listener',
          () {
        final a = Observable<int>(1);
        final computed = ObservableComputed([a], computer: () => a.value + 1);

        int callCount = 0;
        final sub = computed.listen((_) => callCount++);
        a.value = 2;
        expect(callCount, 1);

        sub.cancel();
        a.value = 3;
        expect(callCount, 1); // no new calls
      });

      test('listener removed before first notification does not receive value',
          () {
        final a = Observable<int>(1);
        final computed = ObservableComputed([a], computer: () => a.value + 1);

        bool wasCalled = false;
        final sub = computed.listen((_) => wasCalled = true);
        sub.cancel();
        a.value = 5;
        expect(wasCalled, isFalse);
      });
    });

    group('Dispose and Error Handling', () {
      test('stops reacting after dispose', () {
        final a = Observable<int>(1);
        final computed = ObservableComputed([a], computer: () => a.value * 2);
        int? lastValue;
        computed.listen((v) => lastValue = v);

        computed.dispose();
        a.value = 10;

        expect(computed.v, 2);
        expect(lastValue, null);
      });

      test('handles errors in compute function', () {
        final a = Observable<int>(1);
        final computed = ObservableComputed([a], computer: () {
          if (a.value == 0) throw Exception('bad');
          return 1 ~/ a.value;
        });

        expect(computed.value, 1);
        a.value = 0;
        expect(() => computed.value, returnsNormally);
      });

      test('computed recovers after error if dependencies become valid', () {
        final a = Observable<int>(1);
        final computed = ObservableComputed([a], computer: () {
          if (a.value == 0) throw Exception('bad');
          return 10 ~/ a.value;
        });

        expect(computed.value, 10);
        a.value = 0;
        expect(() => computed.value, returnsNormally);

        a.value = 2;
        expect(computed.value, 5);
      });
    });

    group('Advanced Cases', () {
      test('computed with no dependencies computes once and never updates', () {
        int computeCount = 0;
        final computed = ObservableComputed([], computer: () {
          computeCount++;
          return 86;
        });

        expect(computed.value, 86);
        expect(computeCount, 1);

        int notifyCount = 0;
        computed.listen((_) => notifyCount++);

        // computed.notify();
        // expect(notifyCount, 1); // preFire only
      });

      test('chained computed values update correctly', () {
        final a = Observable<int>(2);
        final b = ObservableComputed([a], computer: () => a.value * 2);
        final c = ObservableComputed([b], computer: () => b.value + 1);

        expect(c.value, 5);
        a.value = 3;
        expect(b.value, 6);
        expect(c.value, 7);
      });
    });
  });
}
