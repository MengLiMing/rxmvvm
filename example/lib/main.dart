// ignore_for_file: avoid_print

import 'package:easy_rxmvvm/easy_rxmvvm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxmvvm_example/bind/bind_page.dart';
import 'package:rxmvvm_example/event_bus/event_bus_page.dart';
import 'package:rxmvvm_example/paging/paging_page.dart';
import 'package:rxmvvm_example/todo/todo_list/todo_list_page.dart';
import 'package:rxmvvm_example/vm/login_vm.dart';

import 'counter/counter_page.dart';
import 'inherited/inherited_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  get demoList => [
        DemoItem("共享", (context) => const InheritedPage()),
        DemoItem("计数器", (context) => const CounterPage()),
        DemoItem("双向绑定 & StreamOb", (context) => const BindPage()),
        DemoItem("分页请求", (context) => const PagingPage()),
        DemoItem("EventBus", (context) => const EventBusPage()),
        DemoItem("TodoList", (context) => const TodoListPage()),
      ];

  final a = PublishSubject<int>();

  @override
  Widget build(BuildContext context) {
    return ViewModelConsumer(
      creators: [
        ViewModelFactory<LoginManagerViewModel>(() => LoginManagerViewModel())
      ],
      shareStrategy: ViewModelShareStrategy.provider,
      builder: (context, child) {
        final loginViewModel = context.getViewModel<LoginManagerViewModel>();
        if (loginViewModel == null) {
          return const SizedBox.shrink();
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: EasyLoading.init(),
          home: Scaffold(
            appBar: AppBar(
              title: StreamBuilderFactory.buildBehavior(loginViewModel.isLogin,
                  builder: (context, value, _) {
                return Text('登录状态: ${value ? '已登录' : '未登录'}');
              }),
            ),
            body: ListView.builder(
              itemBuilder: (context, index) {
                final item = demoList[index];
                return ListTile(
                  title: Text(item.title),
                  onTap: () => item.push(context),
                );
              },
              itemCount: demoList.length,
            ),
          ),
        );
      },
    );
  }
}

class DemoItem {
  final String title;
  final WidgetBuilder builder;

  DemoItem(this.title, this.builder);

  void push(BuildContext context) {
    Navigator.of(context).push(CupertinoPageRoute(builder: builder));
  }
}
