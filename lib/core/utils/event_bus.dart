part of easy_rxmvvm;

/// 全局事件总线（静态调用）
class EventBus {
  static final PublishSubject<dynamic> _eventSubject =
      PublishSubject<dynamic>();

  static bool get isClosed => _eventSubject.isClosed;

  static void emit(dynamic event) {
    if (isClosed) {
      RxLogger.warning('Cannot emit event after dispose: $event');
      return;
    }
    RxLogger.log(
        'EventBus: Emitting event of type ${event.runtimeType} - $event');
    _eventSubject.safeAdd(event);
  }

  static Stream<T> on<T>() {
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

  /// 事件动作流
  static Stream<EventAction<E>> onEventStream<E>() {
    if (isClosed) {
      RxLogger.warning('EventBus is closed');
      return const Stream.empty();
    }
    return _eventSubject.stream
        .where((e) => e is EventAction<E>)
        .cast<EventAction<E>>()
        .doOnData((action) {
      RxLogger.log('EventBus: Received Action ${E.toString()} - $action');
    }).doOnCancel(() {
      RxLogger.log(
          'EventBus: Stop listening to actions of type ${E.toString()}');
    }).doOnError((error, stackTrace) {
      RxLogger.logError(error, stackTrace);
    });
  }

  /// predicate 过滤事件动作
  static Stream<EventAction<E>> onEventWhere<E>(
      bool Function(E event) predicate) {
    return onEventStream<E>().where((action) => predicate(action.event));
  }

  /// 监听指定事件
  static Stream<EventAction<E>> onEvent<E>(E event) {
    return onEventWhere<E>((e) => e == event);
  }

  /// 监听指定事件的数据
  static Stream<R> onEventData<E, R>(E event) {
    return onEvent<E>(event).where((a) => a.data is R).map((a) => a.data as R);
  }

  /// 分发事件
  static void dispatch<E>(E event, {dynamic data}) {
    if (isClosed) {
      RxLogger.warning('Cannot dispatch after dispose: $event');
      return;
    }
    final action = EventAction<E>(event, data: data);
    RxLogger.log('EventBus: Dispatch action ${E.toString()} - $action');
    _eventSubject.safeAdd(action);
  }

  /// 分发事件动作
  static void dispatchEvent<E>(EventAction<E> action) {
    if (isClosed) {
      RxLogger.warning('Cannot dispatch action after dispose: $action');
      return;
    }
    RxLogger.log('EventBus: Dispatch action ${E.toString()} - $action');
    _eventSubject.safeAdd(action);
  }

  /// 监听指定事件
  static StreamSubscription<EventAction<E>> onListen<E>(
    E event,
    void Function(EventAction<E>) listen, {
    StreamTransformer<EventAction<E>, EventAction<E>>? transformer,
    StreamOperator<EventAction<E>>? transfer,
    void Function()? onDone,
    void Function(Object, StackTrace)? onError,
    bool? cancelOnError,
  }) {
    Stream<EventAction<E>> s = onEvent<E>(event);
    if (transformer != null) {
      s = s.transform(transformer);
    }
    if (transfer != null) {
      s = transfer(s);
    }
    return s.listen(
      listen,
      onDone: onDone,
      onError: onError,
      cancelOnError: cancelOnError,
    );
  }

  /// 监听指定事件的数据
  static StreamSubscription<R> onDataListen<E, R>(
    E event,
    void Function(R data) listen, {
    StreamTransformer<R, R>? transformer,
    StreamOperator<R>? transfer,
    void Function()? onDone,
    void Function(Object, StackTrace)? onError,
    bool? cancelOnError,
  }) {
    Stream<R> s = onEventData<E, R>(event);
    if (transformer != null) {
      s = s.transform(transformer);
    }
    if (transfer != null) {
      s = transfer(s);
    }
    return s.listen(
      listen,
      onDone: onDone,
      onError: onError,
      cancelOnError: cancelOnError,
    );
  }

  /// 销毁事件总线
  static void dispose() {
    if (!isClosed) {
      RxLogger.log('EventBus disposed');
      _eventSubject.close();
    }
  }
}
