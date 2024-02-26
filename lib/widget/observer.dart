import 'package:flutter/material.dart';
import 'package:rx_observable/src/observable.dart';

/// Widget that listen to an [observable], build [builder] when its changed
/// and provides [observable] value to builder.
class Observer<T> extends StatelessWidget {
  const Observer({
    super.key,
    required this.observable,
    required this.builder,
  });

  final Observable<T> observable;
  final Widget? Function(BuildContext, T value) builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
        stream: observable.stream,
        builder: (context, _) {
          return builder(context, observable.value) ?? const SizedBox.shrink();
        }
    );
  }
}

/// Same as [Observer] for 2 observables
class Observer2<T, T2> extends StatelessWidget {
  const Observer2({
    super.key,
    required this.observable,
    required this.observable2,
    required this.builder,
  });

  final Observable<T> observable;
  final Observable<T2> observable2;
  final Widget? Function(BuildContext, T value, T2 value2) builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: observable.stream,
      builder: (context, _) {
        return StreamBuilder<T2>(
            stream: observable2.stream,
            builder: (context, _) {
              return builder(context, observable.value, observable2.value) ?? const SizedBox.shrink();
            }
        );
      }
    );
  }
}

/// Same as [Observer] for 3 observables
class Observer3<T, T2, T3> extends StatelessWidget {
  const Observer3({
    super.key,
    required this.observable,
    required this.observable2,
    required this.observable3,
    required this.builder,
  });

  final Observable<T> observable;
  final Observable<T2> observable2;
  final Observable<T3> observable3;
  final Widget? Function(BuildContext, T value, T2 value2, T3 value3) builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
        stream: observable.stream,
        builder: (context, _) {
          return StreamBuilder<T2>(
              stream: observable2.stream,
              builder: (context, _) {
                return StreamBuilder<T3>(
                  stream: observable3.stream,
                  builder: (context, _) {
                    return builder(context, observable.value, observable2.value, observable3.value)
                        ?? const SizedBox.shrink();
                  }
                );
              }
          );
        }
    );
  }
}