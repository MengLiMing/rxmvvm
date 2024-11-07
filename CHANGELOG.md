# Changelog

## [1.0.0] - 2024-11-07

### Changed

- 优化了 ViewModelConsumer 的实现
  - 改进了 Provider 树的构建逻辑
  - 优化了性能
  - 简化了代码结构
- 改进了 ViewModelContainer（原 ViewModelCache）
  - 重命名为更准确的名称
  - 优化了内部实现
  - 改进了错误处理
- 优化了 ContextProviderMixin
  - 使用 WeakReference 管理 context
  - 改进了错误处理
  - 优化了生命周期管理
- 改进了 EventBus
  - 添加了更详细的日志记录
  - 优化了错误处理
  - 简化了 EventBusMixin 实现
- 优化了 DisposeBag 机制
  - 改进了错误处理
  - 优化了资源释放流程

### Added

- 添加了 BehaviorSubject 创建的便捷方法
  - 支持非空类型：`value.rx`
  - 支持可空类型：`nullRx<T>()`
  - 支持将非空转可空：`value.nullRx`

### Fixed

- 修复了 ViewModel dispose 后仍然发送事件的问题
- 修复了重复 dispose 的问题
- 改进了错误提示信息