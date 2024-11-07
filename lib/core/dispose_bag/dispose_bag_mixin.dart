part of rxmvvm;

/// dispose回调函数
typedef DisposeHandler = void Function();

/// DisposeBagMixin,用于在 State 中统一管理所有的 Subscription 和其他需要 dispose 的对象
mixin DisposeBagMixin on DisposeMixin {
  bool _isDisposed = false;

  /// Subscription的dispose统一管理
  final _subscriptionBag = CompositeSubscription();

  /// 其他需要dispose的将其方法添加到其中进行统一管理
  final List<DisposeHandler> _disposeHandlers = [];

  /// 检查是否已销毁
  bool get isDisposed => _isDisposed;

  @override
  void dispose() {
    if (_isDisposed) {
      RxLogger.warning('${runtimeType.toString()} already disposed');
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
    } catch (error, stackTrace) {
      RxLogger.logError(error, stackTrace);
    } finally {
      super.dispose();
    }
  }

  /// 添加订阅到 dispose bag
  StreamSubscription<T> addSubscription<T>(StreamSubscription<T> subscription) {
    _checkDisposed();
    _subscriptionBag.add(subscription);
    return subscription;
  }

  /// 添加多个订阅到 dispose bag
  void addSubscriptions(List<StreamSubscription> subscriptions) {
    _checkDisposed();
    for (var subscription in subscriptions) {
      _subscriptionBag.add(subscription);
    }
  }

  /// 添加销毁回调
  void addDisposeCallback(DisposeHandler callback) {
    _checkDisposed();
    _disposeHandlers.add(callback);
  }

  /// 添加多个销毁回调
  void addDisposeCallbacks(List<DisposeHandler> callbacks) {
    _checkDisposed();
    _disposeHandlers.addAll(callbacks);
  }

  /// 检查是否已销毁
  void _checkDisposed() {
    if (_isDisposed) {
      throw StateError('${runtimeType.toString()} is already disposed');
    }
  }
}
