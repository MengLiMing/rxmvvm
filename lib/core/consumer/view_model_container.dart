part of rxmvvm;

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
