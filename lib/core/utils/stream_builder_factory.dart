part of easy_rxmvvm;

typedef StreamConsumerBuilder<T> = Widget Function(
    BuildContext context, T data, Widget? child);

typedef StreamOperator<T> = Stream<T> Function(Stream<T>);

/// 不关心AsyncSnapshot状态，只关注数据变化
///
/// 建议在 ViewModel 中处理流转换，不在 UI 层处理
///
/// 推荐使用StreamOb代替
class StreamBuilderFactory {
  StreamBuilderFactory._();

  static Widget build<T>({
    Key? key,
    required Stream<T> stream,
    required StreamConsumerBuilder<T?> builder,
    T? initialData,
    Widget? child,
  }) {
    return StreamBuilder<T>(
      key: key,
      stream: stream,
      initialData: initialData,
      builder: (context, snapshot) {
        return builder(context, snapshot.data, child);
      },
    );
  }

  /// 构建基于 BehaviorSubject 的 StreamBuilder
  ///
  /// 为了使用便捷，请确保 BehaviorSubject 有初始值
  static Widget buildBehavior<T>(
    BehaviorSubject<T> behaviorSubject, {
    Key? key,
    required StreamConsumerBuilder<T> builder,
    StreamTransformer<T, T>? transformer,
    StreamOperator<T>? transfer,
    Widget? child,
  }) {
    Stream<T> stream = behaviorSubject;
    if (transformer != null) {
      stream = stream.transform(transformer);
    }
    if (transfer != null) {
      stream = transfer(stream);
    }
    final initial = () {
      try {
        return behaviorSubject.value;
      } catch (_) {
        return null;
      }
    }();

    return build(
      key: key,
      stream: stream,
      builder: (context, data, child) =>
          builder(context, (data ?? initial) as T, child),
      initialData: initial,
      child: child,
    );
  }

  /// 合并多个同类型流并渲染最新事件
  static Widget buildMerge<T>({
    Key? key,
    required List<Stream<T>> streams,
    required StreamConsumerBuilder<T?> builder,
    StreamTransformer<T, T>? transformer,
    StreamOperator<T>? transfer,
    Widget? child,
  }) {
    var processed = Rx.merge(streams);
    if (transformer != null) {
      processed = processed.transform(transformer);
    }
    if (transfer != null) {
      processed = transfer(processed);
    }
    return build<T>(
      key: key,
      stream: processed,
      builder: builder,
      child: child,
    );
  }

  /// 组合两个流，并将二者的最新值传入 builder，避免嵌套
  static Widget buildCombine2<A, B>({
    Key? key,
    required Stream<A> a,
    required Stream<B> b,
    required Widget Function(BuildContext, A, B, Widget?) builder,
    A? initialA,
    B? initialB,
    StreamTransformer<(A, B), (A, B)>? transformer,
    StreamOperator<(A, B)>? transfer,
    Widget? child,
  }) {
    var sa = a;
    var sb = b;
    if (initialA != null) sa = sa.startWith(initialA);
    if (initialB != null) sb = sb.startWith(initialB);

    var processed = Rx.combineLatest2<A, B, (A, B)>(sa, sb, (x, y) => (x, y));
    if (transformer != null) {
      processed = processed.transform(transformer);
    }
    if (transfer != null) {
      processed = transfer(processed);
    }
    return StreamBuilder<(A, B)>(
      key: key,
      stream: processed,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) {
          return const SizedBox.shrink();
        }
        return builder(context, data.$1, data.$2, child);
      },
    );
  }

  /// 组合三个流，并将三者的最新值传入 builder
  static Widget buildCombine3<A, B, C>({
    Key? key,
    required Stream<A> a,
    required Stream<B> b,
    required Stream<C> c,
    required Widget Function(BuildContext, A, B, C, Widget?) builder,
    A? initialA,
    B? initialB,
    C? initialC,
    StreamTransformer<(A, B, C), (A, B, C)>? transformer,
    StreamOperator<(A, B, C)>? transfer,
    Widget? child,
  }) {
    var sa = a;
    var sb = b;
    var sc = c;
    if (initialA != null) sa = sa.startWith(initialA);
    if (initialB != null) sb = sb.startWith(initialB);
    if (initialC != null) sc = sc.startWith(initialC);

    Stream<(A, B, C)> combined = Rx.combineLatest3<A, B, C, (A, B, C)>(
      sa,
      sb,
      sc,
      (x, y, z) => (x, y, z),
    );
    if (transformer != null) {
      combined = combined.transform(transformer);
    }
    if (transfer != null) {
      combined = transfer(combined);
    }
    return StreamBuilder<(A, B, C)>(
      key: key,
      stream: combined,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) {
          return const SizedBox.shrink();
        }
        return builder(context, data.$1, data.$2, data.$3, child);
      },
    );
  }

  /// 组合多个同类型流，builder 接收最新值列表
  static Widget buildCombineList<T>({
    Key? key,
    required List<Stream<T>> streams,
    required Widget Function(BuildContext, List<T>, Widget?) builder,
    List<T>? initial,
    StreamTransformer<List<T>, List<T>>? transformer,
    StreamOperator<List<T>>? transfer,
    Widget? child,
  }) {
    var ss = streams;
    if (initial != null &&
        initial.isNotEmpty &&
        initial.length == streams.length) {
      ss = [
        for (var i = 0; i < streams.length; i++)
          streams[i].startWith(initial[i])
      ];
    }

    Stream<List<T>> processed = CombineLatestStream.list<T>(ss);
    if (transformer != null) {
      processed = processed.transform(transformer);
    }
    if (transfer != null) {
      processed = transfer(processed);
    }
    return StreamBuilder<List<T>>(
      key: key,
      stream: processed,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) {
          return const SizedBox.shrink();
        }
        return builder(context, data, child);
      },
    );
  }
}
