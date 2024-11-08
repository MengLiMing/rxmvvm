part of easy_rxmvvm;

/// ViewModel 的生命周期管理
mixin ViewModelConsumerStateMixin<T extends StatefulWidget>
    on State<T>, DisposeBagProvider {
  final _viewModelContainer = ViewModelContainer();

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
    _viewModelContainer.clear();
    _builder = (child) => child;

    _builder = creators.reversed.fold(
      _builder,
      _createAndBuildViewModel,
    );
  }

  Widget Function(Widget) _createAndBuildViewModel(
    Widget Function(Widget) currentBuilder,
    ViewModelFactory creator,
  ) {
    final viewModel = creator.createViewModel(this);

    if (_shouldUseStack(creator)) {
      ViewModelStack.getStack(viewModel.runtimeType).push(viewModel);
    }

    if (_shouldUseProvider(creator)) {
      return (child) => creator.buildProvider(
            viewModel,
            currentBuilder(child),
          );
    }

    return currentBuilder;
  }

  bool _shouldUseStack(ViewModelFactory creator) =>
      shareStrategy.useStack || creator.shareStrategy.useStack;

  bool _shouldUseProvider(ViewModelFactory creator) =>
      shareStrategy.useProvider || creator.shareStrategy.useProvider;

  /// 构建 Provider 树
  Widget buildProviderTree(Widget child) {
    return _builder(child);
  }

  /// 更新 ViewModel 的上下文
  void updateContext(BuildContext context) {
    _viewModelContainer.updateContext(context);
  }

  /// 获取当前Widget下的 ViewModel
  VM? getViewModel<VM extends ViewModel>() {
    return _viewModelContainer.get<VM>();
  }

  /// 添加 ViewModel 到缓存中
  void addToCache<VM extends ViewModel>(VM viewModel) {
    _viewModelContainer.add(viewModel);
  }

  @override
  void dispose() {
    try {
      disposeBag.dispose();
      _viewModelContainer.clear();
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

/// ViewModel 容器，用于管理当前 context 的 ViewModel
class ViewModelContainer {
  final Map<Type, ViewModel> _viewModels = {};

  /// 添加 ViewModel
  void add<VM extends ViewModel>(VM viewModel) {
    _viewModels[viewModel.runtimeType] = viewModel;
  }

  /// 获取指定类型的 ViewModel
  VM? get<VM extends ViewModel>() {
    try {
      return _viewModels[VM] as VM?;
    } catch (error, stackTrace) {
      RxLogger.logError(error, stackTrace);
      return null;
    }
  }

  /// 清除所有 ViewModel
  void clear() {
    try {
      for (final viewModel in _viewModels.values) {
        viewModel.dispose();
      }
      _viewModels.clear();
    } catch (error, stackTrace) {
      RxLogger.logError(error, stackTrace);
    }
  }

  /// 更新所有 ViewModel 的 context
  void updateContext(BuildContext context) {
    try {
      for (final viewModel in _viewModels.values) {
        viewModel.updateContext(context);
      }
    } catch (error, stackTrace) {
      RxLogger.logError(error, stackTrace);
    }
  }
}
