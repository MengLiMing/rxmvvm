part of rxmvvm;

/// 只创建一个ViewModel
mixin SingleViewModelMixin<T extends ViewModel, W extends StatefulWidget>
    on ViewModelConsumerStateMixin<W> {
  /// 获取 ViewModel
  T get viewModel {
    try {
      return getViewModel<T>()!;
    } catch (e) {
      rethrow;
    }
  }

  /// 创建 ViewModel 的方法
  T viewModelCreate();

  /// ViewModel 配置前回调
  @protected
  void onViewModelBeforeConfig(T viewModel) {}

  /// ViewModel 配置后回调
  @protected
  void onViewModelConfigured(T viewModel) {}

  @override
  @nonVirtual
  List<ViewModelFactory> get creators => [
        ViewModelFactory<T>(
          viewModelCreate,
          shareStrategy: shareStrategy,
          beforeConfig: onViewModelBeforeConfig,
          afterConfig: onViewModelConfigured,
        )
      ];
}
