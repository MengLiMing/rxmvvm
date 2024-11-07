// ignore_for_file: avoid_print

import 'package:rxmvvm/rxmvvm.dart';
import 'package:rxmvvm_example/inherited/a_vm.dart';

import '../vm/login_vm.dart';

class BViewModel extends ViewModel {
  @override
  void config() {
    configByViewModel<LoginManagerViewModel>((value) {
      print("BViewModel - 获取到了LoginManagerViewModel");
    }).disposeBy(disposeBag);

    configByViewModel<AViewModel>((value) {
      print("BViewModel - 获取到了AViewModel");
    }).disposeBy(disposeBag);
  }
}
