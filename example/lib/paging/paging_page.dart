// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:easy_rxmvvm/easy_rxmvvm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rxmvvm_example/paging/paging_vm.dart';
import 'package:rxmvvm_example/rxmvvm_util/loading_mixin.dart';
import 'package:rxmvvm_example/rxmvvm_util/refresh_controller_extension.dart';

class PagingPage extends ViewModelConsumerStatefulWidget {
  const PagingPage({super.key});

  @override
  ViewModelConsumerStateMixin<PagingPage> createState() => _PagingPageState();
}

class _PagingPageState extends State<PagingPage>
    with
        DisposeBagProvider,
        ViewModelConsumerStateMixin<PagingPage>,
        SingleViewModelMixin<PagingViewModel, PagingPage> {
  final refreshController = RefreshController();

  @override
  void initState() {
    super.initState();

    refreshController
        .changeStatusBy(viewModel.pageRequestStateStream)
        .disposeBy(disposeBag);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('分页请求'),
      ),
      body: StreamBuilderFactory.buildBehavior(viewModel.pageItemsBehavior,
          builder: (context, items, _) {
        return SmartRefresher(
          controller: refreshController,
          onRefresh: viewModel.refreshData,
          onLoading: viewModel.loadMoreData,
          enablePullUp: true,
          child: ListView.builder(
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(items[index]),
              );
            },
            itemCount: items.length,
          ),
        );
      }),
    );
  }

  /// 注意：此处为什么没有卸载initState中，是因为super.initState之后，已经执行过viewModel.config(),在之后再去监听会缺少状态
  ///
  /// beforeViewModelConfig是在对应viewModel.config执行之前调用
  @override
  void onViewModelBeforeConfig() {
    [
      viewModel.onOnceLoadingState((value) {
        value ? EasyLoading.show() : EasyLoading.dismiss();
      }, initialValue: false),
    ].disposeBy(disposeBag);
  }

  @override
  PagingViewModel viewModelCreate() => PagingViewModel();
}
