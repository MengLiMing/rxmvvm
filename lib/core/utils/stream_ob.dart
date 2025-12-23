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

  /// 核心通用 watch 方法
  /// - 不传 selector 时，R 默认为 S（直接观察原始值）
  /// - 传 selector 时，映射为 R
  R? _watch<S, R>(
    Stream<S> stream, {
    R Function(S)? selector,
    R? initial,
    bool Function(R previous, R next)? equals,
    Object? key,
  }) {
    // 如果没有 selector，就用 identity 映射
    final effectiveSelector = selector ?? (S value) => value as R;

    return _state._watch<S, R>(
      stream,
      initial: initial,
      selector: effectiveSelector,
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
      selector: selector, // 原样传递！关键在这里
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
  final Map<_SmartSubKey, StreamSubscription<dynamic>> _subs = {};
  final Map<_SmartSubKey, dynamic> _values = {};
  final Set<_SmartSubKey> _observedThisBuild = {};
  bool _rebuildScheduled = false;

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
    if (_subs.containsKey(subKey)) {
      return;
    }

    _values[subKey] = initial;

    final sub = listenedStream.distinct(equals).listen((newValue) {
      final oldValue = _values[subKey] as R?;

      final bool isEqual = equals != null
          ? equals(oldValue as R, newValue)
          : identical(oldValue, newValue) || (oldValue == newValue);

      if (isEqual) {
        _values[subKey] = newValue;
        return;
      }

      _values[subKey] = newValue;
      _scheduleRebuild();
    }, onError: (err, st) {
      RxLogger.logError(err, st);
    }, cancelOnError: false);

    _subs[subKey] = sub;
  }

  void _cleanupUnusedSubscriptions() {
    final prevKeys = _subs.keys.toSet();
    final unused = prevKeys.difference(_observedThisBuild);

    for (final key in unused) {
      _subs[key]?.cancel();
      _subs.remove(key);
      _values.remove(key);
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

    return _values[subKey] as R?;
  }

  @override
  void dispose() {
    for (final s in _subs.values) {
      s.cancel();
    }
    _subs.clear();
    _values.clear();
    _observedThisBuild.clear();
    super.dispose();
  }

  void _scheduleRebuild() {
    if (_rebuildScheduled) return;
    _rebuildScheduled = true;
    scheduleMicrotask(() {
      if (!mounted) {
        return;
      }
      setState(() {
        _rebuildScheduled = false;
      });
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

  R? selectBy<R>(
    RxOb watcher,
    R Function(S value) selector, {
    R? initial,
    bool Function(R previous, R next)? equals,
    Object? key,
  }) =>
      watcher.select(
        this,
        selector,
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
