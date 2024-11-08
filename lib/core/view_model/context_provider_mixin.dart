part of easy_rxmvvm;

/// 获取BuildContext的Mixin
///
/// 为ViewModel提供获取上下文的能力
mixin ContextProviderMixin on DisposeMixin {
  /// 方便BuildContext的获取
  final _contextSubject =
      BehaviorSubject<WeakReference<BuildContext>?>.seeded(null);

  /// 获取上下文
  BuildContext? get context => _contextSubject.value?.target;

  /// 上下文变化的流
  Stream<BuildContext> get contextStream => _contextSubject.stream
      .map((ref) => ref?.target)
      .whereNotNull()
      .distinct();

  /// BuildContext变化重新获取对应类型的ViewModel
  Stream<T> getViewModel<T extends ViewModel>({
    bool listen = false,
  }) {
    if (_contextSubject.isClosed) {
      RxLogger.warning('$runtimeType: Cannot get ViewModel after dispose');
      return const Stream.empty();
    }

    return contextStream.asyncMap((context) async {
      try {
        return context.getViewModel<T>(inheritedListen: listen);
      } catch (error, stackTrace) {
        RxLogger.logError(error, stackTrace);
        return null;
      }
    }).whereNotNull();
  }

  /// 只获取一次ViewModel，可以用来在其中做一些配置
  /// 返回的 [StreamSubscription] 需要调用 `dispose` 进行清理。
  ///
  /// 如：在当前viewModel的config中 需要其他共享的viewmodel进行一些配置，可以使用此方法
  StreamSubscription<T> configByViewModel<T extends ViewModel>(
    ValueChanged<T> onConfig, {
    bool listen = false,
  }) {
    return getViewModel<T>(listen: listen).take(1).listen(
          onConfig,
          onError: (error, stackTrace) => RxLogger.logError(error, stackTrace),
          onDone: () => RxLogger.log(
              '$runtimeType: Configuration with ${T.toString()} completed'),
        );
  }

  void updateContext(BuildContext context) {
    _contextSubject.safeAdd(WeakReference(context));
  }

  @override
  void dispose() {
    try {
      if (!_contextSubject.isClosed) {
        RxLogger.log('$runtimeType: Disposing');
        _contextSubject.close();
      }
    } catch (error, stackTrace) {
      RxLogger.logError(error, stackTrace);
    } finally {
      super.dispose();
    }
  }
}
