import 'core/observable.dart';
import '../widgets.dart';

typedef Obs<T> = Observable<T>;
typedef ObservableRead<T> = ObservableReadOnly<T>;
typedef ObsRead<T> = ObservableReadOnly<T>;

typedef ObsComputed<T> = ObservableComputed<T>;

typedef ObW<T> = Observer<T>;
typedef Obl<T> = ObservableListener<T>;
typedef Obc<T> = ObservableConsumer<T>;

typedef ObservableDouble = Observable<double>;
typedef ObservableNullableDouble = Observable<double?>;

typedef ObsString = ObservableString;
typedef ObsNString = ObservableNullableString;
typedef ObsDouble = Observable<double>;
typedef ObsNDouble = Observable<double?>;
typedef ObsInt = ObservableInt;
typedef ObsNInt = ObservableNullableInt;
typedef ObsNum = ObservableNum;
typedef ObsNNum = ObservableNullableNum;
