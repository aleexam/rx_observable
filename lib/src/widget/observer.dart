import 'package:get/get.dart';

/// Widget that listen to an [observable], build [builder] when its changed
/// and provides [observable] value to builder.
class Observer<T> extends Obx {
  const Observer(super.builder, {super.key});
}