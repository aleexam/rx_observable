import '../widgets.dart';
import 'core/observable.dart';

typedef Obs<T> = Observable<T>;
typedef ObservableRead<T> = ObservableReadOnly<T>;
typedef ObsRead<T> = ObservableReadOnly<T>;

typedef ObsComputed<T> = ObservableComputed<T>;

typedef Obx<T> = Observer<T>;
typedef Obl<T> = ObservableListener<T>;
typedef Obc<T> = ObservableConsumer<T>;