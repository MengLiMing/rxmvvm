import 'package:easy_rxmvvm/easy_rxmvvm.dart';
import 'package:rxdart/rxdart.dart';
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
    /// 切换
    onData<bool>(TodoDetailAction.changeCompleted)
        .bindToSubject(isCompleted)
        .disposeBy(disposeBag);

    /// 由TodoListViewModel配置
    configByViewModel<TodoListViewModel>((todoListViewModel) {
      /// 值改变修改
      Rx.combineLatest2(
        title.skip(1).distinct(),
        isCompleted.skip(1).distinct(),
        (a, b) {
          return ToDo(id: id, title: a, isComplete: b);
        },
      ).listen(
        (event) {
          todoListViewModel.dispatch(TodoListAction.update, data: event);
        },
      ).disposeBy(disposeBag);

      /// 初始化赋值
      todoListViewModel.checkTodo(id).take(1).listen((event) {
        title.value = event.title;
        isCompleted.value = event.isComplete;
      }).disposeBy(disposeBag);
    }).disposeBy(disposeBag);
  }
}

extension TodoDetailViewModelInput on TodoDetailViewModel {
  /// 切换
  void changeCompleted(bool value) =>
      dispatch(TodoDetailAction.changeCompleted, data: value);
}
