part of easy_rxmvvm;

/// 事件动作，包含事件类型和可选的数据
class EventAction<T> {
  const EventAction(
    this.event, {
    this.data,
  });

  final T event;
  final dynamic data;

  /// 安全地获取数据并转换为指定类型
  V? dataAs<V>() {
    if (data is V) {
      return data as V;
    }
    return null;
  }

  @override
  String toString() {
    return 'EventAction(event: $event, data: $data)';
  }
}

typedef DispatchActionListener<T> = void Function(EventAction<T> action);

/// 事件分发 Mixin
mixin DispatchActionMixin<T> on ViewModel {
  late final _eventActionSubject = PublishSubject<EventAction<T>>();

  /// 事件流
  Stream<EventAction<T>> get eventActionStream => _eventActionSubject.stream;

  /// 分发事件
  StreamSink<EventAction<T>> get eventActionSink => _eventActionSubject.sink;

  StreamSubscription<EventAction<T>>? _loggerSubscription;

  @override
  void beforeConfig() {
    dispatchLogger().disposeBy(disposeBag);
    super.beforeConfig();
  }

  /// 事件日志记录器
  /// [tag] 自定义日志标签
  /// [level] 日志级别
  /// [formatter] 自定义日志格式化方法
  StreamSubscription<EventAction<T>> dispatchLogger({
    String? tag,
    String Function(EventAction<T>)? formatter,
  }) {
    _loggerSubscription?.cancel();
    _loggerSubscription = _eventActionSubject
        .log(
          tag: tag ?? '${T.toString()} Action',
          formatter: formatter ??
              (action) => 'Event: ${action.event}, Data: ${action.data}',
        )
        .listen((_) {});
    return _loggerSubscription!;
  }

  /// 根据条件过滤事件
  Stream<EventAction<T>> filterEvents(bool Function(T event) predicate) {
    return _eventActionSubject.where(
      (action) => predicate(action.event),
    );
  }

  /// 获取指定事件的事件流
  Stream<EventAction<T>> filterEvent(T event) {
    return filterEvents((v) => v == event);
  }

  /// 获取指定事件的事件流
  Stream<R> extractEventData<R>(T event) {
    return filterEvents((v) => v == event).extractData<R>();
  }

  /// 监听指定事件
  ///
  /// [event] 需要监听的事件
  /// [onListen] 事件回调
  ///
  /// return 一个 StreamSubscription，需要在生命周期结束时调用 `dispose` 进行清理
  StreamSubscription<EventAction<T>> onEvent(
    T event,
    DispatchActionListener<T> onListen,
  ) {
    return filterEvents((item) => event == item).listen(onListen);
  }

  /// 监听指定事件
  ///
  /// [event] 需要监听的事件
  /// [onListen] 事件回调，不传递参数
  ///
  /// return 一个 StreamSubscription，需要在生命周期结束时调用 `dispose` 进行清理
  StreamSubscription<EventAction<T>> onEventOnly(
    T event,
    VoidCallback onListen,
  ) {
    return onEvent(event, (_) => onListen());
  }

  /// 监听指定事件的数据
  ///
  /// [event] 需要监听的事件
  /// [onListen] 事件回调，传递该事件的数据
  ///
  /// return 一个 StreamSubscription，需要在生命周期结束时调用 `dispose` 进行清理
  StreamSubscription<R> onEventData<R>(
    T event,
    ValueChanged<R> onListen,
  ) {
    return filterEvents((item) => event == item)
        .extractData<R>()
        .listen(onListen);
  }

  /// 发送事件
  void dispatch(T event, {dynamic data}) {
    dispatchEvent(event.asEventwithData(data));
  }

  void dispatchEvent(EventAction<T> event) {
    if (_eventActionSubject.isClosed) {
      RxLogger.warning('Cannot dispatch event after dispose: $event');
      return;
    }

    try {
      _eventActionSubject.safeAdd(event);
    } catch (error, stackTrace) {
      RxLogger.logError(error, stackTrace);
    }
  }

  /// 创建事件分发回调
  VoidCallback dispatcher(T event, {dynamic data}) {
    return () => dispatch(event, data: data);
  }

  /// 创建带数据的事件分发回调
  ValueChanged<V> dispatcherWithData<V>(T event) {
    return (data) => dispatch(event, data: data);
  }

  @override
  void dispose() {
    _eventActionSubject.close();
    super.dispose();
  }
}

extension EventActionExtension<T> on EventAction<T> {
  void dispatchBy(DispatchActionMixin<T> viewModel) {
    viewModel.dispatchEvent(this);
  }

  VoidCallback dispatcher(DispatchActionMixin<T> viewModel) {
    return () => dispatchBy(viewModel);
  }
}

extension EventActionWrapperExtension<T> on T {
  EventAction<T> get asEventAction => EventAction(this);

  EventAction<T> asEventwithData(dynamic data) => EventAction(this, data: data);

  EventAction<R> asDataForEvent<R>(R event) => EventAction(event, data: this);
}

/// 事件动作流扩展
extension StreamEventActionExtension<T> on Stream<EventAction<T>> {
  /// 从事件中提取数据
  Stream<R> extractData<R>() {
    return where((event) => event.data is R).map((event) => event.data).cast();
  }
}
