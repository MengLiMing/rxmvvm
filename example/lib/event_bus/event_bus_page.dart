import 'package:easy_rxmvvm/easy_rxmvvm.dart';
import 'package:flutter/material.dart';

/// StatefulWidget系列
class EventBusPage extends StatefulWidget {
  const EventBusPage({super.key});

  @override
  State<EventBusPage> createState() => _EventBusPageState();
}

class _EventBusPageState extends State<EventBusPage> with DisposeBagProvider {
  @override
  void dispose() {
    disposeBag.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelConsumer.single(
      creator: ViewModelFactory<EventBusDemo>(() => EventBusDemo()),
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("EventBus"),
          ),
          body: Center(
            child: Column(
              children: [
                StreamOb(builder: (context, watcher, _) {
                  final action = viewModel.eventActionValue.watchBy(watcher);
                  if (action == null) {
                    return const Text("暂未收到event");
                  }
                  return Text("收到event: ${action.event}, data: ${action.data}");
                }),
                StreamBuilderFactory.buildBehavior(
                  viewModel.counter,
                  builder: (context, value, _) {
                    return Text("数字1111消息次数统计: $value");
                  },
                ),
                const EventBusDemo1Widget(),
                const EventBusDemo2Widget(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class EventBusDemo extends ViewModel {
  final counter = 0.rx;

  late final eventAction = EventBus.onEventStream<DemoEvent>();

  late final eventActionValue =
      EventBus.onEventStream<DemoEvent>().cast<EventAction<DemoEvent>?>();

  @override
  void config() {
    EventBus.onDataListen<DemoEvent, int>(DemoEvent.number, (value) {
      counter.value += 1;
    }).disposeBy(disposeBag);
  }
}

class EventBusDemo1Widget extends StatelessWidget {
  const EventBusDemo1Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        EventBus.dispatch(DemoEvent.aaaa, data: "aaaa");
      },
      child: const Text('发送aaaa'),
    );
  }
}

class EventBusDemo2Widget extends StatelessWidget {
  const EventBusDemo2Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        EventBus.dispatch(DemoEvent.number, data: 1111);
      },
      child: const Text('发送1111'),
    );
  }
}

enum DemoEvent {
  aaaa,
  number,
}
