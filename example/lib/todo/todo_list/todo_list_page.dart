// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:easy_rxmvvm/easy_rxmvvm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxmvvm_example/todo/todo_detail/todo_detail_page.dart';
import 'package:rxmvvm_example/todo/todo_list/todo_list_vm.dart';

class TodoListPage extends ViewModelConsumerStatefulWidget {
  const TodoListPage({super.key});

  @override
  ViewModelConsumerStateMixin<TodoListPage> createState() =>
      _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage>
    with
        DisposeBagProvider,
        ViewModelConsumerStateMixin<TodoListPage>,
        SingleViewModelMixin<TodoListViewModel, TodoListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: Column(
        children: [
          filterWidget(),
          // TextButton(
          //     onPressed: () {
          //       Navigator.of(context)
          //           .push(CupertinoPageRoute(builder: (context) {
          //         return TodoListPage();
          //       }));
          //     },
          //     child: Text('跳转')),
          Expanded(
            child: StreamBuilderFactory.build(
              stream: viewModel.todos,
              builder: (context, _list, _) {
                final list = _list ?? [];
                return ListView.builder(
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return Dismissible(
                      key: ValueKey(item.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (_) {
                        viewModel.dispatch(TodoListAction.delete,
                            data: item.id);
                      },
                      child: ListTile(
                        title: Text(item.title),
                        trailing: CupertinoSwitch(
                            value: item.isComplete,
                            onChanged: (value) => viewModel.dispatch(
                                TodoListAction.update,
                                data: item.copyWith(isComplete: value))),
                        onTap: () {
                          Navigator.of(context)
                              .push(CupertinoPageRoute(builder: (context) {
                            return TodoDetailPage(id: item.id);
                          }));
                        },
                      ),
                    );
                  },
                  itemCount: list.length,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => viewModel.dispatch(TodoListAction.add),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget filterWidget() {
    return StreamBuilderFactory.buildBehavior(viewModel.filter,
        builder: (context, value, _) {
      return DropdownButton<TodoFilter>(
        value: value,
        items: TodoFilter.values.map((TodoFilter filter) {
          return DropdownMenuItem<TodoFilter>(
            value: filter,
            child: Text(filterToString(filter)),
          );
        }).toList(),
        onChanged: (filter) =>
            viewModel.dispatch(TodoListAction.changeFilter, data: filter),
      );
    });
  }

  String filterToString(TodoFilter filter) {
    switch (filter) {
      case TodoFilter.all:
        return '所有';
      case TodoFilter.completed:
        return '已完成';
      case TodoFilter.uncompleted:
        return '未完成';
    }
  }

  @override
  TodoListViewModel viewModelCreate() => TodoListViewModel();

  @override
  ViewModelShareStrategy get shareStrategy => ViewModelShareStrategy.all;
}
