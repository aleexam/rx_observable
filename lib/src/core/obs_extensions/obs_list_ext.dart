import '../observable.dart';

extension ObservableListExt<T> on Observable<List<T>> {
  void addOne(T item) {
    value.add(item);
    refresh();
  }

  void addAll(List<T> items) {
    value.addAll(items);
    refresh();
  }

  void insert(int index, T item) {
    value.insert(index, item);
    refresh();
  }

  void insertAll(int index, List<T> items) {
    value.insertAll(index, items);
    refresh();
  }

  void update(int index, T newItem) {
    if (!notifyOnlyIfChanged || newItem != value[index]) {
      value[index] = newItem;
      refresh();
    }
  }

  bool remove(T item) {
    var result = value.remove(item);
    refresh();
    return result;
  }

  T removeAt(int index) {
    var result = value.removeAt(index);
    refresh();
    return result;
  }

  T removeLast() {
    var result = value.removeLast();
    refresh();
    return result;
  }

  void removeRange(int start, int end) {
    value.removeRange(start, end);
    refresh();
  }

  void removeWhere(bool Function(T) test) {
    value.removeWhere(test);
    refresh();
  }
}
