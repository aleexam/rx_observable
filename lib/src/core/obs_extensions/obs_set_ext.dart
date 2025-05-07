import '../observable.dart';

extension ObservableSetExt<T> on Observable<Set<T>> {
  void addOne(T item) {
    value.add(item);
    notifyListeners();
  }

  void addAll(List<T> items) {
    value.addAll(items);
    notifyListeners();
  }

  bool remove(T item) {
    var result = value.remove(item);
    notifyListeners();
    return result;
  }

  void removeWhere(bool Function(T) test) {
    value.removeWhere(test);
    notifyListeners();
  }
}
