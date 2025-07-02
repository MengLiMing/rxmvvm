part of easy_rxmvvm;

/// dispose回调函数
typedef DisposeHandler = void Function();

class DisposeBag with DisposeMixin, DisposeBagMixin {}

mixin DisposeBagProvider {
  /// 用于资源管理的 DisposeBag
  late final disposeBag = DisposeBag().._ownerType = runtimeType;
}

/// DisposeBagMixin,用于在 State 中统一管理所有的 Subscription 和其他需要 dispose 的对象
mixin DisposeBagMixin on DisposeMixin {
  Type? _ownerType;

  CompositeSubscription? _subscriptionBagInstance;

  /// Subscription的dispose统一管理
  /// 每次获取时检查是否已经被dispose，如果是则创建新的实例
  CompositeSubscription get _subscriptionBag {
    if (_subscriptionBagInstance == null || _isDisposed) {
      _subscriptionBagInstance = CompositeSubscription();
      _isDisposed = false;
    }
    return _subscriptionBagInstance!;
  }

  /// 标记是否已经被dispose
  bool _isDisposed = false;

  /// 其他需要dispose的将其方法添加到其中进行统一管理
  final List<DisposeHandler> _disposeHandlers = [];

  @override
  void dispose() {
    try {
      _subscriptionBagInstance?.dispose();
      _isDisposed = true;
    } catch (error, stackTrace) {
      RxLogger.logError(error, stackTrace);
    }
    try {
      for (var handler in _disposeHandlers) {
        handler.dispose();
      }
      _disposeHandlers.clear();
    } catch (error, stackTrace) {
      RxLogger.logError(error, stackTrace);
    } finally {
      if (_ownerType != null) {
        RxLogger.log("$_ownerType.DisposeBag - dispose");
      } else {
        super.dispose();
      }
    }
  }

  void _addSubscription(StreamSubscription subscription) {
    if (_subscriptionBag.isDisposed) {
      addDisposeCallback(subscription.cancel);
      return;
    }
    _subscriptionBag.add(subscription);
  }

  /// 添加订阅到 dispose bag
  StreamSubscription<T> addSubscription<T>(StreamSubscription<T> subscription) {
    _addSubscription(subscription);
    return subscription;
  }

  /// 添加多个订阅到 dispose bag
  void addSubscriptions(List<StreamSubscription> subscriptions) {
    for (var subscription in subscriptions) {
      _addSubscription(subscription);
    }
  }

  /// 添加销毁回调
  void addDisposeCallback(DisposeHandler callback) {
    _disposeHandlers.add(callback);
  }

  /// 添加多个销毁回调
  void addDisposeCallbacks(List<DisposeHandler> callbacks) {
    _disposeHandlers.addAll(callbacks);
  }
}
