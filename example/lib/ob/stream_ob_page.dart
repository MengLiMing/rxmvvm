import 'package:easy_rxmvvm/easy_rxmvvm.dart';
import 'package:flutter/material.dart';

import 'stream_ob_vm.dart';

/// 示例页面：演示使用 StreamOb 订阅与渲染
class StreamObPage extends ViewModelConsumerStatefulWidget {
  /// 构建示例页面
  const StreamObPage({super.key});

  @override
  ViewModelConsumerStateMixin<StreamObPage> createState() =>
      _StreamObPageState();
}

class _StreamObPageState
    extends ViewModelState<StreamObPage, StreamObViewModel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('StreamOb 示例')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamOb(
          builder: (ctx, watch, child) {
            // 使用稳定的去重流，并传入 initial 以避免初次渲染为 null
            final count = watch.value(viewModel.counter);
            final evenCount = watch(viewModel.evenCounter, initial: 0);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('当前计数：$count'),
                const SizedBox(height: 8),
                Text('偶数计数：$evenCount'),
                const SizedBox(height: 16),
                Row(children: [
                  ElevatedButton(
                    onPressed: () => viewModel.increment(1),
                    child: const Text('+1'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => viewModel.increment(10),
                    child: const Text('+10'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: viewModel.reset,
                    child: const Text('重置'),
                  ),
                ]),
                const SizedBox(height: 16),
                child ?? const Text('静态内容，不随计数变化重建'),
              ],
            );
          },
          child: const Text('静态内容'),
        ),
      ),
    );
  }

  @override
  StreamObViewModel viewModelCreate() => StreamObViewModel();
}
