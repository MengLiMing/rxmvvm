import 'package:easy_rxmvvm/easy_rxmvvm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:rxmvvm_example/bind/bind_vm.dart';

class BindPage extends ViewModelConsumerStatefulWidget {
  const BindPage({super.key});

  @override
  ViewModelConsumerStateMixin<BindPage> createState() => _BindPageState();
}

class _BindPageState extends State<BindPage>
    with
        DisposeBagProvider,
        ViewModelConsumerStateMixin<BindPage>,
        SingleViewModelMixin<BindViewModel, BindPage> {
  final nameController = TextEditingController();
  final addressController = TextEditingController();

  @override
  void initState() {
    super.initState();

    [
      viewModel.name.syncWithTextController(nameController), // 双向绑定
      viewModel.address.syncWithTextController(addressController),
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
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '姓名'),
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: '地址'),
            ),
            StreamBuilderFactory.buildBehavior(
              viewModel.age,
              builder: (context, value, _) {
                return Slider(
                  value: value,
                  onChanged: viewModel.dispatcherWithData(BindAction.updateAge),
                  max: 100,
                  min: 0,
                );
              },
            ),
            StreamBuilderFactory.build(
              stream: viewModel.isCommitEnable,
              builder: (context, isEnable, _) {
                return TextButton(
                  onPressed: (isEnable ?? false)
                      ? () => viewModel.dispatch(BindAction.commit)
                      : null,
                  child: const Text('提交'),
                );
              },
            ),
            TextButton(
              onPressed: () => viewModel.dispatch(BindAction.reset),
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
