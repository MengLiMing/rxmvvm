import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxmvvm/rxmvvm.dart';
import 'package:rxmvvm_example/inherited/child_widget.dart';
import 'package:rxmvvm_example/vm/login_vm.dart';

class InheritedPushPage extends ViewModelConsumerStatefulWidget {
  const InheritedPushPage({super.key});

  @override
  ViewModelConsumerStateMixin<InheritedPushPage> createState() =>
      _InheritedPushPageState();
}

class _InheritedPushPageState extends State<InheritedPushPage>
    with
        DisposeBagProvider,
        ViewModelConsumerStateMixin<InheritedPushPage>,
        RetrieveViewModelMixin<LoginManagerViewModel, InheritedPushPage> {
  @override
  Widget build(BuildContext context) {
    /// 一个 Push 页，用于演示共享的 ViewModel
    ///
    /// 该页可以修改共享的 ViewModel 的状态，并且可以在子 Widget 中使用共享的 ViewModel
    ///
    /// 该页还提供了一个跳转到下一个 Push 页的按钮
    ///
    return Scaffold(
      appBar: AppBar(
        title: const Text('共享Model的Push页'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              const Spacer(),
              const Text("修改登录状态："),
              StreamBuilderFactory.buildBehavior(
                viewModel!.isLogin,
                builder: (context, value, _) {
                  return CupertinoSwitch(
                      value: value,
                      onChanged: (value) {
                        value
                            ? viewModel?.dispatch(LoginManagerAction.login)
                            : viewModel?.dispatch(LoginManagerAction.logout);
                      });
                },
              ),
              const Spacer(),
            ],
          ),
          const InheritedChildWidget(),
          TextButton(
            child: const Text('跳转'),
            onPressed: () {
              Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                return const InheritedPushPage();
              }));
            },
          ),
          TextButton(
            child: const Text('回到根目录'),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }
}
