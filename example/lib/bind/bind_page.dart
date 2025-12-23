import 'package:easy_rxmvvm/easy_rxmvvm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:rxmvvm_example/bind/bind_vm.dart';

class BindPage extends ViewModelConsumerStatefulWidget {
  const BindPage({super.key});

  @override
  ViewModelConsumerStateMixin<BindPage> createState() => _BindPageState();
}

class _BindPageState extends ViewModelState<BindPage, BindViewModel> {
  final nameController = TextEditingController();
  final addressController = TextEditingController();

  @override
  void initState() {
    super.initState();

    [
      viewModel.stateStream.map((event) => event.name).syncWithTextController(
          nameController,
          onUpdate: viewModel.updateName),
      viewModel.stateStream
          .map((event) => event.address)
          .syncWithTextController(addressController,
              onUpdate: viewModel.updateAddress),
    ].disposeBy(disposeBag);

    [
      viewModel.onLoadingState((value) {
        value ? EasyLoading.show() : EasyLoading.dismiss();
      }, initialValue: false),
      viewModel.commitResult.listen((value) {
        EasyLoading.showToast(value ? "提交成功" : "提交失败");
      })
    ].disposeBy(disposeBag);
  }

  /// 测试刷新次数
  var ageRefreshCount = 0;
  var stateRefreshCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('双向绑定'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            StreamOb(builder: (context, watcher, _) {
              final _ = viewModel.stateStream.watchBy(watcher);
              stateRefreshCount++;
              return Text('state刷新次数：$stateRefreshCount');
            }),
            StreamOb(builder: (context, watcher, _) {
              /// 监听 age 的三种常见写法 —— 性能差异显著，请仔细阅读！
              ///
              /// StreamOb 的智能去重依赖于 Stream 实例 + selector 函数引用的 identical 比较。
              /// 只有使用 ViewModel 中预定义的固定成员变量，才能保证订阅键完全稳定，
              /// 从而实现“只订阅一次、只在真实变化时 rebuild”的最佳性能。
              ///
              /// 1. 最差（强烈禁止）：临时 .map() 创建新 Stream 实例
              ///    每次 build 都会生成全新的 MapStream 对象，导致订阅键不同。
              ///    后果：旧订阅被取消 → 新订阅创建 → 新 Stream 初始无值 → 收到值后触发“假变化”
              ///          即使 age 未实际变化，也会导致 builder 反复执行（刷新计数疯狂增加）
              // final age = viewModel.stateStream
              //     .map((event) => event.age)
              //     .watchBy(watcher);

              /// 2. 可以使用：临时匿名 selector
              ///    每次 build 都会创建一个新的匿名函数，导致 selectorFn 不 identical。
              ///    后果：会重复取消旧订阅并创建新订阅
              ///    但由于 BehaviorSubject 是 hot stream，新订阅能立即拿到最新值，
              ///    当值未实际变化时不会触发额外 rebuild，因此 UI 表现通常正常。
              // final age =
              //     viewModel.stateStream.selectBy(watcher, (state) => state.age);

              /// 3. 强烈推荐：使用 ViewModel 中预定义的派生 Stream
              ///    ageStream 是固定成员变量，Stream 实例终身不变。
              ///    订阅键完全稳定 → 只订阅一次 → 只在 age 真正变化时 rebuild。
              ///    性能最佳，无任何额外开销。
              final age = viewModel.ageStream.watchBy(watcher);
              // 或更清晰的等价写法
              // final age = watcher.watchValue(viewModel.ageStream);

              ageRefreshCount++;
              return Text('age: $age  age刷新次数：$ageRefreshCount');
            }),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '姓名'),
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: '地址'),
            ),
            StreamOb(builder: (context, watcher, _) {
              final age =
                  viewModel.stateStream.selectBy(watcher, (state) => state.age);
              return Slider(
                value: age,
                onChanged: viewModel.updateAge,
                max: 100,
                min: 0,
              );
            }),
            StreamOb(
              builder: (context, watcher, _) {
                final isEnable = viewModel.isCommitEnable.watchBy(watcher);
                return TextButton(
                  onPressed: isEnable ? viewModel.commit : null,
                  child: const Text('提交'),
                );
              },
            ),
            TextButton(
              onPressed: viewModel.reset,
              child: const Text('重置'),
            )
          ],
        ),
      ),
    );
  }

  @override
  BindViewModel viewModelCreate() => BindViewModel();
}
