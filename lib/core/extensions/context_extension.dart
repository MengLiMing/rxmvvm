part of easy_rxmvvm;

extension ContextExtension on BuildContext {
  /// 获取当前的或共享的 ViewModel。
  ///
  /// 优先级先查自身 -> 依赖注入的 -> 再查InheritedWidget
  ///
  /// 如果需要查找共享的 ViewModel，请将 [forceInherited] 设置为 true。
  ///
  /// 当 [ignoreCache] 为 true 时，不查找自身的ViewModel，
  /// 当 [ignoreStack] 为 true 时，不查找堆栈中的ViewModel，
  /// 当 [ignoreInherited] 为 true 时，不查找Inherited中的，
  ///
  /// [inheritedListen] 参数决定是否在 ViewModel 发生变化时重新构建。
  T? getViewModel<T extends ViewModel>({
    bool ignoreCache = false,
    bool ignoreStack = false,
    bool ignoreInherited = false,
    bool inheritedListen = false,
  }) {
    // 如果不强制查找共享 ViewModel
    if (!ignoreCache) {
      T? result;
      // 检查当前上下文是否实现了 ConsumerStatefulElement
      if (this is ConsumerStatefulElement) {
        // 从缓存中获取 ViewModel
        result = (this as ConsumerStatefulElement).getViewModel<T>();
      }
      // 如果找到缓存的 ViewModel，直接返回
      if (result != null) {
        return result;
      }
    }

    if (!ignoreInherited) {
      // 查找共享的 ViewModel
      final result = ViewModelProvider.of<T>(this, listen: inheritedListen);
      if (result != null) {
        return result;
      }
    }

    // 查找依赖注入的 ViewModel
    if (!ignoreStack) {
      final result = _getStackCacheViewModel<T>();
      if (result != null) {
        return result;
      }
    }

    return null;
  }

  /// 获取DI注入的ViewModel
  T? _getStackCacheViewModel<T extends ViewModel>() {
    try {
      return ViewModelStack.getStack(T).top as T?;
    } catch (_) {
      return null;
    }
  }
}
