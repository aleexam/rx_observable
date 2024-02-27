import 'package:flutter/material.dart';
import 'package:rx_observable/rx_observable.dart';
import 'package:rx_observable/src/widget/observer.dart';

extension ObserverWidgetExt<T> on Observable<T> {
  Widget observer(Widget? Function(T v) builder) {
    return Observer<T>(this, builder);
  }

  Widget obW(Widget? Function(T v) builder) {
    return observer(builder);
  }
}
