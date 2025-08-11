import 'package:easy_rxmvvm/easy_rxmvvm.dart';

enum LoginManagerAction {
  login,
  logout,
}

class LoginManagerViewModel extends ViewModel
    with DispatchActionMixin<LoginManagerAction> {
  final isLogin = false.rx;

  @override
  void config() {
    on(LoginManagerAction.login).listen((event) {
      isLogin.value = true;
    }).disposeBy(disposeBag);

    on(LoginManagerAction.logout).listen((event) {
      isLogin.value = false;
    }).disposeBy(disposeBag);
  }
}
