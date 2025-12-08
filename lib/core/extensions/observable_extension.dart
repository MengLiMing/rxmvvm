part of easy_rxmvvm;

/// 一些基础类型的便捷创建BehaviorSubject
extension ObservableExtension<T extends Object> on T {
  /// 创建一个带有初始值的 BehaviorSubject
  BehaviorSubject<T> get rx => BehaviorSubject.seeded(this);

  /// 创建一个带有初始值的 ValueNotifier
  ValueNotifier<T> get notifier => ValueNotifier(this);

  /// 创建一个 Stream ，只发射当前值
  Stream<T> get asStream => Stream.value(this);
}

/// 针对可空类型的扩展
extension NullableObservableExtension<T> on T? {
  /// 创建一个可空的 BehaviorSubject
  BehaviorSubject<T?> get nullRx => BehaviorSubject<T?>.seeded(this);

  /// 创建一个可空的 ValueNotifier
  ValueNotifier<T?> get nullNotifier => ValueNotifier<T?>(this);
}

/// 创建一个可空的 BehaviorSubject (初始值为 null 或指定值)
///
/// 示例:
/// ```dart
/// final s1 = nullRx<int>(); // BehaviorSubject<int?> seeded with null
/// final s2 = nullRx<int>(1); // BehaviorSubject<int?> seeded with 1
/// ```
BehaviorSubject<T?> nullRx<T>([T? initial]) =>
    BehaviorSubject<T?>.seeded(initial);

/// 创建一个可空的 ValueNotifier (初始值为 null 或指定值)
///
/// 示例:
/// ```dart
/// final n1 = nullNotifier<int>(); // ValueNotifier<int?> with null
/// ```
ValueNotifier<T?> nullNotifier<T>([T? initial]) => ValueNotifier<T?>(initial);
