import 'package:rxdart/rxdart.dart';
import 'package:rxmvvm/rxmvvm.dart';

/// 提供统一的错误管理
mixin ToastMixin on DisposeMixin {
  final _toastSubject = BehaviorSubject<String>.seeded('');

  Stream<String> get toastStream =>
      _toastSubject.stream.where((event) => event.isNotEmpty);

  void setToast(String error) => _toastSubject.safeAdd(error);

  @override
  void dispose() {
    try {
      _toastSubject.close();
    } catch (_) {}
    super.dispose();
  }
}
