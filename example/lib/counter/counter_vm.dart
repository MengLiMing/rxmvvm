import 'package:rxmvvm/rxmvvm.dart';

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
    /// 开启打印日志
    dispatchLogger.disposeBy(disposeBag);

    onEventData<int>(CounterEvent.increment, (value) {
      counter.value += value;
    }).disposeBy(disposeBag);

    onEventData<int>(CounterEvent.decrement, (value) {
      counter.value -= value;
    }).disposeBy(disposeBag);

    onEvent(CounterEvent.reset, (event) {
      counter.value = 0;
    }).disposeBy(disposeBag);
  }
}
