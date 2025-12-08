part of easy_rxmvvm;

extension ListenableExtension on Listenable {
  DisposeHandler addListenerWithDispose(VoidCallback listener) {
    addListener(listener);

    return () {
      try {
        removeListener(listener);
      } catch (error, stackTrace) {
        RxLogger.logError(error, stackTrace);
      }
    };
  }
}

extension AnimationLocalStatusListenersMixinExtension
    on AnimationLocalStatusListenersMixin {
  DisposeHandler addStatusListenerWithDispose(
      AnimationStatusListener listener) {
    addStatusListener(listener);
    return () {
      try {
        removeStatusListener(listener);
      } catch (error, stackTrace) {
        RxLogger.logError(error, stackTrace);
      }
    };
  }
}
