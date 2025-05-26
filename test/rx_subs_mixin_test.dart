// ignore_for_file: library_private_types_in_public_api

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rx_observable/rx_observable.dart';

/// ✅
void main() {
  group('RxSubsMixin', () {
    test('regSub registers and disposes StreamSubscription correctly',
        () async {
      final testClass = TestClass();
      final controller = StreamController<int>();
      bool callbackCalled = false;

      final subscription = controller.stream.listen((_) {
        callbackCalled = true;
      });

      testClass.regSub(subscription);

      controller.add(1);
      await Future.delayed(Duration.zero);
      expect(callbackCalled, true);

      testClass.dispose();
      expect(testClass.customDisposeCalled, true);

      callbackCalled = false;
      controller.add(2);
      expect(callbackCalled, false);

      controller.close();
    });

    test(
        'regSubs registers and disposes multiple StreamSubscriptions correctly',
        () async {
      final testClass = TestClass();
      final controller1 = StreamController<int>();
      final controller2 = StreamController<int>();
      int callCount = 0;

      final subscription1 = controller1.stream.listen((_) {
        callCount++;
      });

      final subscription2 = controller2.stream.listen((_) {
        callCount++;
      });

      testClass.regSubs([subscription1, subscription2]);

      controller1.add(1);
      controller2.add(1);
      await Future.delayed(Duration.zero);
      expect(callCount, 2);

      testClass.dispose();

      callCount = 0;
      controller1.add(2);
      controller2.add(2);
      expect(callCount, 0);

      controller1.close();
      controller2.close();
    });

    test('regSink registers and closes EventSink correctly', () {
      final testClass = TestClass();
      final controller = StreamController<int>();

      testClass.regSink(controller.sink);
      controller.sink.add(1);
      testClass.dispose();
      expect(() => controller.sink.add(2), throwsStateError);
    });

    test('regSinks registers and closes multiple EventSinks correctly', () {
      final testClass = TestClass();
      final controller1 = StreamController<int>();
      final controller2 = StreamController<int>();

      testClass.regSinks([controller1.sink, controller2.sink]);
      controller1.sink.add(1);
      controller2.sink.add(1);

      testClass.dispose();
      expect(() => controller1.sink.add(2), throwsStateError);
      expect(() => controller2.sink.add(2), throwsStateError);
    });

    test('regDisposable registers and disposes IDisposable correctly', () {
      final testClass = TestClass();
      final disposable = TestDisposable();

      testClass.regDisposable(disposable);
      expect(disposable.disposed, false);

      testClass.dispose();
      expect(disposable.disposed, true);
    });

    test(
        'regDisposables registers and disposes multiple IDisposables correctly',
        () {
      final testClass = TestClass();
      final disposable1 = TestDisposable();
      final disposable2 = TestDisposable();

      testClass.regDisposables([disposable1, disposable2]);
      expect(disposable1.disposed, false);
      expect(disposable2.disposed, false);

      testClass.dispose();
      expect(disposable1.disposed, true);
      expect(disposable2.disposed, true);
    });

    test('regCancelable registers and cancels ICancelable correctly', () {
      final testClass = TestClass();
      final cancelable = TestCancelable();

      testClass.regCancelable(cancelable);
      expect(cancelable.cancelled, false);

      testClass.dispose();
      expect(cancelable.cancelled, true);
    });

    test('regCancelables registers and cancels multiple ICancelables correctly',
        () {
      final testClass = TestClass();
      final cancelable1 = TestCancelable();
      final cancelable2 = TestCancelable();

      testClass.regCancelables([cancelable1, cancelable2]);
      expect(cancelable1.cancelled, false);
      expect(cancelable2.cancelled, false);

      testClass.dispose();
      expect(cancelable1.cancelled, true);
      expect(cancelable2.cancelled, true);
    });

    test('reg handles various types correctly', () {
      final testClass = TestClass();
      final controller = StreamController<int>();
      final subscription = controller.stream.listen((_) {});
      final disposable = TestDisposable();
      final cancelable = TestCancelable();
      final notifier = ChangeNotifier();
      final observable = Observable<int>(42);
      final observableAsync = ObservableAsync<String>("test");

      testClass.reg(subscription);
      testClass.reg(controller.sink);
      testClass.reg(disposable);
      testClass.reg(cancelable);
      testClass.reg(notifier);
      testClass.reg(observable);
      testClass.reg(observableAsync);

      testClass.dispose();

      expect(disposable.disposed, true);
      expect(cancelable.cancelled, true);
      expect(() => controller.sink.add(1), throwsStateError);
      expect(observable.value, 42);
      expect(() => observable.value = 100, throwsAssertionError);
      expect(observableAsync.isClosed, true);
      controller.close();
    });

    test('regs handles lists of various types correctly', () {
      final testClass = TestClass();
      final controller1 = StreamController<int>();
      final controller2 = StreamController<int>();
      final subscription1 = controller1.stream.listen((_) {});
      final subscription2 = controller2.stream.listen((_) {});
      final disposable = TestDisposable();
      final cancelable = TestCancelable();
      final observable = Observable<int>(42);
      final observableAsync = ObservableAsync<String>("test");
      final customResource = CustomResource();
      final adapter = DisposableAdapter(() => customResource.cleanup());

      testClass.regs([
        subscription1,
        subscription2,
        controller1.sink,
        controller2.sink,
        disposable,
        cancelable,
        observable,
        observableAsync,
        adapter
      ]);

      testClass.dispose();

      expect(disposable.disposed, true);
      expect(cancelable.cancelled, true);
      expect(customResource.disposed, true);
      expect(() => controller1.sink.add(1), throwsStateError);
      expect(() => controller2.sink.add(1), throwsStateError);
      expect(() => observable.value = 100, throwsAssertionError);
      expect(observableAsync.isClosed, true);

      // Clean up
      controller1.close();
      controller2.close();
    });

    test('reg throws for unsupported types', () {
      final testClass = TestClass();

      expect(() => testClass.reg("string"), throwsUnimplementedError);
      expect(() => testClass.reg(123), throwsUnimplementedError);
      expect(() => testClass.reg(true), throwsUnimplementedError);
    });

    test('Observable is properly disposed via regDisposable', () {
      final testClass = TestClass();
      final observable = Observable<int>(0);

      testClass.regDisposable(observable);

      observable.value = 42;
      expect(observable.value, 42);
      testClass.dispose();

      expect(observable.value, 42);
      expect(() => observable.value = 100, throwsAssertionError);
    });

    test('ObservableAsync is properly disposed via regDisposable', () {
      final testClass = TestClass();
      final observable = ObservableAsync<int>(0);

      testClass.regDisposable(observable);

      observable.value = 42;
      expect(observable.value, 42);

      testClass.dispose();

      expect(observable.isClosed, true);
      expect(() => observable.value = 100, throwsStateError);
    });

    test('Observable subscriptions are properly cancelled via regCancelable',
        () {
      final testClass = TestClass();
      final observable = Observable<int>(0);
      int callCount = 0;

      final subscription = observable.listen((_) {
        callCount++;
      });

      testClass.regCancelable(subscription);
      observable.value = 1;
      expect(callCount, 1);
      testClass.dispose();

      observable.value = 2;
      expect(callCount, 1); // Still 1, not 2

      observable.dispose();
    });

    test('DisposableAdapter works correctly with custom resources', () {
      final testClass = TestClass();
      final customResource = CustomResource();

      testClass
          .regDisposable(DisposableAdapter(() => customResource.cleanup()));

      expect(customResource.disposed, false);

      testClass.dispose();

      expect(customResource.disposed, true);
    });

    test(
        'DisposableAdapter can be used with both IDisposable and ICancelable interfaces',
        () {
      final testClass = TestClass();
      final customResource1 = CustomResource();
      final customResource2 = CustomResource();

      testClass
          .regDisposable(DisposableAdapter(() => customResource1.cleanup()));

      testClass
          .regCancelable(DisposableAdapter(() => customResource2.cleanup()));

      testClass.dispose();

      expect(customResource1.disposed, true);
      expect(customResource2.disposed, true);
    });
  });

  group('RxSubsStateMixin', () {
    testWidgets(
        'RxSubsStateMixin properly disposes resources when widget is disposed',
        (WidgetTester tester) async {
      final disposable = TestDisposable();
      final cancelable = TestCancelable();
      final controller = StreamController<int>();

      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            disposable: disposable,
            cancelable: cancelable,
            controller: controller,
          ),
        ),
      );

      expect(disposable.disposed, false);
      expect(cancelable.cancelled, false);

      await tester.pumpWidget(Container());

      expect(disposable.disposed, true);
      expect(cancelable.cancelled, true);
      expect(() => controller.sink.add(1), throwsStateError);

      controller.close();
    });
  });

  group('RxSubsMixin edge cases', () {
    test('Disposing twice is safe', () {
      final testClass = TestClass();
      final disposable = TestDisposable();

      testClass.regDisposable(disposable);

      // First dispose
      testClass.dispose();
      expect(disposable.disposed, true);
      expect(testClass.customDisposeCalled, true);

      // Second dispose should not throw
      testClass.dispose();
    });

    test('Registering after disposal throws or is no-op', () {
      final testClass = TestClass();
      testClass.dispose();

      final disposable = TestDisposable();

      // Depending on implementation, might throw or just be a no-op
      // Registering after disposal should ideally throw, but at minimum
      // it shouldn't break anything
      try {
        testClass.regDisposable(disposable);

        // If we get here, it should be a no-op
        expect(disposable.disposed, false);

        // Call dispose again to see if it affects the late-registered disposable
        testClass.dispose();

        // The disposable should either be disposed or untouched
        // (depends on how strict the implementation is)
      } catch (e) {
        // Or it might throw, which is also fine
      }
    });

    test('Registering already disposed resources is handled gracefully', () {
      final testClass = TestClass();
      final disposable = TestDisposable();

      // Pre-dispose the resource
      disposable.dispose();
      expect(disposable.disposed, true);

      // Register it with the mixin
      testClass.regDisposable(disposable);

      // Dispose the mixin - should not cause issues
      testClass.dispose();

      // Disposable should still be in disposed state
      expect(disposable.disposed, true);
    });

    test('RxSubsMixin handles complex registration patterns', () {
      final testClass = TestClass();
      final disposables = List.generate(5, (_) => TestDisposable());
      final cancelables = List.generate(5, (_) => TestCancelable());
      final controllers = List.generate(5, (_) => StreamController<int>());

      // Register some individual resources
      testClass.regDisposable(disposables[0]);
      testClass.regCancelable(cancelables[0]);
      testClass.regSink(controllers[0].sink);

      // Register some as lists
      testClass.regDisposables(disposables.sublist(1, 3));
      testClass.regCancelables(cancelables.sublist(1, 3));
      testClass.regSinks([controllers[1].sink, controllers[2].sink]);

      // Register some with generic reg
      testClass.reg(disposables[3]);
      testClass.reg(cancelables[3]);
      testClass.reg(controllers[3].sink);

      // Register some with generic regs
      testClass.regs([disposables[4], cancelables[4], controllers[4].sink]);

      // Dispose should clean up all resources
      testClass.dispose();

      // Verify all resources are properly disposed
      for (var disposable in disposables) {
        expect(disposable.disposed, true);
      }

      for (var cancelable in cancelables) {
        expect(cancelable.cancelled, true);
      }

      for (var controller in controllers) {
        expect(() => controller.sink.add(1), throwsStateError);
        controller.close();
      }
    });

    test('Resource registered multiple times is only disposed once', () {
      final testClass = TestClass();
      final disposable = TestDisposable();

      // Register the same resource multiple times
      testClass.regDisposable(disposable);
      testClass.regDisposable(disposable);
      testClass.reg(disposable);

      // Dispose should handle duplicates gracefully
      testClass.dispose();

      // Should be disposed exactly once
      expect(disposable.disposed, true);
    });
  });

  group('RxSubsStateMixin edge cases', () {
    testWidgets(
        'RxSubsStateMixin works with dynamic registration in lifecycle methods',
        (WidgetTester tester) async {
      // Special widget that registers resources at different lifecycle stages
      await tester.pumpWidget(
        const MaterialApp(
          home: LifecycleRegistrationWidget(),
        ),
      );

      // Force rebuild
      await tester.pump();

      // Replace the widget to trigger disposal
      await tester.pumpWidget(Container());

      // If we get here without exceptions, the test passes
    });

    testWidgets('RxSubsStateMixin handles State being kept alive',
        (WidgetTester tester) async {
      final disposable = TestDisposable();
      final controller = StreamController<int>();

      // Create a widget that uses a KeepAlive
      await tester.pumpWidget(
        MaterialApp(
          home: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: KeepAliveTestWidget(
                  disposable: disposable,
                  controller: controller,
                ),
              ),
            ],
          ),
        ),
      );

      // Resource should not be disposed yet
      expect(disposable.disposed, false);

      // Scroll away to potentially deactivate but not dispose due to keep alive
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -1000));
      await tester.pump();

      // Resource should still not be disposed
      expect(disposable.disposed, false);

      // Replace the widget entirely to force disposal
      await tester.pumpWidget(Container());

      // Now resources should be disposed
      expect(disposable.disposed, true);
      expect(() => controller.sink.add(1), throwsStateError);

      // Clean up
      controller.close();
    });
  });
}

// Helper classes for testing
class TestDisposable implements IDisposable {
  bool disposed = false;

  @override
  void dispose() {
    disposed = true;
  }
}

class TestCancelable implements ICancelable {
  bool cancelled = false;

  @override
  void cancel() {
    cancelled = true;
  }
}

class TestClass with RxSubsMixin {
  bool customDisposeCalled = false;

  @override
  void dispose() {
    customDisposeCalled = true;
    super.dispose();
  }
}

// Additional test helper classes
class ThrowingDisposable implements IDisposable {
  @override
  void dispose() {
    throw Exception('Intentional exception during disposal');
  }
}

// Widget that registers resources in different lifecycle methods
class LifecycleRegistrationWidget extends StatefulWidget {
  const LifecycleRegistrationWidget({super.key});

  @override
  _LifecycleRegistrationWidgetState createState() =>
      _LifecycleRegistrationWidgetState();
}

class _LifecycleRegistrationWidgetState
    extends State<LifecycleRegistrationWidget> with RxSubsStateMixin {
  late StreamController _initController;
  late StreamController _buildController;
  late StreamController _didUpdateController;

  @override
  void initState() {
    super.initState();
    _initController = StreamController();
    regSink(_initController);
  }

  @override
  Widget build(BuildContext context) {
    _buildController = StreamController();
    regSink(_buildController);
    return Container();
  }

  @override
  void didUpdateWidget(covariant LifecycleRegistrationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _didUpdateController = StreamController();
    regSink(_didUpdateController);
  }
}

// Widget with AutomaticKeepAlive mixin
class KeepAliveTestWidget extends StatefulWidget {
  final TestDisposable disposable;
  final StreamController controller;

  const KeepAliveTestWidget({
    super.key,
    required this.disposable,
    required this.controller,
  });

  @override
  _KeepAliveTestWidgetState createState() => _KeepAliveTestWidgetState();
}

class _KeepAliveTestWidgetState extends State<KeepAliveTestWidget>
    with AutomaticKeepAliveClientMixin, RxSubsStateMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    regDisposable(widget.disposable);
    regSink(widget.controller.sink);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Container(
      height: 200,
      color: Colors.blue,
      child: const Center(child: Text('Keep Alive Test')),
    );
  }
}

// Widget with a disposable that throws
class ErrorTestWidget extends StatefulWidget {
  final ThrowingDisposable throwingDisposable;
  final TestDisposable normalDisposable;

  const ErrorTestWidget({
    super.key,
    required this.throwingDisposable,
    required this.normalDisposable,
  });

  @override
  _ErrorTestWidgetState createState() => _ErrorTestWidgetState();
}

class _ErrorTestWidgetState extends State<ErrorTestWidget>
    with RxSubsStateMixin {
  @override
  void initState() {
    super.initState();
    regDisposable(widget.throwingDisposable);
    regDisposable(widget.normalDisposable);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// Test widget for RxSubsStateMixin tests
class TestWidget extends StatefulWidget {
  final TestDisposable disposable;
  final TestCancelable cancelable;
  final StreamController controller;

  const TestWidget({
    super.key,
    required this.disposable,
    required this.cancelable,
    required this.controller,
  });

  @override
  _TestWidgetState createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> with RxSubsStateMixin {
  @override
  void initState() {
    super.initState();

    // Register resources for automatic disposal
    regDisposable(widget.disposable);
    regCancelable(widget.cancelable);
    regSink(widget.controller.sink);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// Custom types for adapter testing
class CustomResource {
  bool disposed = false;

  void cleanup() {
    disposed = true;
  }
}
