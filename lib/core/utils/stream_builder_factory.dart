part of easy_rxmvvm;

typedef StreamConsumerBuilder<T> = Widget Function(
    BuildContext context, T data, Widget? child);

class StreamBuilderFactory {
  static Widget build<T>({
    Key? key,
    required Stream<T> stream,
    required StreamConsumerBuilder<T?> builder,
    T? initialData,
    Widget? child,
  }) {
    return StreamBuilder<T>(
      key: key,
      stream: stream,
      initialData: initialData,
      builder: (context, snapshot) {
        return builder(context, snapshot.data, child);
      },
    );
  }

  static Widget buildBehavior<T>(
    BehaviorSubject<T> behaviorSubject, {
    Key? key,
    required StreamConsumerBuilder<T> builder,
    Widget? child,
  }) {
    return build(
      key: key,
      stream: behaviorSubject.stream,
      builder: (context, data, child) =>
          builder(context, data ?? behaviorSubject.value, child),
      initialData: behaviorSubject.value,
      child: child,
    );
  }
}
