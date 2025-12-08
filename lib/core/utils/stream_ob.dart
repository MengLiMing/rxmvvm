part of easy_rxmvvm;

/// 面向任意 Stream<T> 的响应式组件。
/// 在 builder 中通过 watch(stream, {initial}) 收集依赖并读取值；
/// 事件到达时触发最小范围重建，订阅按生命周期统一管理。
class StreamOb extends StatefulWidget {
  /// 函数注释：builder 接收统一的 `watch` 方法，以及可选 `child` 静态子树。
  const StreamOb({
    super.key,
    required this.builder,
    this.child,
  });

  /// builder 参数：
  /// watch 用于登记依赖并返回最新值（无缓存时返回 initial）；
  /// child 为静态子树，避免重复构建。
  final Widget Function(
    BuildContext context,
    StreamWatch watch,
    Widget? child,
  ) builder;

  final Widget? child;

  @override
  State<StreamOb> createState() => _StreamObState();
}

/// 监听函数的类型定义
typedef StreamWatch = T? Function<T>(Stream<T> stream, {T? initial});

/// 为 StreamWatch 扩展，提供更方便的 API
extension StreamWatchExt on StreamWatch {
  /// 确定有值时调用 监听并获取 [ValueStream] (如 BehaviorSubject) 的当前值
  T value<T>(ValueStream<T> stream, {T? initial}) {
    final val = this(stream, initial: initial);

    if (val != null) {
      return val;
    }

    throw StateError(
      'ValueStream has no value. You should ensure the stream has a value before calling value(), '
      'or use watch(stream, initial: ...) instead.\n'
      'Stream: $stream',
    );
  }
}

/// 负责依赖收集、事件缓存、订阅管理与按需重建。
class _StreamObState extends State<StreamOb> with DisposeBagProvider {
  /// 订阅映射：保证每个依赖流对应一个订阅，便于增量维护
  final Map<Stream<dynamic>, StreamSubscription<dynamic>> _subs = {};

  /// 当前构建收集到的依赖集合
  final Set<Stream<dynamic>> _deps = <Stream<dynamic>>{};

  /// 最新值缓存
  final Map<Stream<dynamic>, dynamic> _latest = {};

  /// 重建节流标记：同一帧内合并多次事件为一次重建
  bool _rebuildScheduled = false;

  /// 登记依赖并返回最新值；无缓存时返回 initial
  T? _watch<T>(Stream<T> stream, {T? initial}) {
    _deps.add(stream);
    // 优先读取 ValueStream 的当前值
    if (stream is ValueStream<T>) {
      final vs = stream;
      if (vs.hasValue) {
        return vs.value;
      }
    }
    // 其次返回当前构建缓存到的最新值
    final has = _latest.containsKey(stream);
    if (has) {
      return _latest[stream] as T;
    }
    // 无缓存时返回初值
    return initial;
  }

  /// 根据依赖集合增量维护订阅
  void _ensureSubscriptions() {
    // 取消未使用的订阅
    _subs.removeWhere((stream, sub) {
      if (!_deps.contains(stream)) {
        sub.cancel();
        _latest.remove(stream);
        return true;
      }
      return false;
    });

    // 新增需要的订阅
    for (final stream in _deps) {
      if (_subs.containsKey(stream)) continue;

      final sub = stream.listen((event) {
        _latest[stream] = event;
        if (!mounted) return;
        if (_rebuildScheduled) return;
        _rebuildScheduled = true;
        scheduleMicrotask(() {
          if (mounted) {
            setState(() {
              _rebuildScheduled = false;
            });
          }
        });
      });
      // 加入 DisposeBag 管理
      sub.disposeBy(disposeBag);
      _subs[stream] = sub;
    }
  }

  /// 构建期收集依赖并维护订阅
  Widget _buildWithDependencyCollection(BuildContext context) {
    _deps.clear();
    final child = widget.builder(context, _watch, widget.child);
    _ensureSubscriptions();
    return child;
  }

  @override
  void dispose() {
    try {
      _subs.clear();
      _deps.clear();
      _latest.clear();
    } finally {
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildWithDependencyCollection(context);
  }
}
