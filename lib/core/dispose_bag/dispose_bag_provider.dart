part of rxmvvm;

mixin DisposeMixin {
  void dispose() {
    // 移除默认的日志打印，让具体实现决定是否打印
  }
}

class DisposeBag with DisposeMixin, DisposeBagMixin {
  @override
  void dispose() {
    if (_isDisposed) {
      RxLogger.warning('DisposeBag already disposed');
      return;
    }
    _isDisposed = true;

    try {
      _subscriptionBag.dispose();

      for (var handler in _disposeHandlers) {
        try {
          handler.dispose();
        } catch (error, stackTrace) {
          RxLogger.logError(error, stackTrace);
        }
      }

      _disposeHandlers.clear();
      RxLogger.log("DisposeBag - dispose"); // 只在这里打印一次日志
    } catch (error, stackTrace) {
      RxLogger.logError(error, stackTrace);
    }
  }
}

mixin DisposeBagProvider {
  /// 用于资源管理的 DisposeBag
  late final disposeBag = DisposeBag();
}
