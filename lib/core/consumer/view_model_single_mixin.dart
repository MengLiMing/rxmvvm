part of easy_rxmvvm;

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
  void onViewModelBeforeConfig() {}

  /// ViewModel 配置后回调
  @protected
  void onViewModelConfigured() {}

  @override
  @nonVirtual
  List<ViewModelFactory> get creators => [
        ViewModelFactory<T>(
          viewModelCreate,
          shareStrategy: shareStrategy,
          beforeConfig: (_) => onViewModelBeforeConfig(),
          afterConfig: (_) => onViewModelConfigured(),
        )
      ];
}
