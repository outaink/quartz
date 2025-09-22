- 关键：`Application.ActivityLifecycleCallbacks`
- 一个用于监听Activity生命周期的接口
- 
- 首先
- ```kotlin
  class MyGlobalActivityMonitor : Application.ActivityLifecycleCallbacks {
    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
      Log.i(TAG, activity.*javaClass*.*simpleName *+ " - Created");
    }

    override fun onActivityDestroyed(activity: Activity) {
      Log.w(TAG, activity.*javaClass*.getSimpleName() + " - Destroyed");
    }
  }
  ```
- 2. 在 Application 类中使用 `registerActivityLifecycleCallbacks` 注册
- ```Kotlin
  class MyApp : Application() {
      override fun onCreate() {
          super.onCreate()
          registerActivityLifecycleCallbacks(MyGlobalActivityMonitor())
          Log.i("MyApplication", "ActivityLifecycleCallbacks registered.");
      }
  }
  ```
- 
- 实际应用
[[LeakCanary原理]]
