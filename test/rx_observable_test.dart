import 'package:flutter_test/flutter_test.dart';

import 'dart:async';

import 'package:rx_observable/src/core/observable.dart';

int heavySyncTask(int value) {
  int total = 0;
  for (int i = 1; i <= 1000000; i++) {
    total += (i ^ value) % i;
  }
  return total;
}


Future<void> heavyAsyncTask(int value) async {
  // Имитация тяжёлой async-операции: IO + CPU
  await Future.delayed(Duration(milliseconds: 10)); // IO-задержка

  int total = 0;
  for (int i = 1; i < 10000; i++) {
    total += (i ^ value) % i;
  }

  // Вывод отключён, чтобы не мешал бенчмарку
  // print('Processed $value: $total');
}

class StreamLike<T> {
  final _controller = StreamController<T>.broadcast(sync: true);

  void listen(void Function(T) listener) {
    _controller.stream.listen(listener);
  }

  void add(T value) {
    _controller.add(value);
  }

  void close() {
    _controller.close();
  }
}

void main() {
  test('', () async {
    final iterations = 1;
    final listenersCount = 100;

    final stopwatchRx = Stopwatch()..start();
    final rx = Observable<int>(-1);

    for (int i = 0; i < listenersCount; i++) {
      rx.listen((v) => heavySyncTask(v));
    }

    for (int i = 0; i < iterations; i++) {
      rx.value = i;
    }

    stopwatchRx.stop();

    final stopwatchStream = Stopwatch()..start();
    final stream = ObservableAsync<int>(-1);

    for (int i = 0; i < listenersCount; i++) {
      stream.listen((v) => heavySyncTask(v));
    }

    for (int i = 0; i < iterations; i++) {
      stream.value = i;
    }

    stopwatchStream.stop();

    print('RxNotifier: ${stopwatchRx.elapsedMilliseconds} ms');
    print('StreamLike: ${stopwatchStream.elapsedMilliseconds} ms');
  });
}
