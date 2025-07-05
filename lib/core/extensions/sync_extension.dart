part of easy_rxmvvm;

extension StreamAsyncExtension<T> on Stream<T> {
  /// 将 Stream 与 ChangeNotifier 同步
  /// [notifier] 监听器
  /// [onChanged] 值改变时的回调
  /// [getValue] 获取当前值的方法
  /// [setValue] 设置新值的方法
  DisposeHandler syncWith(
    ChangeNotifier notifier,
    ValueChanged<T> onChanged, {
    required T Function() getValue,
    required void Function(T) setValue,
  }) {
    // 使用 distinct() 避免重复值触发更新
    final subscription = distinct().listen((newValue) {
      // 只有当值真正改变时才更新
      if (getValue() != newValue) {
        setValue(newValue);
      }
    });

    // 监听器回调
    void listener() {
      try {
        onChanged(getValue());
      } catch (error, stackTrace) {
        RxLogger.logError(error, stackTrace);
      }
    }

    notifier.addListener(listener);

    // 返回取消监听的方法
    return () {
      try {
        notifier.removeListener(listener);
        subscription.cancel();
      } catch (error, stackTrace) {
        RxLogger.logError(error, stackTrace);
      }
    };
  }
}

extension SubjectSyncExtension<T> on Subject<T> {
  /// 将 Subject 与 ValueNotifier 同步
  /// [notifier] 值通知器
  DisposeHandler syncWithNotifier(ValueNotifier<T> notifier) {
    // 只在 Subject 未关闭时同步初始值
    if (!isClosed && notifier.value != null) {
      add(notifier.value);
    }
    return syncWith(
      notifier,
      add,
      getValue: () => notifier.value,
      setValue: (value) => notifier.value = value,
    );
  }
}

extension SubjectTextElementSyncExtension on Subject<String> {
  /// 将 Subject 与 TextEditingController 同步
  /// [controller] 文本编辑控制器
  DisposeHandler syncWithTextController(TextEditingController controller) {
    // 只在 Subject 未关闭时同步初始值
    if (!isClosed && controller.text.isNotEmpty) {
      add(controller.text);
    }
    return syncWith(
      controller,
      add,
      getValue: () => controller.text,
      setValue: (value) => controller.text = value,
    );
  }
}
