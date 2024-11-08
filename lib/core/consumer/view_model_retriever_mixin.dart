part of easy_rxmvvm;

/// RetrieveViewModelMixin 用于在 State 中检索 ViewModel
mixin RetrieveViewModelMixin<T extends ViewModel, W extends StatefulWidget>
    on ViewModelConsumerStateMixin<W> {
  T? _viewModel;

  /// 获取 ViewModel，如果 _viewModel 为空则从 context 中获取
  T? get viewModel {
    _viewModel ??= context.getViewModel<T>();
    return _viewModel;
  }

  @override
  @nonVirtual

  /// 返回空的 ViewModelFactory 列表
  List<ViewModelFactory> get creators => [];
}
