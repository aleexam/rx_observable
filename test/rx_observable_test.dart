import 'package:flutter_test/flutter_test.dart';
import 'package:rx_observable/src/core/observable.dart';

int heavySyncTask(int value) {
  int total = 0;
  for (int i = 1; i <= 1000000; i++) {
    total += (i ^ value) % i;
  }
  return total;
}


Future<void> heavyAsyncTask(int value) async {
  await Future.delayed(const Duration(milliseconds: 10)); // IO-задержка

  int total = 0;
  for (int i = 1; i < 10000; i++) {
    total += (i ^ value) % i;
  }
}

void main() {
  test('', () async {
    const iterations = 1;
    const listenersCount = 100;

    final stopwatchRx = Stopwatch()..start();
    final o1 = Observable<int>(-1);

    for (int i = 0; i < listenersCount; i++) {
      o1.listen((v) => heavySyncTask(v));
    }

    for (int i = 0; i < iterations; i++) {
      o1.value = i;
    }

    stopwatchRx.stop();

    final stopwatchStream = Stopwatch()..start();
    final o2 = ObservableAsync<int>(-1);

    for (int i = 0; i < listenersCount; i++) {
      o2.listen((v) => heavySyncTask(v));
    }

    for (int i = 0; i < iterations; i++) {
      o2.value = i;
    }

    stopwatchStream.stop();

    print('Sync: ${stopwatchRx.elapsedMilliseconds} ms');
    print('Async: ${stopwatchStream.elapsedMilliseconds} ms');
  });
}
