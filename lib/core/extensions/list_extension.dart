part of easy_rxmvvm;

/// List 扩展方法
extension ListExtension<T> on List<T> {
  /// 获取指定索引的元素，如果索引越界则返回 null
  T? getOrNull(int index) {
    if (index >= 0 && index < length) {
      return this[index];
    }
    return null;
  }

  /// 安全地获取指定索引的元素
  /// 如果索引越界则返回默认值
  T getOrDefault(int index, T defaultValue) {
    return getOrNull(index) ?? defaultValue;
  }

  /// 判断两个列表是否相等（元素相同且顺序相同）
  bool equal(List<T>? other) {
    if (other == null) return false;
    if (identical(this, other)) return true;
    if (length != other.length) return false;

    for (var i = 0; i < length; i++) {
      final item1 = this[i];
      final item2 = other[i];

      if (item1 == null) {
        if (item2 != null) return false;
        continue;
      }

      if (item1 != item2) return false;
    }

    return true;
  }

  /// 安全地添加元素
  void safeAdd(T element) {
    // 对于固定长度列表，add 会抛出异常。
    // 但通常我们不建议在扩展方法中捕获此类编程错误。
    // 如果列表是不可修改的，调用者应该自己知道。
    // 这里保留 try-catch 主要是为了防止不可变列表抛出异常。
    try {
      add(element);
    } catch (error, stackTrace) {
      RxLogger.logError(error, stackTrace);
    }
  }

  /// 安全地移除元素
  bool safeRemove(T element) {
    try {
      return remove(element);
    } catch (error, stackTrace) {
      RxLogger.logError(error, stackTrace);
      return false;
    }
  }
}
