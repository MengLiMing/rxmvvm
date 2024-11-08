part of easy_rxmvvm;

/// List 扩展方法
extension ListExtension<T> on List<T> {
  /// 获取指定索引的元素，如果索引越界则返回 null
  T? getOrNull(int index) {
    try {
      return index >= 0 && index < length ? this[index] : null;
    } catch (error, stackTrace) {
      RxLogger.logError(error, stackTrace);
      return null;
    }
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

  /// 获取列表的第一个元素，如果列表为空则返回 null
  T? get firstOrNull {
    return isEmpty ? null : first;
  }

  /// 获取列表的最后一个元素，如果列表为空则返回 null
  T? get lastOrNull {
    return isEmpty ? null : last;
  }

  /// 安全地添加元素
  /// 如果添加失败则记录错误
  void safeAdd(T element) {
    try {
      add(element);
    } catch (error, stackTrace) {
      RxLogger.logError(error, stackTrace);
    }
  }

  /// 安全地移除元素
  /// 如果移除失败则记录错误
  bool safeRemove(T element) {
    try {
      return remove(element);
    } catch (error, stackTrace) {
      RxLogger.logError(error, stackTrace);
      return false;
    }
  }
}
