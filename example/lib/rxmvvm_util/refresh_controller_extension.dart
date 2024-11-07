import 'dart:async';

import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rxmvvm_example/rxmvvm_util/page_request_mixin.dart';

extension RefreshControllerRxExtension on RefreshController {
  StreamSubscription changeStatusBy(Stream<PageRequestState> stream) {
    return stream.listen((event) {
      switch (event) {
        case PageRequestState.refreshCompleted:
          refreshCompleted(resetFooterState: true);
          break;
        case PageRequestState.refreshCompletedNoMoreData:
          refreshCompleted();
          loadNoData();
          break;
        case PageRequestState.loadCompleted:
          loadComplete();
          break;
        case PageRequestState.loadCompletedNoMoreData:
          loadNoData();
          break;
        default:
          break;
      }
    });
  }
}
