- LeakCanary 借助了 `Application.ActivityLifecycleCallbacks` 来监控所有 Activity 的销毁状态
- 
## 内存泄漏检测流程
  - 初始化和注册：使用application.registerActivityLifecycleCallbacks() 注入 LeakCanary 实现的监听接口
  - 监听 `onActivityDestroyed`：当该方法被调用时，逻辑上 Activity 会被销毁，下一次 gc 应该回收
  - 使用 WeakReference 指向这个 Activity 实例，等待 5s 后主动触发 gc。如果在等待和 GC 后，`WeakReference` **没有**出现在 `ReferenceQueue` 中，LeakCanary 就认为该 Activity 实例发生了内存泄漏（即它本该被回收，但由于还存在其他强引用链导致无法回收）。
  - 一旦确认泄漏，LeakCanary 会 dump 当前的 Java 堆内存快照 (hprof 文件)，并在后台线程中分析这个快照，找出导致该 Activity 实例无法被回收的引用链，最终以通知的形式报告出来。
