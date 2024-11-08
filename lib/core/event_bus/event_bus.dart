part of easy_rxmvvm;

/// 全局事件总线
class EventBus {
  static final EventBus _instance = EventBus._internal();
  factory EventBus() => _instance;

  final _eventSubject = PublishSubject<dynamic>();

  bool get isClosed => _eventSubject.isClosed;

  EventBus._internal();

  /// 监听指定类型的事件
  Stream<T> on<T>() {
    if (isClosed) {
      RxLogger.warning('EventBus is closed');
      return const Stream.empty();
    }
    return _eventSubject.stream
        .where((event) => event is T)
        .cast<T>()
        .doOnData((event) {
      RxLogger.log('EventBus: Received ${T.toString()} - $event');
    }).doOnCancel(() {
      RxLogger.log(
          'EventBus: Stop listening to events of type ${T.toString()}');
    }).doOnError((error, stackTrace) {
      RxLogger.logError(error, stackTrace);
    });
  }

  /// 发送事件
  void emit(dynamic event) {
    if (isClosed) {
      RxLogger.warning('Cannot emit event after dispose: $event');
      return;
    }
    RxLogger.log(
        'EventBus: Emitting event of type ${event.runtimeType} - $event');
    _eventSubject.safeAdd(event);
  }

  /// 销毁事件总线
  void dispose() {
    if (!isClosed) {
      RxLogger.log('EventBus disposed');
      _eventSubject.close();
    }
  }
}
