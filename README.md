# easy_rxmvvm

基于 **RxDart** 的 Flutter MVVM 状态管理框架，提供：

- 轻量级的 `ViewModel` 基类与生命周期管理（`ViewModel`、`DisposeBag` 等）
- 便捷的 `ViewModelConsumer` 组件与 mixin，快速搭建 MVVM 页面
- 基于 `BehaviorSubject`/`Stream` 的响应式 UI 构建工具（`StreamOb`、`StreamBuilderFactory`）
- 丰富的扩展方法（`rx_extension`、`dispose_extension` 等），减少样板代码

> 更完整的示例请查看 [example](example) 目录。

## 安装

在你的 Flutter 项目 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  easy_rxmvvm: ^2.0.0
```

然后执行：

```bash
flutter pub get
```

## 快速上手

### 1. 创建 ViewModel

继承 `ViewModel` 或配合 `StateMixin<TState>` 使用（`lib/core/view_model/view_model.dart:1`、`lib/core/view_model/state_view_model_mixin.dart:1`）：

```dart
import 'package:easy_rxmvvm/easy_rxmvvm.dart';

class CounterState {
  final int value;
  const CounterState(this.value);
}

class CounterViewModel extends ViewModel with StateMixin<CounterState> {
  @override
  CounterState get initialState => const CounterState(0);

  void increment() {
    updateState((prev) => CounterState(prev.value + 1));
  }
}
```

### 2. 在页面中使用 ViewModel

推荐使用 `ViewModelState` 快速创建绑定单一 ViewModel 的页面  
（`lib/core/consumer/view_model_state.dart:1`、`lib/core/consumer/view_model_single_mixin.dart:1`）：

```dart
import 'package:easy_rxmvvm/easy_rxmvvm.dart';
import 'package:flutter/material.dart';

class CounterPage extends ViewModelConsumerStatefulWidget {
  const CounterPage({super.key});

  @override
  ViewModelConsumerStateMixin<CounterPage> createState() =>
      _CounterPageState();
}

class _CounterPageState
    extends ViewModelState<CounterPage, CounterViewModel> {
  @override
  CounterViewModel viewModelCreate() => CounterViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: Center(
        child: StreamOb(
          builder: (context, watcher, child) {
            // 通过 stateStream + StreamOb 构建 UI
            final state = viewModel.stateStream.watch(watcher);
            final value = state?.value ?? 0;
            return Text(
              '$value',
              style: const TextStyle(fontSize: 32),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: viewModel.increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### 3. 使用 StreamOb 观察任意 Stream

`StreamOb` 位于 `lib/core/utils/stream_ob.dart:1`，提供一个通用的响应式组件：

```dart
final BehaviorSubject<int> counter =
    BehaviorSubject<int>.seeded(0);

class CounterWithSubject extends StatelessWidget {
  const CounterWithSubject({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamOb(
      builder: (context, watcher, child) {
        // watch 会自动：
        // 1. 订阅当前 Stream（或 ValueStream）
        // 2. 缓存最新值
        // 3. 在值变化时触发重建
        final value = watcher.watch(counter) ?? 0;
        return Text('value = $value');
      },
    );
  }
}
```

> 性能建议：尽量在 ViewModel 中提前定义好派生流（如 `ageStream`），再在 UI 中通过 `watch` 订阅，而不要在 `build` 中临时 `map` 新的 Stream。

### 4. 使用 StreamBuilderFactory（推荐使用 StreamOb）

如果你习惯原生的 `StreamBuilder` 样式，可以使用 `StreamBuilderFactory`（`lib/core/utils/stream_builder_factory.dart:1`）：

```dart
StreamBuilderFactory.buildBehavior<int>(
  viewModel.counterSubject,
  builder: (context, value, child) {
    return Text('value = $value');
  },
);
```

## 代码块（VS Code Snippets）

### VS Code 添加代码块步骤

1. 打开 vsCode
2. 按下快捷键 `Ctrl + Shift + P` 打开命令面板
3. 输入 `Snippets: Configure Snippets` 并选择
4. 选择 `dart.json` 文件
5. 在 `dart.json` 文件中添加下方代码块

```json
{
  "Consumer ViewModel": {
    "prefix": "rxvmConsumers",
    "description": "创建支持提供多个viewModel的StatefulWidget",
    "body": [
      "import 'package:easy_rxmvvm/easy_rxmvvm.dart';",
      "import 'package:flutter/material.dart';",
      "\n",
      "class $1 extends ViewModelConsumerStatefulWidget {",
      "\tconst $1({super.key});",
      "\n",
      "\t@override",
      "\tViewModelConsumerStateMixin<$1> createState() => _$1State();",
      "}\n",
      "class _$1State extends State<$1> with DisposeBagProvider, ViewModelConsumerStateMixin<$1> {",
      "\t@override",
      "\tWidget build(BuildContext context) {",
      "\t\treturn Container();",
      "\t}",
      "\n",
      "\t@override",
      "\t// TODO: implement creaters",
      "\tList<ViewModelFactory<ViewModel>> get creators => throw UnimplementedError();",
      "}"
    ]
  },
  "Consumer SingleViewModel": {
    "prefix": "rxvmConsumer",
    "description": "创建支持提供单个viewModel的StatefulWidget",
    "body": [
      "import 'package:easy_rxmvvm/easy_rxmvvm.dart';",
      "import 'package:flutter/material.dart';",
      "\n",
      "class $1 extends ViewModelConsumerStatefulWidget {",
      "\tconst $1({super.key});",
      "\n",
      "\t@override",
      "\tViewModelConsumerStateMixin<$1> createState() => _$1State();",
      "}\n",
      "class _$1State extends State<$1> with DisposeBagProvider, ViewModelConsumerStateMixin<$1>, SingleViewModelMixin<$2, $1> {",
      "\t@override",
      "\tWidget build(BuildContext context) {",
      "\t\treturn Container();",
      "\t}",
      "\n",
      "\t@override",
      "\t$2 viewModelCreate() => $2();",
      "}"
    ]
  },
  "Consumer RetrieveViewModel": {
    "prefix": "rxvmConsumerRetrive",
    "description": "创建只获取单个viewModel的StatefulWidget",
    "body": [
      "import 'package:easy_rxmvvm/easy_rxmvvm.dart';",
      "import 'package:flutter/material.dart';",
      "\n",
      "class $1 extends ViewModelConsumerStatefulWidget {",
      "\tconst $1({super.key});",
      "\n",
      "\t@override",
      "\tViewModelConsumerStateMixin<$1> createState() => _$1State();",
      "}\n",
      "class _$1State extends State<$1> with DisposeBagProvider, ViewModelConsumerStateMixin<$1>, RetrieveViewModelMixin<$2, $1> {",
      "\t@override",
      "\tWidget build(BuildContext context) {",
      "\t\treturn Container();",
      "\t}",
      "}"
    ]
  },
  "Rxvvm ViewModel Class": {
    "prefix": "rxvmViewModel",
    "description": "创建一个 ViewModel",
    "body": [
      "import 'package:easy_rxmvvm/easy_rxmvvm.dart';",
      "\n",
      "class $1ViewModel extends ViewModel {",
      "\t@override",
      "\tvoid config() {",
      "\t\t// TODO: implement config",
      "\t}",
      "}"
    ]
  },
  "ViewModelFactory Creation": {
    "prefix": "rxvmFactory",
    "description": "创建一个 ViewModelFactory 实例",
    "body": ["ViewModelFactory<$1>(${2:() => $1()})"]
  }
}
```
