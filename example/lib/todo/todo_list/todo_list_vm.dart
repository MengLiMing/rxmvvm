import 'package:easy_rxmvvm/easy_rxmvvm.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxmvvm_example/todo/model/todo_model.dart';

enum TodoListAction {
  add,
  delete,
  update,
  changeFilter,
}

enum TodoFilter {
  all,
  completed,
  uncompleted,
}

class TodoListViewModel extends ViewModel
    with DispatchActionMixin<TodoListAction> {
  final filter = TodoFilter.all.rx;

  final _todos = <ToDo>[].rx;

  Stream<List<ToDo>> get todos => Rx.combineLatest2(filter, _todos, (a, b) {
        switch (a) {
          case TodoFilter.all:
            return b;
          case TodoFilter.completed:
            return b.where((element) => element.isComplete).toList();
          case TodoFilter.uncompleted:
            return b.where((element) => !element.isComplete).toList();
        }
      });

  Stream<ToDo> checkTodo(String id) {
    return todos
        .map((value) => value.firstWhere((element) => element.id == id));
  }

  @override
  void config() {
    [
      eventActionStream.log(tag: "TodoListAction").emptyListen(),

      onEvent(TodoListAction.add, (action) {
        final date = DateTime.now();
        final newToDo = ToDo(id: date.toString(), title: "时间：$date");
        _todos.value = [..._todos.value, newToDo];
      }),

      /// 新增
      onEventData<String>(TodoListAction.add, (data) {}),

      /// 更新
      onEventData<ToDo>(TodoListAction.update, (data) {
        /// 查找到id相同的item 然后替换
        _todos.value =
            _todos.value.map((e) => e.id == data.id ? data : e).toList();
      }),

      /// 删除
      onEventData<String>(TodoListAction.delete, (id) {
        _todos.value =
            _todos.value.where((element) => element.id != id).toList();
      }),

      /// 更新筛选条件
      onEventData<TodoFilter>(TodoListAction.changeFilter, (data) {
        filter.value = data;
      })
    ].disposeBy(disposeBag);
  }
}
