import '../observable.dart';

extension ObservableListExt<T> on Observable<List<T>> {
  void addOne(T item) {
    value.add(item);
    notifyListeners();
  }

  void addAll(List<T> items) {
    value.addAll(items);
    notifyListeners();
  }

  void insert(int index, T item) {
    value.insert(index, item);
    notifyListeners();
  }

  void insertAll(int index, List<T> items) {
    value.insertAll(index, items);
    notifyListeners();
  }

  void update(int index, T newItem) {
    if (!notifyOnlyIfChanged || newItem != value[index]) {
      value[index] = newItem;
      notifyListeners();
    }
  }

  bool remove(T item) {
    var result = value.remove(item);
    notifyListeners();
    return result;
  }

  T removeAt(int index) {
    var result = value.removeAt(index);
    notifyListeners();
    return result;
  }

  T removeLast() {
    var result = value.removeLast();
    notifyListeners();
    return result;
  }

  void removeRange(int start, int end) {
    value.removeRange(start, end);
    notifyListeners();
  }

  void removeWhere(bool Function(T) test) {
    value.removeWhere(test);
    notifyListeners();
  }
}
