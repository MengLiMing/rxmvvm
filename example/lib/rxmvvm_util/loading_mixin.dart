import 'dart:async';

import 'package:easy_rxmvvm/easy_rxmvvm.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

/// 提供统一的loading管理
mixin LoadingMixin<T> on DisposeMixin {
  late final _loadingSubject = PublishSubject<T>();

  void setLoading(T state) {
    _loadingSubject.safeAdd(state);
  }

  /// 返回的 [StreamSubscription] 需要调用 `dispose` 进行清理。
  StreamSubscription<T> onLoadingState(
    ValueChanged<T> onListen, {
    required T initialValue,
    StreamMiddlewareTransfer<T>? transformer,
  }) {
    return _loadingSubject
        .applyMiddleware(transformer)
        .doOnCancel(() => onListen(initialValue))
        .listen(onListen);
  }

  @override
  void dispose() {
    try {
      _loadingSubject.close();
    } catch (_) {}
    super.dispose();
  }
}

extension BoolLoadingExtension on LoadingMixin<bool> {
  /// 返回的 [StreamSubscription] 需要调用 `dispose` 进行清理。
  ///
  /// 对于bool类型的 只想出发一组事件
  StreamSubscription<bool> onOnceLoadingState(
    ValueChanged<bool> onListen, {
    required bool initialValue,
  }) {
    return onLoadingState(onListen,
        initialValue: initialValue, transformer: (p0) => p0.distinct().take(2));
  }
}
