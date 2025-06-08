import 'package:flutter/material.dart';

import '../core/observable.dart';
import '../../widgets.dart';

extension ObserverWidgetExt<T> on Observable<T> {
  Widget observerWidget(Widget Function(T v) builder) {
    return Observer<T>(this, builder);
  }

  Widget obW(Widget Function(T v) builder) {
    return observerWidget(builder);
  }
}
