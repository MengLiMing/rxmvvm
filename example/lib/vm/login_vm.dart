import 'package:rxmvvm/rxmvvm.dart';

enum LoginManagerAction {
  login,
  logout,
}

class LoginManagerViewModel extends ViewModel
    with DispatchActionMixin<LoginManagerAction> {
  final isLogin = false.rx;

  @override
  void config() {
    onEvent(LoginManagerAction.login, (action) {
      isLogin.value = true;
    }).disposeBy(disposeBag);

    onEvent(LoginManagerAction.logout, (action) {
      isLogin.value = false;
    }).disposeBy(disposeBag);
  }
}
