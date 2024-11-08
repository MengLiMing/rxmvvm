// ignore_for_file: avoid_print, unused_local_variable

import 'package:easy_rxmvvm/easy_rxmvvm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxmvvm_example/inherited/a_vm.dart';
import 'package:rxmvvm_example/inherited/b_vm.dart';
import 'package:rxmvvm_example/inherited/child_widget.dart';
import 'package:rxmvvm_example/inherited/inherited_push_page.dart';
import 'package:rxmvvm_example/vm/login_vm.dart';

class InheritedPage extends ViewModelConsumerStatefulWidget {
  const InheritedPage({super.key});

  @override
  ViewModelConsumerStateMixin<InheritedPage> createState() =>
      _InheritedPageState();
}

class _InheritedPageState extends State<InheritedPage>
    with DisposeBagProvider, ViewModelConsumerStateMixin<InheritedPage> {
  @override
  Widget build(BuildContext context) {
    final loginViewModel = context.getViewModel<LoginManagerViewModel>()!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('共享Model'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              const Spacer(),
              const Text("修改登录状态："),
              StreamBuilderFactory.buildBehavior(
                loginViewModel.isLogin,
                builder: (context, value, _) {
                  return CupertinoSwitch(
                      value: value,
                      onChanged: (value) {
                        value
                            ? loginViewModel.dispatch(LoginManagerAction.login)
                            : loginViewModel
                                .dispatch(LoginManagerAction.logout);
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
        ],
      ),
    );
  }

  @override
  List<ViewModelFactory<ViewModel>> get creators => [
        ViewModelFactory<AViewModel>(() => AViewModel(),
            shareStrategy: ViewModelShareStrategy.provider),
        ViewModelFactory<BViewModel>(
          () => BViewModel(),
          shareStrategy: ViewModelShareStrategy.stack,
        ),
      ];
}
