import 'package:easy_rxmvvm/easy_rxmvvm.dart';
import 'package:equatable/equatable.dart';

enum PageRequestState implements Equatable {
  /// 空闲状态
  idle,

  /// 正在刷新
  refreshing,

  /// 刷新完成且有更多数据
  refreshCompleted,

  /// 刷新完成且无更多数据
  refreshCompletedNoMoreData,

  /// 下拉刷新失败
  refreshFailed,

  /// 正在加载更多
  loading,

  /// 加载更多完成
  loadCompleted,

  /// 没有更多数据
  loadCompletedNoMoreData,

  /// 加载更多失败
  loadFailed;

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [this];
}

class PageResult<T> {
  final List<T> items;
  final bool hasMore;

  const PageResult(
    this.items,
    this.hasMore,
  );
}

/// 分页请求控制器
class PageRequestController<T> with DisposeMixin, PageRequestMixin<T> {
  final Future<PageResult<T>?> Function(int page) _requestPage;

  PageRequestController({
    required Future<PageResult<T>?> Function(int page) requestPage,
    int initialPage = 1,
  }) : _requestPage = requestPage {
    this.initialPage = initialPage;
  }

  @override
  Future<PageResult<T>?> requestPage(int page) {
    return _requestPage(page);
  }
}

/// 提供统一的分页管理
mixin PageRequestMixin<T> on DisposeMixin {
  final _pageSubject = 1.rx; // 默认从 1 开始
  final pageItemsBehavior = <T>[].rx;
  final _pageStateSubject = PageRequestState.idle.rx;

  /// 分页数据
  Stream<List<T>> get pageItemsStream => pageItemsBehavior.stream;

  /// 分页请求状态监听
  Stream<PageRequestState> get pageRequestStateStream =>
      _pageStateSubject.stream.distinct();

  List<T> get items => pageItemsBehavior.value;
  int get currentPage => _pageSubject.value;

  PageRequestState get currentPageState => _pageStateSubject.value;

  /// 初始页码，可配置
  int initialPage = 1;

  /// 是否有更多数据
  bool get hasMoreData =>
      currentPageState != PageRequestState.refreshCompletedNoMoreData &&
      currentPageState != PageRequestState.loadCompletedNoMoreData;

  /// 设置数据项
  void setItems(List<T> newItems) {
    pageItemsBehavior.value = newItems;
    pageItemsBehavior.safeAdd(newItems);
  }

  /// 添加数据项
  void addItems(List<T> moreItems) {
    pageItemsBehavior.value += moreItems;
  }

  /// 设置当前页码
  void setPage(int page) {
    _pageSubject.safeAdd(page);
  }

  /// 设置分页状态
  void setState(PageRequestState state) {
    if (state != _pageStateSubject.value) {
      _pageStateSubject.safeAdd(state);
    }
  }

  /// 刷新数据逻辑
  Future<void> refreshData() async {
    if (currentPageState == PageRequestState.refreshing) return;
    setState(PageRequestState.refreshing);
    setPage(initialPage); // 刷新时从初始页开始
    try {
      final result = await requestPage(currentPage);
      if (result == null) {
        setState(PageRequestState.refreshCompleted);
        return;
      }
      setItems(result.items);
      setState(result.hasMore
          ? PageRequestState.refreshCompleted
          : PageRequestState.refreshCompletedNoMoreData);
    } catch (_) {
      setState(PageRequestState.refreshFailed);
    }
  }

  /// 加载更多数据逻辑，只有在加载成功后才递增 `page`
  Future<void> loadMoreData() async {
    if (currentPageState == PageRequestState.loading || !hasMoreData) return;
    setState(PageRequestState.loading);
    try {
      final result = await requestPage(currentPage + 1); // 请求下一页的数据
      if (result == null) {
        setState(PageRequestState.loadCompleted);
        return;
      }
      addItems(result.items);
      if (!result.hasMore) {
        setState(PageRequestState.loadCompletedNoMoreData); // 没有更多数据
      } else {
        setPage(currentPage + 1);
        setState(PageRequestState.loadCompleted);
      }
    } catch (_) {
      setState(PageRequestState.loadFailed);
    }
  }

  Future<PageResult<T>?> requestPage(int page);

  @override
  void dispose() {
    _pageSubject.close();
    pageItemsBehavior.close();
    _pageStateSubject.close();
    super.dispose();
  }
}
