part of easy_rxmvvm;

/// ViewModel 的基类，提供配置功能
abstract class ViewModel
    with DisposeMixin, DisposeBagProvider, ContextProviderMixin {
  /// 配置前回调
  @mustCallSuper
  void beforeConfig() {}

  /// 配置当前ViewModel
  void config() {}

  /// 配置后回调
  @mustCallSuper
  void afterConfig() {}

  @override
  void dispose() {
    disposeBag.dispose();
    super.dispose();
  }
}

/// ViewModel共享策略
enum ViewModelShareStrategy {
  /// 不共享
  none,

  /// 通过Provider来共享
  provider,

  /// 通过ViewModelStack来共享
  stack,

  /// 通过Provider和ViewModelStack来共享
  all;

  bool get useProvider =>
      this == ViewModelShareStrategy.provider ||
      this == ViewModelShareStrategy.all;

  bool get useStack =>
      this == ViewModelShareStrategy.stack ||
      this == ViewModelShareStrategy.all;
}

/// ViewModelFactory 抽象基类
abstract class BaseViewModelFactory<T extends ViewModel> extends Equatable {
  const BaseViewModelFactory();

  /// 创建 ViewModel
  T createViewModel(ViewModelConsumerStateMixin cache);

  /// 获取共享策略
  ViewModelShareStrategy get shareStrategy;

  /// 获取 ViewModel 类型
  Type get viewModelType => T;

  /// 构建 Provider
  Widget buildProvider(T viewModel, Widget child) {
    return ViewModelProvider<T>(viewModel: viewModel, child: child);
  }
}

/// 默认的 ViewModelFactory 实现
class ViewModelFactory<T extends ViewModel> extends BaseViewModelFactory<T> {
  final T Function() create;
  @override
  final ViewModelShareStrategy shareStrategy;
  final void Function(T)? beforeConfig;
  final void Function(T)? afterConfig;

  const ViewModelFactory(
    this.create, {
    this.shareStrategy = ViewModelShareStrategy.none,
    this.beforeConfig,
    this.afterConfig,
  });

  @override
  T createViewModel(ViewModelConsumerStateMixin cache) {
    try {
      final viewModel = create();
      cache.addToCache(viewModel);

      try {
        viewModel.beforeConfig();
        beforeConfig?.call(viewModel);
      } catch (error, stackTrace) {
        RxLogger.logError(error, stackTrace);
      }

      try {
        viewModel.config();
      } catch (error, stackTrace) {
        RxLogger.logError(error, stackTrace);
      }

      try {
        viewModel.afterConfig();
        afterConfig?.call(viewModel);
      } catch (error, stackTrace) {
        RxLogger.logError(error, stackTrace);
      }

      return viewModel;
    } catch (error, stackTrace) {
      RxLogger.logError(error, stackTrace);
      rethrow;
    }
  }

  @override
  List<Object?> get props => [T.runtimeType, shareStrategy];
}

/// ViewModelStack 用于管理 ViewModel 的堆栈
class ViewModelStack<T extends ViewModel> {
  static final getIt = GetIt.instance;

  /// 获取或创建 ViewModelStack
  static ViewModelStack getStack(Type type) {
    final name = type.toString();
    return getIt.registerSingletonIfAbsent<ViewModelStack>(
      () => ViewModelStack._(),
      instanceName: name,
    );
  }

  ViewModelStack._();

  final List<T> _stack = [];

  /// 将 ViewModel 压入堆栈
  void push(T viewModel) {
    _stack.add(viewModel);
    viewModel.disposeBag.addDisposeCallback(() => remove(viewModel));
    RxLogger.log(
        "${viewModel.runtimeType}Stack pushed, count: ${_stack.length}");
  }

  /// 从堆栈中移除 ViewModel
  void remove(T? viewModel) {
    if (_stack.remove(viewModel)) {
      RxLogger.log(
          "${viewModel.runtimeType}Stack removed, count: ${_stack.length}");
    }
  }

  /// 获取堆栈顶部的 ViewModel
  T? get top => _stack.isEmpty ? null : _stack.last;

  /// 获取堆栈中的 ViewModel 数量
  int get length => _stack.length;

  /// 清空堆栈
  void clear() {
    _stack.clear();
  }

  /// 检查堆栈是否为空
  bool get isEmpty => _stack.isEmpty;

  /// 检查堆栈是否不为空
  bool get isNotEmpty => _stack.isNotEmpty;
}
