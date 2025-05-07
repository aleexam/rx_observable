part of 'observable.dart';

class ObservableSubscription implements ICancelable {
  final void Function() _cancel;

  ObservableSubscription(this._cancel);

  @override
  void cancel() => _cancel();
}
