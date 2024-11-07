import 'package:flutter/material.dart';
import 'package:rxmvvm/rxmvvm.dart';

import 'counter_vm.dart';

/// 计数器demo
class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelConsumer.single(
        creator: ViewModelFactory<CounterViewModel>(
          () => CounterViewModel(),
          shareStrategy: ViewModelShareStrategy.all,
        ),
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('计数器'),
            ),
            body: SizedBox(
              width: double.infinity,
              child: Column(children: [
                StreamBuilderFactory.buildBehavior(
                  viewModel.counter,
                  builder: (context, value, _) {
                    return Text(value.toString());
                  },
                ),
                TextButton(
                  onPressed:
                      viewModel.dispatcher(CounterEvent.increment, data: 1),
                  child: const Text('+'),
                ),
                TextButton(
                  onPressed:
                      viewModel.dispatcher(CounterEvent.increment, data: 10),
                  child: const Text('+10'),
                ),
                TextButton(
                  onPressed:
                      viewModel.dispatcher(CounterEvent.decrement, data: 1),
                  child: const Text('-'),
                ),
                TextButton(
                  onPressed:
                      viewModel.dispatcher(CounterEvent.decrement, data: 10),
                  child: const Text('-10'),
                ),
                TextButton(
                  onPressed: viewModel.dispatcher(CounterEvent.reset),
                  child: const Text('重置'),
                ),
              ]),
            ),
          );
        });
  }
}
