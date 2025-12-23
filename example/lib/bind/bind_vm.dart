import 'package:easy_rxmvvm/easy_rxmvvm.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxmvvm_example/bind/bind_state.dart';
import 'package:rxmvvm_example/rxmvvm_util/loading_mixin.dart';

enum BindAction {
  commit,

  updateAge,

  reset
}

class BindViewModel extends ViewModel
    with
        StateMixin<BindState>,
        DispatchActionMixin<BindAction>,
        LoadingMixin<bool> {
  @override
  BindState get initialState => const BindState(age: 18);

  final _commitResult = PublishSubject<bool>();

  Stream<bool> get commitResult => _commitResult.stream;

  late final isCommitEnable = stateStream
      .map((event) => event.isComplete)
      .shareValueSeeded(state.isComplete);

  // late final ageStream =
  //     stateStream.map((event) => event.age).shareValueSeeded(0);
  late final ageStream =
      stateStream.map((event) => event.age).shareValueSeeded(state.age);

  @override
  void config() {
    on(BindAction.commit)
        .throttleTime(const Duration(milliseconds: 500)) // 防抖/节流
        .withLatestFrom(stateStream, (_, s) => s)
        .asyncMap((state) async {
          setLoading(true);
          // 模拟请求
          await Future.delayed(const Duration(seconds: 3));
          setLoading(false);
          return true;
        })
        .bindToSubject(_commitResult) // 结果发送到结果流
        .disposeBy(disposeBag);

    /// 更新年龄
    onData<double>(BindAction.updateAge)
        .listen((event) => updateState((prev) => prev.copyWith(age: event)))
        .disposeBy(disposeBag);

    /// 重置数据
    on(BindAction.reset)
        .map((event) => initialState)
        .bindToSubject(stateSink)
        .disposeBy(disposeBag);
  }
}

extension BindViewModelInput on BindViewModel {
  /// 提交
  void commit() {
    dispatch(BindAction.commit);
  }

  /// 更新年龄
  void updateAge(double value) => dispatch(BindAction.updateAge, data: value);

  /// 重置
  void reset() => dispatch(BindAction.reset);

  void updateName(String value) =>
      updateState((prev) => prev.copyWith(name: value));

  void updateAddress(String value) =>
      updateState((prev) => prev.copyWith(address: value));
}
