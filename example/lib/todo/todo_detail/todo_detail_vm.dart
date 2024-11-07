import 'package:rxdart/rxdart.dart';
import 'package:rxmvvm/rxmvvm.dart';
import 'package:rxmvvm_example/todo/model/todo_model.dart';
import 'package:rxmvvm_example/todo/todo_list/todo_list_vm.dart';

enum TodoDetailAction {
  changeCompleted,
}

class TodoDetailViewModel extends ViewModel
    with DispatchActionMixin<TodoDetailAction> {
  final String id;

  TodoDetailViewModel({
    required this.id,
  });

  final title = "".rx;
  final isCompleted = false.rx;

  @override
  void config() {
    [
      dispatchLogger,

      /// 切换
      streamEventDataWhere<bool>(TodoDetailAction.changeCompleted)
          .bindToSubject(isCompleted),

      /// 由TodoListViewModel配置
      configByViewModel<TodoListViewModel>((todoListViewModel) {
        Rx.combineLatest2(title.distinct(), isCompleted.distinct(), (a, b) {
          return ToDo(id: id, title: a, isComplete: b);
        }).listen((event) {
          todoListViewModel.dispatch(TodoListAction.update, data: event);
        }).disposeBy(disposeBag);

        todoListViewModel.checkTodo(id).take(1).listen((event) {
          title.value = event.title;
          isCompleted.value = event.isComplete;
        }).disposeBy(disposeBag);
      })
    ];
  }
}