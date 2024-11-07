# rxmvvm

基于 rxdart 的 mvvm 框架

## 使用说明

## 代码块

### vsCode 添加代码块步骤

1. 打开 vsCode
2. 按下快捷键 `Ctrl + Shift + P` 打开命令面板
3. 输入 `Snippets: Configure Snippets` 并选择
4. 选择 `dart.json` 文件
5. 在 `dart.json` 文件中添加下方代码块

```json
{
  "Consumer ViewModel": {
    "prefix": "rxvmConsumers",
    "description": "创建支持提供多个viewModel的StatefulWidget",
    "body": [
      "class $1 extends ViewModelConsumerStatefulWidget {",
      "\tconst $1({super.key});",
      "\n",
      "\t@override",
      "\tViewModelConsumerStateMixin<$1> createState() => _$1State();",
      "}\n",
      "class _$1State extends State<$1> with DisposeBagProvider, ViewModelConsumerStateMixin<$1> {",
      "\t@override",
      "\tWidget build(BuildContext context) {",
      "\t\treturn Container();",
      "\t}",
      "\n",
      "\t@override",
      "\t// TODO: implement creaters",
      "\tList<ViewModelFactory<ViewModel>> get creators => throw UnimplementedError();",
      "}"
    ]
  },
  "Consumer SingleViewModel": {
    "prefix": "rxvmConsumer",
    "description": "创建支持提供单个viewModel的StatefulWidget",
    "body": [
      "class $1 extends ViewModelConsumerStatefulWidget {",
      "\tconst $1({super.key});",
      "\n",
      "\t@override",
      "\tViewModelConsumerStateMixin<$1> createState() => _$1State();",
      "}\n",
      "class _$1State extends State<$1> with DisposeBagProvider, ViewModelConsumerStateMixin<$1>, SingleViewModelMixin<$2, $1> {",
      "\t@override",
      "\tWidget build(BuildContext context) {",
      "\t\treturn Container();",
      "\t}",
      "\n",
      "\t@override",
      "\t$2 viewModelCreate() => $2();",
      "}"
    ]
  },
  "Consumer RetrieveViewModel": {
    "prefix": "rxvmConsumerRetrive",
    "description": "创建只获取单个viewModel的StatefulWidget",
    "body": [
      "class $1 extends ViewModelConsumerStatefulWidget {",
      "\tconst $1({super.key});",
      "\n",
      "\t@override",
      "\tViewModelConsumerStateMixin<$1> createState() => _$1State();",
      "}\n",
      "class _$1State extends State<$1> with DisposeBagProvider, ViewModelConsumerStateMixin<$1>, RetrieveViewModelMixin<$2, $1> {",
      "\t@override",
      "\tWidget build(BuildContext context) {",
      "\t\treturn Container();",
      "\t}",
      "}"
    ]
  },
  "Rxvvm ViewModel Class": {
    "prefix": "rxvmViewModel",
    "description": "创建一个 ViewModel",
    "body": [
      "class $1ViewModel extends ViewModel {",
      "\t@override",
      "\tvoid config() {",
      "\t\t// TODO: implement config",
      "\t}",
      "}"
    ]
  },
  "ViewModelFactory Creation": {
    "prefix": "rxvmFactory",
    "description": "创建一个 ViewModelFactory 实例",
    "body": ["ViewModelFactory<${1:ViewModel}>(${2:() => ${1}()})"]
  }
}
```
