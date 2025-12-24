part of easy_rxmvvm;

/// 面向任意 Stream<T> 的响应式组件（Riverpod 风格，无需手动 key）
///
/// 核心优势：
/// - 自动根据 Stream 实例 + selector 函数引用 实现智能订阅去重
/// - 支持 ValueStream 自动读取初始值
/// - 只在值变化时 rebuild
/// - 自动清理未使用的订阅
///
/// 使用示例：
///   StreamOb(builder: (context, watcher) {
///     final state = viewModel.stateStream.watch(watcher);
///     final age = viewModel.stateStream.select(watcher, (s) => s.age);
///     // 或等价写法：
///     // final age = watcher.select(viewModel.stateStream, (s) => s.age);
///     return Text('Age: ${age ?? 0}');
///   });
///
/// 重要性能提示（请务必阅读）：
///
///   为了获得最佳性能和避免重复订阅，
///   强烈建议所有需要在 UI 中观察的派生状态，都在 ViewModel 中预先定义为成员变量。
///
///   推荐做法：
///     late final ValueStream<int> ageStream =
///         stateStream.map((s) => s.age).shareValueSeeded(stateStream.value.age);
///
///     // UI 中：
///     final age = viewModel.ageStream.watch(watcher);
///
///   禁止做法（会导致每次 build 重复订阅、性能严重下降）：
///     viewModel.stateStream.map((s) => s.age).watch(watcher); // 临时 Stream 实例！
///
///   本组件在 debug 模式下不会阻止此类用法，但强烈不推荐。
///
class StreamOb extends StatefulWidget {
  const StreamOb({
    super.key,
    required this.builder,
    this.child,
    this.debugLabel,
  });

  final Widget Function(BuildContext context, RxOb watcher, Widget? child)
      builder;
  final Widget? child;
  final String? debugLabel;

  @override
  State<StreamOb> createState() => _StreamObState();
}

class RxOb {
  final _StreamObState _state;
  RxOb._(this._state);

  R? _watch<S, R>(
    Stream<S> stream, {
    R Function(S)? selector,
    R? initial,
    bool Function(R previous, R next)? equals,
    Object? key,
  }) {
    final resolvedInitial = initial ??
        (stream is ValueStream<S>
            ? (() {
                try {
                  if (stream.hasValue) return selector?.call(stream.value);
                } catch (_) {}
                return null;
              })()
            : null);

    return _state._watch<S, R>(
      stream,
      initial: resolvedInitial,
      selector: selector,
      equals: equals,
      key: key,
    );
  }

  R _watchValue<S, R>(
    ValueStream<S> stream, {
    R Function(S)? selector,
    R? fallback,
    R? initial,
    bool Function(R previous, R next)? equals,
    Object? key,
  }) {
    // 用于计算初始值的有效 selector
    final computeInitial = selector ?? (S v) => v as R;

    bool streamHasValue = false;
    R? init = initial;

    try {
      streamHasValue = stream.hasValue;
      if (streamHasValue) {
        init ??= computeInitial(stream.value);
      }
    } catch (_) {}

    // 注意：传给 _watch 的 selector 保持原始（允许 null）
    final v = _state._watch<S, R>(
      stream,
      initial: init,
      selector: selector,
      equals: equals,
      key: key,
    );

    if (streamHasValue) return v as R;
    if (v != null) return v;
    if (fallback != null) return fallback;
    throw StateError('watchValue: ValueStream 当前没有值，且未提供 fallback。');
  }
}

class _StreamObState extends State<StreamOb> {
  final Map<_SmartSubKey, _SubscriptionEntry> _subscriptions = {};
  final Set<_SmartSubKey> _observedThisBuild = {};
  Timer? _rebuildTimer;

  R? _resolveInitial<S, R>(
    Stream<S> stream,
    R? initial,
    R Function(S)? selector,
  ) {
    if (initial != null) return initial;
    if (stream is ValueStream<S>) {
      try {
        final value = stream.value;
        return selector != null ? selector(value) : value as R;
      } catch (_) {}
    }
    return null;
  }

  void _ensureSubscriptionForKey<R>(
    _SmartSubKey subKey,
    Stream<R> listenedStream,
    R? initial,
    bool Function(R previous, R next)? equals,
  ) {
    // Check if subscription already exists - single lookup
    final existingEntry = _subscriptions[subKey];
    if (existingEntry != null) {
      return;
    }

    final sub = listenedStream.distinct(equals).listen((newValue) {
      // Use single lookup to get entry
      final entry = _subscriptions[subKey];
      if (entry == null) return; // 订阅已被清理

      final oldValue = entry.value as R?;

      final bool isEqual = equals != null
          ? equals(oldValue as R, newValue)
          : identical(oldValue, newValue) || (oldValue == newValue);

      if (isEqual) {
        // 值相等，只更新值但不触发重建
        entry.updateValue(newValue);
        return;
      }

      // 值不相等，更新值并触发重建
      entry.updateValue(newValue);
      _scheduleRebuild();
    }, onError: (err, st) {
      RxLogger.logError(err, st);
    }, cancelOnError: false);

    // 创建新的订阅条目，将订阅和初始值存储在一起
    _subscriptions[subKey] = _SubscriptionEntry(sub, initial);
  }

  void _cleanupUnusedSubscriptions() {
    final prevKeys = _subscriptions.keys.toSet();
    final unused = prevKeys.difference(_observedThisBuild);

    if (unused.isEmpty) return;

    // Batch cleanup with error handling
    final errors = <Object>[];
    final toRemove = <_SmartSubKey>[];

    for (final key in unused) {
      final entry = _subscriptions[key];
      if (entry != null) {
        try {
          entry.cancel();
          toRemove.add(key);
        } catch (error, stackTrace) {
          errors.add(error);
          RxLogger.logError(error, stackTrace);
          // Still mark for removal even if cancel failed
          toRemove.add(key);
        }
      }
    }

    // Remove all entries in batch
    for (final key in toRemove) {
      _subscriptions.remove(key);
    }

    // Log cleanup summary if there were errors
    if (errors.isNotEmpty) {
      RxLogger.warning(
          'StreamOb cleanup completed with ${errors.length} errors out of ${unused.length} subscriptions');
    }
  }

  R? _watch<S, R>(
    Stream<S> baseStream, {
    R? initial,
    R Function(S)? selector,
    bool Function(R previous, R next)? equals,
    Object? key,
  }) {
    final subKey = _SmartSubKey(
      baseStream: baseStream,
      userKey: key,
      selectorFn: selector,
    );

    _observedThisBuild.add(subKey);

    final resolvedInitial =
        _resolveInitial<S, R>(baseStream, initial, selector);

    final Stream<R> finalStream =
        selector != null ? baseStream.map(selector) : baseStream as Stream<R>;

    _ensureSubscriptionForKey<R>(subKey, finalStream, resolvedInitial, equals);

    // Single lookup to get the value
    return _subscriptions[subKey]?.value as R?;
  }

  @override
  void dispose() {
    // Cancel rebuild timer if active
    _rebuildTimer?.cancel();
    _rebuildTimer = null;

    // Batch cleanup all subscriptions with error handling
    final errors = <Object>[];

    for (final entry in _subscriptions.values) {
      try {
        entry.cancel();
      } catch (error, stackTrace) {
        errors.add(error);
        RxLogger.logError(error, stackTrace);
      }
    }

    _subscriptions.clear();
    _observedThisBuild.clear();

    // Log disposal summary if there were errors
    if (errors.isNotEmpty) {
      RxLogger.warning(
          'StreamOb disposal completed with ${errors.length} subscription cleanup errors');
    }

    super.dispose();
  }

  void _scheduleRebuild() {
    // Avoid duplicate scheduling
    if (_rebuildTimer?.isActive ?? false) return;

    _rebuildTimer = Timer(Duration.zero, () {
      if (!mounted) {
        _rebuildTimer = null;
        return;
      }
      setState(() {});
      _rebuildTimer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    _observedThisBuild.clear();

    final watcher = RxOb._(this);
    final built = widget.builder(context, watcher, widget.child);

    _cleanupUnusedSubscriptions();

    return built;
  }
}

/// 智能订阅键：支持函数引用比较（Riverpod 风格）
class _SmartSubKey {
  final Stream baseStream;
  final Object? userKey;
  final Function? selectorFn;

  _SmartSubKey({
    required this.baseStream,
    this.userKey,
    this.selectorFn,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! _SmartSubKey) return false;

    if (userKey != null || other.userKey != null) {
      return userKey == other.userKey;
    }

    return identical(baseStream, other.baseStream) &&
        identical(selectorFn, other.selectorFn);
  }

  @override
  int get hashCode {
    if (userKey != null) return userKey.hashCode;
    return Object.hash(
      identityHashCode(baseStream),
      identityHashCode(selectorFn),
    );
  }

  @override
  String toString() {
    final parts = <String>[];
    parts.add('base=${baseStream.runtimeType}');
    if (userKey != null) parts.add('userKey=$userKey');
    if (selectorFn != null) parts.add('selector=${selectorFn.hashCode}');
    return 'SmartSubKey(${parts.join(', ')})';
  }
}

/// 订阅条目：将订阅和值合并到单一数据结构中
/// 这样可以减少 Map 查找次数，提高性能
class _SubscriptionEntry {
  final StreamSubscription<dynamic> subscription;
  dynamic value;

  _SubscriptionEntry(this.subscription, this.value);

  /// 更新值
  void updateValue(dynamic newValue) {
    value = newValue;
  }

  /// 取消订阅
  void cancel() {
    subscription.cancel();
  }
}

extension RxObExtension on RxOb {
  S? watch<S>(
    Stream<S> stream, {
    S? initial,
    bool Function(S previous, S next)? equals,
    Object? key,
  }) =>
      _watch<S, S>(
        stream,
        initial: initial,
        equals: equals,
        key: key,
      );

  R? select<S, R>(
    Stream<S> stream,
    R Function(S value) selector, {
    R? initial,
    bool Function(R previous, R next)? equals,
    Object? key,
  }) =>
      _watch<S, R>(
        stream,
        selector: selector,
        initial: initial,
        equals: equals,
        key: key,
      );

  S watchValue<S>(
    ValueStream<S> stream, {
    S? fallback,
    S? initial,
    bool Function(S previous, S next)? equals,
    Object? key,
  }) =>
      _watchValue<S, S>(
        stream,
        fallback: fallback,
        initial: initial,
        equals: equals,
        key: key,
      );

  R selctValue<S, R>(
    ValueStream<S> stream,
    R Function(S value) selector, {
    R? fallback,
    R? initial,
    bool Function(R previous, R next)? equals,
    Object? key,
  }) =>
      _watchValue<S, R>(
        stream,
        selector: selector,
        fallback: fallback,
        initial: initial,
        equals: equals,
        key: key,
      );
}

extension StreamWatchExtension<S> on Stream<S> {
  S? watchBy(
    RxOb watcher, {
    S? initial,
    bool Function(S previous, S next)? equals,
    Object? key,
  }) =>
      watcher.watch(
        this,
        initial: initial,
        equals: equals,
        key: key,
      );
}

extension ValueStreamWatchExtension<S> on ValueStream<S> {
  S watchBy(
    RxOb watcher, {
    S? fallback,
    S? initial,
    bool Function(S previous, S next)? equals,
    Object? key,
  }) =>
      watcher.watchValue(
        this,
        fallback: fallback,
        initial: initial,
        equals: equals,
        key: key,
      );

  R selectBy<R>(
    RxOb watcher,
    R Function(S value) selector, {
    R? fallback,
    R? initial,
    bool Function(R previous, R next)? equals,
    Object? key,
  }) =>
      watcher.selctValue(
        this,
        selector,
        fallback: fallback,
        initial: initial,
        equals: equals,
        key: key,
      );
}
