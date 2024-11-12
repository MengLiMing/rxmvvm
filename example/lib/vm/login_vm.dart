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
    onEventOnly(LoginManagerAction.login, () {
      isLogin.value = true;
    });

    onEventOnly(LoginManagerAction.logout, () {
      isLogin.value = false;
    });
  }
}
