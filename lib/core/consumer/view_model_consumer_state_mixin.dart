part of rxmvvm;

/// ViewModel 的生命周期管理
mixin ViewModelConsumerStateMixin<T extends StatefulWidget>
    on State<T>, DisposeBagProvider {
  final _viewModelCache = ViewModelContainer();

  /// creators 是 ViewModel 的工厂列表
  List<ViewModelFactory> get creators;

  /// ViewModel共享策略
  ViewModelShareStrategy get shareStrategy => ViewModelShareStrategy.none;

  late Widget Function(Widget child) _builder;

  @override
  void initState() {
    super.initState();
    _initializeViewModels();
  }

  void _initializeViewModels() {
    try {
      _viewModelCache.clear();
      _builder = (child) => child;

      for (final creator in creators.reversed) {
        final useStack =
            shareStrategy.useStack || creator.shareStrategy.useStack;
        final useProvider =
            shareStrategy.useProvider || creator.shareStrategy.useProvider;
        _createViewModel(creator, useStack, useProvider);
      }
    } catch (error, stackTrace) {
      RxLogger.logError(error, stackTrace);
      rethrow;
    }
  }

  void _createViewModel(
    ViewModelFactory creator,
    bool useStack,
    bool useProvider,
  ) {
    try {
      final viewModel = creator.createViewModel(this);

      if (useStack) {
        ViewModelStack.getStack(viewModel.runtimeType).push(viewModel);
      }

      if (useProvider) {
        final currentBuilder = _builder;
        _builder = (child) => creator.buildProvider(
              viewModel,
              currentBuilder(child),
            );
      }
    } catch (error, stackTrace) {
      RxLogger.logError(error, stackTrace);
      rethrow;
    }
  }

  /// 构建 Provider 树
  Widget buildProviderTree(Widget child) {
    return _builder(child);
  }

  /// 更新 ViewModel 的上下文
  void updateContext(BuildContext context) {
    _viewModelCache.updateContext(context);
  }

  /// 获取缓存的 ViewModel
  VM? getViewModel<VM extends ViewModel>() {
    return _viewModelCache.get<VM>();
  }

  /// 添加 ViewModel 到缓存中
  void addToCache<VM extends ViewModel>(VM viewModel) {
    _viewModelCache.add(viewModel);
  }

  @override
  void dispose() {
    try {
      disposeBag.dispose();
      _viewModelCache.clear();
    } catch (error, stackTrace) {
      RxLogger.logError(error, stackTrace);
    } finally {
      super.dispose();
    }
  }

  /// 重新初始化所有 ViewModel
  void reinitializeViewModels() {
    _initializeViewModels();
  }
}
