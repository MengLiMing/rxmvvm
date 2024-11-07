import 'package:rxmvvm/rxmvvm.dart';

import '../rxmvvm_util/loading_mixin.dart';
import '../rxmvvm_util/page_request_mixin.dart';

class PagingViewModel extends ViewModel
    with PageRequestMixin<String>, LoadingMixin<bool> {
  @override
  void config() {
    refreshData();
  }

  @override
  Future<PageResult<String>> requestPage(int page) async {
    setLoading(true);
    await Future.delayed(const Duration(seconds: 2));
    setLoading(false);
    if (page == 1) {
      return PageResult(List.filled(20, "data"), true);
    } else {
      return PageResult(List.filled(20, "data"), page <= 3);
    }
  }
}
