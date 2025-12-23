import 'package:collection/collection.dart';
import 'package:easy_rxmvvm/easy_rxmvvm.dart';
import 'package:flutter/foundation.dart';
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
  // 内部私有变量
  final _filter = TodoFilter.all.rx;
  final _todos = <ToDo>[].rx;

  // output
  /// 推荐写法：
  ///
  /// 1. late final: 保证 Stream 对象唯一，防止 StreamBuilder 在 didUpdateWidget 中重复订阅。
  /// 2. distinct: 内容（值）相等时不分发，防止列表未变时的 UI 无效重绘。
  /// 3. shareValue: 将冷流转热，实现逻辑单例化。无论多少个监听者，[_filterLogic] 仅执行一次，
  ///    并支持同步通过 [.value] 访问缓存。
  late final Stream<List<ToDo>> todos = Rx.combineLatest2(
    _filter,
    _todos,
    _filterLogic,
  ).distinct(listEquals).shareValue();

  Stream<TodoFilter> get filter => _filter;

  Stream<ToDo> checkTodo(String id) {
    return todos
        .map((value) => value.firstWhereOrNull((element) => element.id == id))
        .whereNotNull()
        .distinct();
  }

  @override
  void config() {
    /// 增
    on(TodoListAction.add).listen((event) {
      final date = DateTime.now();
      final newToDo = ToDo(id: date.toString(), title: "时间：$date");
      _todos.value = [..._todos.value, newToDo];
    }).disposeBy(disposeBag);

    /// 删
    onData<String>(TodoListAction.delete).listen((id) {
      _todos.value = _todos.value.where((element) => element.id != id).toList();
    }).disposeBy(disposeBag);

    /// 改
    onData<ToDo>(TodoListAction.update).listen((data) {
      _todos.value =
          _todos.value.map((e) => e.id == data.id ? data : e).toList();
    }).disposeBy(disposeBag);

    /// 更新筛选条件
    onData<TodoFilter>(TodoListAction.changeFilter).listen((data) {
      _filter.value = data;
    }).disposeBy(disposeBag);
  }

  List<ToDo> _filterLogic(TodoFilter f, List<ToDo> list) {
    switch (f) {
      case TodoFilter.all:
        return list;
      case TodoFilter.completed:
        return list.where((e) => e.isComplete).toList();
      case TodoFilter.uncompleted:
        return list.where((e) => !e.isComplete).toList();
    }
  }
}

/// 此处通过 [dispatch] 将动作发送至事件流，而非直接在方法内修改逻辑
///
/// 1. 响应式 (推荐):
///    通过 [dispatch] 将意图发送至事件流。其核心价值在于能在 [config] 中利用 Rx 操作符实现
///    节流 (throttle)、防抖 (debounce)、或异步排队 (exhaustMap) 等流式控制。
///
/// 2. 命令式 (可选):
///    如果逻辑非常简单且不需要防抖等流控操作，也可以直接在方法内编写逻辑。
///
/// 总结：使用 [dispatch] 是为了将“动作”转化为“流”，从而享受 RxDart 操作符带来的便捷指令操作。
extension TodoListViewModelInput on TodoListViewModel {
  /// 添加
  void add() => dispatch(TodoListAction.add);

  /// 删除
  void delete(String id) => dispatch(TodoListAction.delete, data: id);

  /// 更新
  void update(ToDo todo) => dispatch(TodoListAction.update, data: todo);

  /// 切换筛选条件
  void changeFilter(TodoFilter? filter) =>
      dispatch(TodoListAction.changeFilter, data: filter);
}
