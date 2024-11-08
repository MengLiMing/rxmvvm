part of easy_rxmvvm;

typedef LogCallback = void Function(String message);

class RxLogger {
  static LogCallback? _logCallback = kDebugMode ? print : null;

  /// 设置日志记录器
  /// [logger] 日志回调
  static void setLogger(
    LogCallback? logger,
  ) {
    _logCallback = logger;
  }

  /// 禁用日志
  static void disable() {
    _logCallback = null;
  }

  /// 记录普通日志
  static void log(String message) {
    _logCallback?.call('[RxMVVM] $message');
  }

  /// 记录警告日志
  static void warning(String message) {
    _logCallback?.call('[RxMVVM Warning] $message');
  }

  /// 记录错误日志
  static void logError(Object error, StackTrace stackTrace) {
    _logCallback?.call(
      '[RxMVVM Error] Error: $error\nStackTrace: $stackTrace',
    );
  }
}

extension LogStreamExtension<T> on Stream<T> {
  Stream<T> log({
    String? tag,
    String Function(T value)? formatter,
  }) {
    return doOnData((value) {
      final message = formatter?.call(value) ?? '$tag: Received - $value';
      RxLogger.log(message);
    }).doOnCancel(() {
      RxLogger.log('$tag: Cancelled');
    }).doOnDone(() {
      RxLogger.log('$tag: Done');
    }).doOnError((error, stackTrace) {
      RxLogger.logError(error, stackTrace);
    });
  }
}
