[[Compose 重组的性能风险和优化]]
## Compose 的生命周期
- 进入组合
  - 时机：当一个 Composable 被首次调用，并且其父 Composable 决定将其包含在 UI 树中时，就**进入了组合**
  - 这个阶段，Compose 运行时会执行该函数，生成对应的 UI 节点，添加到组合树中
  - remember 和 LauchedEffect 会在这时候执行
- 重组（Recomposition）：当 Composable 函数以来的 State 发生变化时，Compose 运行时会**智能地**重新执行这个 Composable 及其可能受影响的子函数，用来更新 UI
- 离开组合
  - 时机：当一个 Composable 函数不被其父 Composable 调用 (if 的条件变为 false，或者导航离开屏幕)，它就离开了组合
  - Compose 运行时会从组合树中移除对应的 UI 节点
  - 与 Composable 关联的 remember 值会释放（remeberSaveable 不会），DisposableEffect 的 onDispose 清理块会被执行
- 
## remember
  - 解决状态丢失的问题
  - remember 函数会在 Initial Composition 的时候执行 calculation lambda 获取状态的初始值并保存状态
  - 后续的  Recomposition 环节会直接返回这个值而不执行 cal lambda
  - **带 Key 的remember**：当任何一个 key 的值上一次组合时相比发生了变化，remeber 就会忘记之前存储的值并且 **重新执行** cal lambda 来计算并存储新的值
  - ```kotlin
	  @Composable
	  fun UserProfile(userId: String) {
	      // 当 userId 变化时，重新执行 fetchUserData(userId) 并记住新的结果
	      val user = remember(userId) { fetchUserData(userId) }
	      // 显示 user 信息...
	  }
	  ```
## rememberSaveable
  - 利用了 Android 的 Saved Instance State 机制，将 remember 的值保存到 Bundle 中，使得数据可以在 Activity/进程 重建时被系统保留和恢复
  - 所以 rememberSaveable 只能保存**基本数据类型**和**可序列化**对象
