import 'package:flutter/material.dart';
import 'package:rxmvvm/rxmvvm.dart';
import 'package:rxmvvm_example/inherited/a_vm.dart';
import 'package:rxmvvm_example/inherited/b_vm.dart';

class InheritedChildWidget extends StatelessWidget {
  const InheritedChildWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModelA = context.getViewModel<AViewModel>();
    final viewModelB = context.getViewModel<BViewModel>();
    return DefaultTextStyle(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        height: 1.6,
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          color: Colors.blue,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(viewModelA == null ? "没有获取到AViewModel" : "获取到了AViewModel"),
              Text(viewModelB == null ? "没有获取到BViewModel" : "获取到了BViewModel"),
            ],
          ),
        ),
      ),
    );
  }
}
