// coverage:ignore-line
import 'core/observable.dart';
import '../widgets.dart';

typedef Obs<T> = Observable<T>;
typedef ObsA<T> = ObservableAsync<T>;
typedef ObservableRead<T> = ObservableReadOnly<T>;
typedef ObservableReadA<T> = ObservableAsyncReadOnly<T>;
typedef ObsRead<T> = ObservableReadOnly<T>;
typedef ObsReadA<T> = ObservableAsyncReadOnly<T>;

typedef ObsComputed<T> = ObservableComputed<T>;
typedef ObsGroup = ObservableGroup;

typedef ObW<T> = Observer<T>;
typedef Obl<T> = ObservableListener<T>;
typedef Obc<T> = ObservableConsumer<T>;

typedef ObservableString = Observable<String>;
typedef ObservableNullableString = Observable<String?>;
typedef ObservableInt = Observable<int>;
typedef ObservableNullableInt = Observable<int?>;
typedef ObservableDouble = Observable<double>;
typedef ObservableNullableDouble = Observable<double?>;
typedef ObservableNum = Observable<num>;
typedef ObservableNullableNum = Observable<num?>;
typedef ObservableBool = Observable<bool>;
typedef ObservableNullableBool = Observable<bool?>;

typedef ObservableAsyncString = ObservableAsync<String>;
typedef ObservableAsyncNullableString = ObservableAsync<String?>;
typedef ObservableAsyncInt = ObservableAsync<int>;
typedef ObservableAsyncNullableInt = ObservableAsync<int?>;
typedef ObservableAsyncDouble = ObservableAsync<double>;
typedef ObservableAsyncNullableDouble = ObservableAsync<double?>;
typedef ObservableAsyncNum = ObservableAsync<num>;
typedef ObservableAsyncNullableNum = ObservableAsync<num?>;
typedef ObservableAsyncBool = ObservableAsync<bool>;
typedef ObservableAsyncNullableBool = ObservableAsync<bool?>;

typedef ObsString = ObservableString;
typedef ObsNString = ObservableNullableString;
typedef ObsStringA = ObservableAsyncString;
typedef ObsNStringA = ObservableAsyncNullableString;
typedef ObsDouble = ObservableDouble;
typedef ObsNDouble = ObservableNullableDouble;
typedef ObsDoubleA = ObservableAsyncDouble;
typedef ObsNDoubleA = ObservableAsyncNullableDouble;
typedef ObsInt = ObservableInt;
typedef ObsNInt = ObservableNullableInt;
typedef ObsIntA = ObservableAsyncInt;
typedef ObsNIntA = ObservableAsyncNullableInt;
typedef ObsNum = ObservableNum;
typedef ObsNNum = ObservableNullableNum;
typedef ObsNumA = ObservableAsyncNum;
typedef ObsNNumA = ObservableAsyncNullableNum;
typedef ObsBool = ObservableBool;
typedef ObsNBool = ObservableNullableBool;
typedef ObsBoolA = ObservableAsyncBool;
typedef ObsNBoolA = ObservableAsyncNullableBool;

/// Creates unmodifiable Observable List
Observable<List<T>> obsListUnmodifiable<T>(List<T> list) {
  return Observable<List<T>>(List.unmodifiable(list));
}

/// Creates unmodifiable ObservableAsync List
ObservableAsync<List<T>> obsListUnmodifiableA<T>(List<T> list) {
  return ObservableAsync<List<T>>(List.unmodifiable(list));
}

/// Creates unmodifiable Observable List. Short-named
Observable<List<T>> obsListUnMod<T>(List<T> list) {
  return obsListUnmodifiable<T>(list);
}

/// Creates unmodifiable ObservableAsync List. Short-named
ObservableAsync<List<T>> obsListUnModA<T>(List<T> list) {
  return obsListUnmodifiableA<T>(list);
}
