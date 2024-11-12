import 'package:easy_rxmvvm/easy_rxmvvm.dart';
import 'package:rxdart/rxdart.dart';

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
    /// 几种写法参考
    /// 如果想控制点击的间隔时间,可以使用throttleTime
    eventDataStreamOf<int>(CounterEvent.increment)
        .throttleTime(const Duration(seconds: 1))
        .withLatestFrom(counter, (t, s) => t + s)
        .bindToSubject(counter)
        .disposeBy(disposeBag);

    onEventData<int>(CounterEvent.decrement, (data) {
      counter.value -= data;
    }).disposeBy(disposeBag);

    eventDataStreamOf(CounterEvent.reset)
        .map((event) => 0)
        .bindToSubject(counter)
        .disposeBy(disposeBag);
  }
}
