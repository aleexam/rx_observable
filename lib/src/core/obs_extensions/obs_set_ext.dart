import '../observable.dart';

extension ObservableSetExt<T> on Observable<Set<T>> {
  void addOne(T item) {
    value.add(item);
    refresh();
  }

  void addAll(List<T> items) {
    value.addAll(items);
    refresh();
  }

  bool remove(T item) {
    var result = value.remove(item);
    refresh();
    return result;
  }

  void removeWhere(bool Function(T) test) {
    value.removeWhere(test);
    refresh();
  }
}
