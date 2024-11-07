part of rxmvvm;

/// 事件总线，用于在 widgets 和 viewmodel 之间传递事件
/// 事件可以是任何类型，包括自定义的事件
mixin EventBusMixin {
  /// 通过事件总线发送事件
  void emitEvent(dynamic event) {
    EventBus().emit(event);
  }

  /// 事件总线的事件流
  Stream<T> eventBusStream<T>() {
    return EventBus().on<T>();
  }

  /// 监听事件 返回的 [StreamSubscription] 需要调用 `dispose` 进行清理。
  StreamSubscription<T> onEventBus<T>(void Function(T event) onData) {
    return EventBus().on<T>().listen(onData);
  }
}
