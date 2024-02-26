import 'package:flutter/material.dart';
import 'package:rx_observable/rx_observable.dart';
import 'package:rx_observable/widget/observer.dart';

typedef Obx<T> = Observer<T>;

extension ObserverWidgetExt<T> on Observable<T> {
  Widget observer(Widget? Function(BuildContext context, T value) builder) {
    return Observer<T>(
        observable: this,
        builder: builder
    );
  }

  Widget obx(Widget? Function(BuildContext context, T value) builder) {
    return observer(builder);
  }
}
