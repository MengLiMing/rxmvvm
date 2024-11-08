import 'package:easy_rxmvvm/easy_rxmvvm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxmvvm_example/todo/todo_detail/todo_detail_vm.dart';

import '../todo_list/todo_list_page.dart';

class TodoDetailPage extends ViewModelConsumerStatefulWidget {
  final String id;

  const TodoDetailPage({
    super.key,
    required this.id,
  });

  @override
  ViewModelConsumerStateMixin<TodoDetailPage> createState() =>
      _TodoDetailPageState();
}

class _TodoDetailPageState extends State<TodoDetailPage>
    with
        DisposeBagProvider,
        ViewModelConsumerStateMixin<TodoDetailPage>,
        SingleViewModelMixin<TodoDetailViewModel, TodoDetailPage> {
  final titleTextController = TextEditingController();

  @override
  void initState() {
    super.initState();

    viewModel.title
        .syncWithTextController(titleTextController)
        .disposeBy(disposeBag);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('详情'),
      ),
      body: Column(
        children: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                return const TodoListPage();
              }));
            },
            child: const Text('跳转'),
          ),
          TextField(
            controller: titleTextController,
          ),
          StreamBuilderFactory.buildBehavior(
            viewModel.isCompleted,
            builder: (context, value, _) {
              return CupertinoSwitch(
                value: value,
                onChanged: (value) => viewModel.dispatch(
                  TodoDetailAction.changeCompleted,
                  data: value,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  TodoDetailViewModel viewModelCreate() => TodoDetailViewModel(id: widget.id);
}
