part of easy_rxmvvm;

mixin DisposeMixin {
  void dispose() {
    RxLogger.log("$runtimeType - dispose");
  }
}
