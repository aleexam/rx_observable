import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rx_observable/rx_observable.dart';

/// ✅
void main() {
  group('SyncMapper Tests', () {
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

    test('map with same value and notifyOnlyIfChanged flag', () async {
      final source = ObservableAsync<int>(10);

      final mappedDefault = source.map<String>((value) => value.toString());

      bool defaultListenerCalled = false;
      mappedDefault.listen((_) {
        defaultListenerCalled = true;
      });

      final mappedAlwaysNotify = source.map<String>((value) => value.toString(),
          notifyOnlyIfChanged: false);

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

    test('map with same value and notifyOnlyIfChanged flag', () async {
      final source = Observable<int>(10);

      final mappedDefault = source.map<String>((value) => value.toString());

      bool defaultListenerCalled = false;
      mappedDefault.listen((_) {
        defaultListenerCalled = true;
      });

      final mappedAlwaysNotify = source.map<String>((value) => value.toString(),
          notifyOnlyIfChanged: false);

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
