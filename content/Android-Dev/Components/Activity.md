## 生命周期
  - 两个 Activity 之间的跳转，注意只有进入后台的时候调用 onStop
## 启动 Activity
  - Laucher（第一次启动）/ 父 Activity 通过 Instrumentation 钩子，通知AMS启动Activity，最后走到ApplicationThread对对应的Activity类进行类加载，调用 onCreate 方法
- 
## 实验
[[全局监听 Activity 的销毁]]