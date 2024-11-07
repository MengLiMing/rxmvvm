// ignore_for_file: library_private_types_in_public_api

part of rxmvvm;

/// ViewModelConsumer 的构建器类型
typedef ViewModelConsumerBuilder<T extends ViewModel> = Widget Function(
    BuildContext context, T viewModel, Widget? child);

/// ViewModelConsumer 组件，允许在 Widget 树中消费 ViewModel
class ViewModelConsumer extends ViewModelConsumerStatefulWidget {
  /// 需要创建的 ViewModelFactory 列表
  final List<ViewModelFactory> creators;

  /// 共享 ViewModel的策略
  final ViewModelShareStrategy shareStrategy;

  /// 如果需要提供 child, 请使用该参数
  final Widget? child;

  /// 如果需要提供 builder, 请使用该参数
  final TransitionBuilder? builder;

  const ViewModelConsumer({
    super.key,
    this.shareStrategy = ViewModelShareStrategy.none,
    required this.creators,
    this.builder,
    this.child,
  });

  /// 创建一个 ViewModelConsumer，指定了单个 ViewModelFactory
  static ViewModelConsumer single<VM extends ViewModel>({
    Key? key,
    required ViewModelFactory<VM> creator,
    ViewModelConsumerBuilder<VM>? builder,
    Widget? child,
    ViewModelShareStrategy shareStrategy = ViewModelShareStrategy.none,
  }) {
    return ViewModelConsumer(
      key: key,
      creators: [creator],
      shareStrategy: shareStrategy,
      builder: builder != null
          ? (context, child) {
              final viewModel = context.getViewModel<VM>();
              assert(
                viewModel != null,
                'ViewModel of type $VM not found in context',
              );
              return builder(context, viewModel!, child);
            }
          : null,
      child: child,
    );
  }

  /// 一个不创建 ViewModel 的 ViewModelConsumer，用于在 Widget 树中某个位置获取 ViewModel
  static ViewModelConsumer retrieve<VM extends ViewModel>({
    Key? key,
    required ViewModelConsumerBuilder<VM> builder,
    Widget? child,
  }) {
    return ViewModelConsumer(
      key: key,
      creators: const [],
      shareStrategy: ViewModelShareStrategy.none,
      builder: (context, child) {
        final viewModel = context.getViewModel<VM>();
        assert(
          viewModel != null,
          'ViewModel of type $VM not found in context',
        );
        return builder(context, viewModel!, child);
      },
      child: child,
    );
  }

  @override
  _ViewModelConsumerState createState() => _ViewModelConsumerState();
}

class _ViewModelConsumerState extends State<ViewModelConsumer>
    with DisposeBagProvider, ViewModelConsumerStateMixin<ViewModelConsumer> {
  @override
  List<ViewModelFactory> get creators => widget.creators;

  @override
  ViewModelShareStrategy get shareStrategy => widget.shareStrategy;

  @override
  Widget build(BuildContext context) {
    return widget.builder?.call(context, widget.child) ??
        widget.child ??
        const SizedBox.shrink();
  }

  @override
  void didUpdateWidget(covariant ViewModelConsumer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.creators.equal(widget.creators)) {
      reinitializeViewModels();
    }
  }
}

/// ViewModelConsumer 的基类
abstract class ViewModelConsumerStatefulWidget extends StatefulWidget {
  const ViewModelConsumerStatefulWidget({super.key});

  @override
  StatefulElement createElement() => ConsumerStatefulElement(this);
}

/// ConsumerStatefulElement 用于处理 ViewModel 的上下文更新
class ConsumerStatefulElement extends StatefulElement {
  ConsumerStatefulElement(ViewModelConsumerStatefulWidget super.widget);

  ViewModelConsumerStateMixin get consumer =>
      state as ViewModelConsumerStateMixin;

  @override
  Widget build() {
    // 使用 Builder 确保获取到正确的 BuildContext
    return consumer.buildProviderTree(
      Builder(
        builder: (context) {
          consumer.updateContext(context);
          return super.build();
        },
      ),
    );
  }

  /// 获取缓存的 ViewModel
  VM? getViewModel<VM extends ViewModel>() {
    return consumer.getViewModel<VM>();
  }
}
