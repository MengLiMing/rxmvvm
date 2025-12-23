part of easy_rxmvvm;

extension StreamAsyncExtension<T> on Stream<T> {
  DisposeHandler syncWith(
    ValueChanged<T> onChanged, {
    required T Function() getValue,
    required void Function(T) setValue,
    required DisposeHandler Function(VoidCallback listener) subscribe,
    T? initialValue,
    bool Function(T previous, T next)? equals,
  }) {
    // 比较函数：若传入 equals 则用它，否则用 ==
    bool areEqual(T? a, T? b) {
      if (a == null && b == null) return true;
      if (a == null || b == null) return false;
      return equals != null ? equals(a, b) : a == b;
    }

    // 计数器方案，支持嵌套的 programmatic 设置
    var programmaticSetCount = 0;

    void setValueProgrammatic(T v) {
      T current;
      try {
        current = getValue();
      } catch (_) {
        current = v;
      }

      if (areEqual(current, v)) return;

      programmaticSetCount++;
      try {
        setValue(v);
      } catch (err, st) {
        RxLogger.logError(err, st);
      } finally {
        scheduleMicrotask(() {
          try {
            programmaticSetCount--;
          } catch (_) {}
        });
      }
    }

    // 初始值：优先写入 initialValue（并用 equals 判断）
    if (initialValue != null) {
      try {
        final uiCur = getValue();
        if (!areEqual(uiCur, initialValue)) {
          setValueProgrammatic(initialValue);
        }
      } catch (_) {
        setValueProgrammatic(initialValue);
      }
    } else {
      // 若未传 initialValue，则把当前 UI 值通知一次 VM（初始化）
      try {
        onChanged(getValue());
      } catch (_) {}
    }

    // VM -> UI：若提供 equals，则让流先去重（减少 set 调用）
    final Stream<T> listenedStream =
        (equals == null) ? distinct() : distinct((p, n) => equals(p, n));

    final subscription = listenedStream.listen((newValue) {
      try {
        final uiCur = getValue();
        if (!areEqual(uiCur, newValue)) {
          setValueProgrammatic(newValue);
        }
      } catch (err, st) {
        RxLogger.logError(err, st);
      }
    }, onError: (err, st) {
      RxLogger.logError(err, st);
    });

    // UI -> VM：listener 会在程序性设置期间被忽略
    void listener() {
      if (programmaticSetCount > 0) return;
      try {
        final uiValue = getValue();
        onChanged(uiValue);
      } catch (err, st) {
        RxLogger.logError(err, st);
      }
    }

    final uiUnsubscribe = subscribe(listener);

    return () {
      try {
        uiUnsubscribe.call();
        subscription.cancel();
      } catch (err, st) {
        RxLogger.logError(err, st);
      }
    };
  }

  /// 对应的 Listenable 包装
  DisposeHandler syncWithListenable(
    Listenable listenable,
    ValueChanged<T> onChanged, {
    required T Function() getValue,
    required void Function(T) setValue,
    T? initialValue,
    bool Function(T previous, T next)? equals,
  }) {
    return syncWith(
      onChanged,
      getValue: getValue,
      setValue: setValue,
      initialValue: initialValue,
      equals: equals,
      subscribe: (listener) {
        listenable.addListener(listener);
        return () => listenable.removeListener(listener);
      },
    );
  }
}

extension SubjectTextSyncExtension on Stream<String> {
  DisposeHandler syncWithTextController(
    TextEditingController controller, {
    ValueChanged<String>? onUpdate,
    String? initialValue,
  }) {
    if (onUpdate == null && this is Subject<String>) {
      final subj = this as Subject<String>;
      onUpdate = (s) => subj.add(s);
    }

    String? init = initialValue;
    if (init == null && this is ValueStream<String>) {
      try {
        init = (this as ValueStream<String>).value;
      } catch (_) {}
    }

    if (onUpdate == null) {
      throw ArgumentError.value(
          onUpdate, 'onUpdate', '未提供写入回调，且流不是 Subject, 需要提供 onUpdate 回调。');
    }

    // 这里 equals 可以省略（默认会用 ==），我保留写法以示例如何传入自定义比较器
    return syncWithListenable(
      controller,
      onUpdate,
      getValue: () => controller.text,
      setValue: (v) => controller.text = v,
      initialValue: init,
      equals: (p, n) => p == n,
    );
  }
}

extension SubjectSyncExtension<T> on Subject<T> {
  DisposeHandler syncWithNotifier(
    ValueNotifier<T> notifier, {
    bool Function(T previous, T next)? equals,
  }) {
    T? initial;
    if (this is ValueStream<T>) {
      initial = (this as ValueStream<T>).value;
    }

    return syncWithListenable(
      notifier,
      add,
      getValue: () => notifier.value,
      setValue: (v) => notifier.value = v,
      initialValue: initial,
      equals: equals,
    );
  }
}
