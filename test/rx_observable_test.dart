import 'package:flutter_test/flutter_test.dart';
import 'package:rx_observable/rx_observable.dart';

Future<int> testListeners(IObservableMutable observable, int listenersCount,
    {bool asyncTask = false}) async {
  void heavySync() {
    for (int i = 0; i < 50000000; i++) {
      var _ = (i ^ 999) % (i + 1);
    }
  }

  Future<void> heavyAsync() async {
    await Future.delayed(const Duration(milliseconds: 60));
  }

  List<Future> futures = [];

  for (int i = 0; i < listenersCount; i++) {
    observable.listen((v) {
      if (asyncTask) {
        futures.add(heavyAsync());
      } else {
        heavySync();
      }
    });
  }

  Stopwatch sw = Stopwatch()..start();
  observable.value += 1;

  if (observable is IObservableAsync) {
    await Future.delayed(Duration.zero);
  }

  if (asyncTask) {
    await Future.wait(futures);
  }

  sw.stop();
  return sw.elapsedMilliseconds;
}

Future<void> main() async {
  test('test listeners update speed difference', () async {
    final observable = Observable<int>(0);
    final observableAsync = ObservableAsync<int>(0);

    var count = 10000;

    var syncTest1 = await testListeners(observable, count);
    print('ObservableSync (sync listeners): $syncTest1 ms');

    var asyncTest1 = await testListeners(observableAsync, count);
    print('ObservableAsync (sync listeners): $asyncTest1 ms');

    var syncTest2 = await testListeners(observable, count, asyncTask: true);
    print('ObservableSync (async listeners): $syncTest2 ms');

    var asyncTest2 =
        await testListeners(observableAsync, count, asyncTask: true);
    print('ObservableAsync (async listeners): $asyncTest2 ms');

    var test1Result = (((syncTest1 / asyncTest1) - 1).abs() * 100);
    var test2Result = (((syncTest2 / asyncTest2) - 1).abs() * 100);

    print("Test 1 dif: $test1Result %");
    print("Test 2 dif: $test2Result %");

    expect(test1Result < 4, isTrue);
    expect(test2Result < 2, isTrue);
  });
}
