import '../observable.dart';

extension ObservableMapExt<T, T2> on Observable<Map<T, T2>> {
  void put(T key, T2 newItem) {
    if (!notifyOnlyIfChanged || newItem != value[key]) {
      value[key] = newItem;
      notifyListeners();
    }
  }

  T2? remove(T item) {
    var result = value.remove(item);
    notifyListeners();
    return result;
  }

  void removeWhere(bool Function(T, T2) test) {
    value.removeWhere(test);
    notifyListeners();
  }
}
