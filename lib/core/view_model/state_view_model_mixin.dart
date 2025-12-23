part of easy_rxmvvm;

/// StateMixin<TState>
///
/// 基于单一状态对象的 ViewModel 基类
/// TState 推荐为 immutable（并实现 copyWith）
/// TState 推荐继承Equatable 或者 重写==和hashCode
mixin StateMixin<TState> on DisposeMixin, DisposeBagProvider {
  // 子类必须提供初始值
  TState get initialState;

  // BehaviorSubject 用于持有当前状态（seeded with initialState）
  late final BehaviorSubject<TState> _stateSubject =
      BehaviorSubject<TState>.seeded(initialState);

  /// 用于监听State变化
  ValueStream<TState> get stateStream => _stateSubject;

  /// 用于便捷更新State
  StreamSink<TState> get stateSink => _stateSubject.sink;

  TState get state => _stateSubject.value;

  void setState(TState newState) {
    try {
      final prev = state;
      final isEqual = identical(newState, prev) || newState == prev;
      if (isEqual || _stateSubject.isClosed) return;
      _stateSubject.add(newState);
    } catch (err, st) {
      RxLogger.logError(err, st);
    }
  }

  TState updateState(TState Function(TState prev) updater) {
    try {
      final prev = state;
      final next = updater(prev);
      setState(next);
      return next;
    } catch (err, st) {
      RxLogger.logError(err, st);
      rethrow;
    }
  }

  Stream<TSel> select<TSel>(
    TSel Function(TState s) selector, {
    bool Function(TSel a, TSel b)? equals,
  }) {
    final mapped = _stateSubject.map(selector);
    return equals == null
        ? mapped.distinct()
        : mapped.distinct((a, b) => equals(a, b));
  }

  @override
  void dispose() {
    try {
      if (!_stateSubject.isClosed) _stateSubject.close();
    } catch (_) {}
    super.dispose();
  }
}
