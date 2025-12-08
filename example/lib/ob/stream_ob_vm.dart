import 'package:easy_rxmvvm/easy_rxmvvm.dart';

/// 示例 ViewModel：提供计数及派生流
class StreamObViewModel extends ViewModel {
  /// 当前计数，BehaviorSubject 支持读取当前值
  final counter = 0.rx;

  /// 偶数计数派生流，做筛选与去重
  late final Stream<int> evenCounter =
      counter.stream.where((v) => v.isEven).distinct();

  /// 去重后的计数流（稳定实例），避免在构建期频繁创建新流导致读值为 null
  late final Stream<int> distinctCounter = counter.distinct();

  /// 增加计数
  void increment(int step) {
    counter.value = counter.value + step;
  }

  /// 重置计数
  void reset() {
    counter.value = 0;
  }

  /// 初始化配置（示例无需额外订阅）
  @override
  void config() {}
}
