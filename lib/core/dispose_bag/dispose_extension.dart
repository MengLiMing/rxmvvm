part of rxmvvm;

extension DisposeCallbackListExtension on List<DisposeHandler> {
  void disposeBy(DisposeBagMixin bag) {
    bag.addDisposeCallbacks(this);
  }
}

extension StreamSubscriptionListExtension on List<StreamSubscription> {
  void disposeBy(DisposeBagMixin bag) {
    bag.addSubscriptions(this);
  }
}

extension DisposeHandlerExtension on DisposeHandler {
  void disposeBy(DisposeBagMixin bag) {
    bag.addDisposeCallback(this);
  }

  void dispose() {
    try {
      call();
    } catch (error, stackTrace) {
      RxLogger.logError(error, stackTrace);
    }
  }
}

extension StreamSubscriptionDisposeExtension<T> on StreamSubscription<T> {
  StreamSubscription<T> disposeBy(DisposeBagMixin bag) {
    return bag.addSubscription(this);
  }
}
