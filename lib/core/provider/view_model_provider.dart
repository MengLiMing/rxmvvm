part of rxmvvm;

/// 一个 InheritedWidget，用于提供 ViewModel 给子 Widget
///
/// 该类可以在 Widget 树中提供一个 ViewModel，子 Widget 可以使用
/// [ViewModelProvider.of] 方法来获取该 ViewModel
class ViewModelProvider<T extends ViewModel> extends InheritedWidget {
  final T viewModel;

  const ViewModelProvider({
    super.key,
    required this.viewModel,
    required Widget child,
  }) : super(child: child);

  static T? of<T extends ViewModel>(
    BuildContext context, {
    bool listen = false,
  }) {
    try {
      final provider = listen
          ? context.dependOnInheritedWidgetOfExactType<ViewModelProvider<T>>()
          : context.getInheritedWidgetOfExactType<ViewModelProvider<T>>();
      return provider?.viewModel;
    } catch (error, stackTrace) {
      RxLogger.logError(error, stackTrace);
      return null;
    }
  }

  @override
  bool updateShouldNotify(covariant ViewModelProvider<T> oldWidget) {
    return oldWidget.viewModel != viewModel;
  }
}
