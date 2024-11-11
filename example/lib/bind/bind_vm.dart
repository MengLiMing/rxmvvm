import 'package:easy_rxmvvm/easy_rxmvvm.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxmvvm_example/rxmvvm_util/loading_mixin.dart';

enum BindAction {
  commit,

  updateAge,

  reset
}

class BindViewModel extends ViewModel
    with DispatchActionMixin<BindAction>, LoadingMixin<bool>, EventBusMixin {
  final name = "".rx;

  final address = "".rx;

  final age = 0.0.rx;

  /// 请求结果
  final commitResult = PublishSubject<bool>();

  /// 是否可以点击
  Stream<bool> get isCommitEnable => Rx.combineLatest3(
      name, address, age, (a, b, c) => a.isNotEmpty && b.isNotEmpty && c >= 18);

  @override
  void config() {
    [
      /// 提交并绑定到提交结果
      filterEvent(BindAction.commit)
          .throttleTime(const Duration(milliseconds: 200))
          .withLatestFrom3(name, address, age, (t, a, b, c) => (a, b, c))
          .asyncMap((event) async {
        setLoading(true);
        await Future.delayed(const Duration(seconds: 3));
        setLoading(false);
        return true;
      }).bindToSubject(commitResult),

      /// 更新年龄
      onEventData<double>(BindAction.updateAge, (value) {
        age.value = value;
      }),

      /// 重置
      onEventOnly(BindAction.reset, () {
        name.value = "";
        address.value = "";
        age.value = 0.0;
      })
    ].disposeBy(disposeBag);
  }
}
