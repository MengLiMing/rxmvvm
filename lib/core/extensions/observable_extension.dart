part of rxmvvm;

/// 一些基础类型的便捷创建BehaviorSubject
extension ObservableExtension<T extends Object> on T {
  /// 创建一个带有初始值的 BehaviorSubject
  BehaviorSubject<T> get rx => BehaviorSubject.seeded(this);

  /// 创建一个带有初始值的 ValueNotifier
  ValueNotifier<T> get notifier => ValueNotifier(this);

  /// 创建一个可空的 BehaviorSubject
  BehaviorSubject<T?> get nullRx => BehaviorSubject<T?>.seeded(this);

  ValueNotifier<T?> get nullNotifier => ValueNotifier<T?>(this);
}

/// 创建一个 BehaviorSubject
BehaviorSubject<T?> nullRx<T>([T? value]) => BehaviorSubject<T?>.seeded(value);

ValueNotifier<T?> nullNotifier<T>([T? value]) => ValueNotifier<T?>(value);
