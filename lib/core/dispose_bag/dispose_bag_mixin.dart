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

  /// Subscription的dispose统一管理
  final _subscriptionBag = CompositeSubscription();

  /// 其他需要dispose的将其方法添加到其中进行统一管理
  final List<DisposeHandler> _disposeHandlers = [];

  @override
  void dispose() {
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
      if (_ownerType != null) {
        RxLogger.log("$_ownerType.DisposeBag - dispose");
      } else {
        super.dispose();
      }
    }
  }

  /// 添加订阅到 dispose bag
  StreamSubscription<T> addSubscription<T>(StreamSubscription<T> subscription) {
    _subscriptionBag.add(subscription);
    return subscription;
  }

  /// 添加多个订阅到 dispose bag
  void addSubscriptions(List<StreamSubscription> subscriptions) {
    for (var subscription in subscriptions) {
      _subscriptionBag.add(subscription);
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
