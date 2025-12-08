part of easy_rxmvvm;

/// rx一些便捷操作扩展
extension StreamBindExtension<T> on Stream<T> {
  /// 不关心数据返回一个StreamSubscription
  StreamSubscription<T> emptyListen() {
    return listen((_) {});
  }

  /// 将当前 Stream 绑定到 StreamSink
  ///
  /// [sink] 需要绑定的 StreamSink
  ///
  /// return 一个 StreamSubscription，需要在生命周期结束时调用 `dispose` 进行清理
  StreamSubscription<T> bindToSubject(StreamSink<T> sink) {
    return listen((value) {
      sink.add(value);
    });
  }

  /// 将当前 Stream 绑定到 ValueNotifier
  ///
  /// [notifier] 需要绑定的 ValueNotifier
  ///
  /// return 一个 StreamSubscription，需要在生命周期结束时调用 `dispose` 进行清理
  StreamSubscription<T> bindToNotifier(ValueNotifier<T> notifier) {
    return listen((value) {
      notifier.value = value;
    });
  }

  /// 回顾历史元素
  ///
  /// count: 回复历史元素的个数
  /// return 历史数据 + 当前值的数组
  ///
  /// BehaviorSubject<String?> subject = BehaviorSubject<String?>.seeded(null);
  /// subject.review(count: 2).listen((event) {
  ///   print(event);
  /// });
  ///
  /// 打印 [null]
  /// subject.add('a'); 打印 [null, a]
  /// subject.add('b'); 打印 [null, a, b]
  /// subject.add('c'); 打印 [a, b, c]
  /// subject.add('d'); 打印 [b, c, d]
  Stream<List<T>> review({
    int count = 1,
  }) {
    if (count <= 0) {
      return map((event) => [event]);
    }

    return scan<List<T>>(
      (accumulated, value, index) {
        if (accumulated.isEmpty) {
          return [value];
        } else {
          final startIndex = math.max(0, accumulated.length - count);
          return accumulated.sublist(startIndex) + [value];
        }
      },
      [],
    );
  }

  /// 监听 可以检测历史数据
  StreamSubscription<List<T?>> listenWithPrevious(
    void Function(T? previous, T? current) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return review().listen(
      (event) {
        /// 为空表明肯定没有新元素所以就不调用外部事件了
        if (event.isEmpty) {
          return;
        }
        if (event.length == 1) {
          onData(null, event.last);
        } else {
          onData(event[event.length - 2], event.last);
        }
      },
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

extension ValueNotifierBindExtension<T> on ValueListenable<T> {
  /// 将当前ValueListenable绑定到StreamSink上，使得ValueListenable的值变化时更新StreamSink的值。
  ///
  /// [sink] 是要绑定的StreamSink。
  ///
  /// 返回的 [DisposeHandler] 需要调用 `dispose` 进行清理。
  DisposeHandler bindToSubject(StreamSink<T> sink) {
    /// 监听 ValueListenable 的变化，并将变化后的值传递给 sink。
    listener() => sink.add(value);

    /// 添加监听器，以便在 ValueListenable 的值变化时调用 listener。
    addListener(listener);

    /// 返回一个取消绑定的回调。
    return () {
      /// 移除 listener，以便在 ValueListenable 的值变化时不再调用 listener。
      removeListener(listener);
    };
  }

  /// 将当前ValueListenable绑定到ValueNotifier上，使得ValueListenable的值变化时更新ValueNotifier的值。
  ///
  /// [notifier] 是要绑定的ValueNotifier。
  ///
  /// 返回的 [DisposeHandler] 需要调用 `dispose` 进行清理。
  DisposeHandler bindToNotifier(ValueNotifier<T> notifier) {
    /// 监听 ValueListenable 的变化，并将变化后的值传递给 notifier。
    listener() => notifier.value = value;

    /// 添加监听器，以便在 ValueListenable 的值变化时调用 listener。
    addListener(listener);

    /// 返回一个取消绑定的回调。
    return () {
      /// 移除 listener，以便在 ValueListenable 的值变化时不再调用 listener。
      removeListener(listener);
    };
  }
}

extension FutureValueBindExtension<T> on Future<T> {
  Future<T> bindToSubject(StreamSink<T> sink) async {
    final result = await this;
    sink.add(result);
    return result;
  }

  Future<T> bindToNotifier(ValueNotifier<T> notifier) async {
    final result = await this;
    notifier.value = result;
    return result;
  }
}

extension SubjectExtension<T> on Subject<T> {
  /// 安全地添加数据
  /// 如果 Subject 已关闭，则忽略操作并记录警告
  void safeAdd(T value) {
    if (isClosed) {
      RxLogger.warning('Attempt to add value to closed Subject');
      return;
    }

    try {
      add(value);
    } catch (error, stackTrace) {
      RxLogger.logError(error, stackTrace);
    }
  }
}

extension BehaviorSubjectSetIfChanged<T> on BehaviorSubject<T> {
  /// 仅在值变化时更新，避免无效重建
  void setIfChanged(T next, {bool Function(T a, T b)? equals}) {
    final eq = equals ?? (T a, T b) => a == b;
    final prev = hasValue ? value : null;
    if (!hasValue || !eq(prev as T, next)) {
      safeAdd(next);
    }
  }
}
