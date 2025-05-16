part of easy_rxmvvm;

extension ListenableExtension on Listenable {
  DisposeHandler addListenerWithDispose(VoidCallback listener) {
    addListener(listener);

    return () {
      removeListener(listener);
    };
  }
}

extension AnimationLocalStatusListenersMixinExtension
    on AnimationLocalStatusListenersMixin {
  DisposeHandler addStatusListenerWithDispose(
      AnimationStatusListener listener) {
    addStatusListener(listener);
    return () {
      removeStatusListener(listener);
    };
  }
}
