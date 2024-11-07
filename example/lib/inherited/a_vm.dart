// ignore_for_file: avoid_print

import 'package:rxmvvm/rxmvvm.dart';
import 'package:rxmvvm_example/inherited/b_vm.dart';
import 'package:rxmvvm_example/vm/login_vm.dart';

class AViewModel extends ViewModel {
  @override
  void config() {
    configByViewModel<LoginManagerViewModel>((value) {
      print("AViewModel - 获取到了LoginManagerViewModel");
    }).disposeBy(disposeBag);

    configByViewModel<BViewModel>((value) {
      print("AViewModel - 获取到了BViewModel");
    }).disposeBy(disposeBag);
  }
}
