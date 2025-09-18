## ViewModel 的创建
  - 关键：`ViewModelStoreOwner`、`ViewModelStore`、`ViewModelProvider(.Factory)`
- 
### ViewModelStoreOwner
- 是一个接口，ComponentActivity(AppCompatActivity的基类) 和 Fragment 实现
- ```Kotlin
  interface ViewModelStoreOwner {
      val viewModelStore: ViewModelStore
  }
  ```
- 实现类提供一个 ViewModelStore 实例
- 
### ViewModelStore
- 是一个持有 ViewModel 实例的容器类。内部可以理解为一个 `HashMap<String, ViewModel>`。它的关键特性是：**`ViewModelStore` 实例的生命周期比实现 `ViewModelStoreOwner` 的 Activity/Fragment 实例更长，它能够跨越配置更改而存活下来。**
- ```kotlin
  open class ViewModelStore {

      private val map = mutableMapOf*<String, ViewModel>()

      // 。。。
      fun clear() {
          for (vm in map.values) {
              vm.clear()
          }
          map.clear()
      }
  }
  ```
- 
### ViewModelProvider
- 这是获取 `ViewModel` 实例的入口类。它需要一个 `ViewModelStoreOwner` (或者直接一个 `ViewModelStore`) 和一个可选的 `ViewModelProvider.Factory` 来工作。
- 
### ViewModelProvider.Factory
- 这是一个接口，负责实际创建 `ViewModel` 的新实例。如果你的 ViewModel 有非空的构造函数（例如需要传入 Repository 或其他依赖），你就需要提供自定义的 Factory。
- 
### ViewModel 创建流程
-
  ```java
  MyViewModel viewModel = new ViewModelProvider(this).get(MyViewModel.class);
  ```
- 因为给 ViewModelProvider 传入了一个 ViewModelStoreOwner，ViewModelProvider 就会调用 ViewModelStoreOwner 的 getViewModelStore 方法获取到 ViewModelStore 实例
- 如果是新的实例，ViewModelProvider 会调用持有的 Factory 创建一个新的 MyViewModel 并放入 ViewModelStore 中
- 
### 为什么 ViewModel 的生命周期能独立于 Activity 之外 ? （字节剪映一面）
- ViewModel 实例在首次调用时被创建，并且存储在 Activity 的 ViewModelStore 成员中
- Activity 被销毁前，ViewModelStore成员在 OnRetainNonConfiguration() 回调中保存（这是 Android 框架实现的）
- Activity 重新创建后，会先调用 getLastNonConfiguration() 是否为空且找到保存的 ViewModelStore，复用之前创建好的 ViewModel 实例
