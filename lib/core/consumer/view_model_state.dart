part of easy_rxmvvm;

/// 简化版 State 基类，用于单一 ViewModel 的页面
///
/// 自动集成了 [DisposeBagProvider]、[ViewModelConsumerStateMixin] 和 [SingleViewModelMixin]
abstract class ViewModelState<T extends StatefulWidget, VM extends ViewModel>
    extends State<T>
    with
        DisposeBagProvider,
        ViewModelConsumerStateMixin<T>,
        SingleViewModelMixin<VM, T> {}
