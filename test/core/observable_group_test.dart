import 'package:flutter_test/flutter_test.dart';
import 'package:rx_observable/rx_observable.dart';

/// ✅
void main() {
  group('ObservableGroup', () {
    group('Basic Behavior', () {
      test('notifies when any dependency changes', () {
        final a = Observable<int>(1);
        final b = Observable<String>('x');
        final group = ObservableGroup([a, b]);

        int listenCount = 0;
        int onChangeCount = 0;
        int addListenerCount = 0;

        group.listen((_) => listenCount++);
        group.listener(() => onChangeCount++);
        group.addListener(() => addListenerCount++);

        a.value = 2;
        expect(listenCount, equals(1));
        expect(onChangeCount, equals(1));
        expect(addListenerCount, equals(1));

        b.value = 'y';
        expect(listenCount, equals(2));
        expect(onChangeCount, equals(2));
        expect(addListenerCount, equals(2));

        group.dispose();
      });

      test('listener is not triggered on listen', () {
        final a = Observable<int>(1);
        final group = ObservableGroup([a]);
        int notifyCount = 0;

        group.listen((_) => notifyCount++);

        expect(notifyCount, equals(0));

        group.dispose();
      });

      test('group with no dependencies never notifies after listen', () {
        final group = ObservableGroup([]);
        int notifyCount = 0;

        group.listen((_) => notifyCount++);

        expect(notifyCount, equals(0));

        group.dispose();
      });

      test('multiple listeners all get notified', () {
        final a = Observable<int>(1);
        final group = ObservableGroup([a]);
        int count1 = 0;
        int count2 = 0;

        group.listen((_) => count1++);
        group.listen((_) => count2++);

        a.value = 2;

        expect(count1, equals(1));
        expect(count2, equals(1));

        group.dispose();
      });
    });

    group('Subscription Management', () {
      test('removing listener stops notifications', () {
        final a = Observable<int>(1);
        final group = ObservableGroup([a]);
        int notifyCount = 0;

        final sub = group.listen((_) => notifyCount++);

        a.value = 2;
        expect(notifyCount, equals(1));

        sub.cancel();
        a.value = 3;
        expect(notifyCount, equals(1));

        group.dispose();
      });

      test('group does not notify after clearing all listeners', () {
        final a = Observable<int>(1);
        final group = ObservableGroup([a]);

        int count = 0;
        final sub = group.listen((_) => count++);
        sub.cancel();

        a.value = 5;

        expect(count, equals(0));

        group.dispose();
      });
    });

    group('Disposal', () {
      test('dispose cancels all subscriptions and clears listeners', () {
        final a = Observable<int>(1);
        final b = Observable<int>(2);
        final group = ObservableGroup([a, b]);
        int notifyCount = 0;

        group.listen((_) => notifyCount++);

        group.dispose();

        a.value = 10;
        b.value = 20;

        expect(notifyCount, equals(0));
      });

      test('dispose works as expected', () {
        final a = Observable<int>(1);
        final group = ObservableGroup([a]);

        group.dispose();

        expect(() => group.dispose(), throwsFlutterError);
        expect(() => group.listener(() => 1), throwsFlutterError);
        expect(() => group.listen((_) => 1), throwsFlutterError);
        expect(() => group.addListener(() => 1), throwsFlutterError);
      });
    });

    group('Edge Cases', () {
      test('group notifies on rapid consecutive changes', () {
        final a = Observable<int>(1);
        final group = ObservableGroup([a]);

        int notifyCount = 0;
        group.listen((_) => notifyCount++);

        a.value = 2;
        a.value = 3;
        a.value = 4;

        expect(notifyCount, equals(3));

        group.dispose();
      });

      test('group can be created dynamically with late observables', () {
        final observables = <Observable>{};
        final a = Observable<int>(1);
        final b = Observable<int>(2);
        observables.add(a);
        observables.add(b);

        final group = ObservableGroup(observables.toList());
        int count = 0;
        group.listen((_) => count++);

        a.value = 10;
        b.value = 20;

        expect(count, equals(2));

        group.dispose();
      });

      test('group can be created using extension on list', () {
        final firstName = 'John'.obs;
        final age = 30.obs;
        final group = [firstName, age].group();

        int notifyCount = 0;
        group.listener(() => notifyCount++);

        expect(notifyCount, equals(0));

        firstName.value = 'Jane';
        expect(notifyCount, equals(1));

        age.value = 31;
        expect(notifyCount, equals(2));

        group.dispose();
      });

      test('group extension triggers listeners correctly', () {
        final a = 1.obs;
        final b = true.obs;
        final group = [a, b].group();

        final triggered = <int>[];
        group.listen((_) => triggered.add(a.value));

        a.value = 2;
        b.value = false;

        expect(triggered, equals([2, 2]));

        group.dispose();
      });
    });
  });
}
