import 'package:easy_rxmvvm/easy_rxmvvm.dart';

enum CounterEvent {
  increment,
  decrement,
  reset,
}

class CounterViewModel extends ViewModel
    with DispatchActionMixin<CounterEvent> {
  final counter = 0.rx;

  @override
  void config() {
    onEventData<int>(CounterEvent.increment, (data) {
      counter.value += data;
    }).disposeBy(disposeBag);

    onEventData<int>(CounterEvent.decrement, (data) {
      counter.value -= data;
    }).disposeBy(disposeBag);

    onEventOnly(CounterEvent.reset, () {
      counter.value = 0;
    }).disposeBy(disposeBag);
  }
}
