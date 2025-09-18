## Recompose 的执行过程
  - Recompose Scope 失效，重新生成 Composition 的过程
- 
## !! 在 Kotlin 2.0.20 之后，Android 默认开启 `强烈跳过`
- https://developer.android.com/develop/ui/compose/performance/stability/strongskipping?hl=zh-cn
- 会导致即使一些不稳定的参数，也可以跳过重组
- 6
- 
## Composable 一定不会跳过重组的情况
- ```kotlin
  @Composable
  fun composableTest(user: User) {
  	...
  }

  data class User(var name: String)
  ```
- 如果参数是一个**内部参数为可变类型的 data  class**，对应的Composable 函数就一定会重组
- 原因：Compose 认为可变参数是 **不可靠的**
- 
### 什么是稳定的？可靠的？
  - 重组：当 Composable 函数读取的 State 或者其他输入发生**变化**时，Compose 会重新调用该函数更新 UI
  - 稳定性：为了优化重组，Compose 需要知道一个类型的实例在其生命周期内是否会改变，以及 equals 方法是否可靠且一致
    - **稳定类型**：
      - 所有的公共属性都是 val 且类型也是稳定的
      - equals 方法对于两个相同的实例永远是相同的
      - 如：基本数据类型和主构造函数属性都是val的data class
      - 或者公开属性为 var 但被 mutableStateOf 代理
    - **不稳定类型**:
      - data class 的主构造参数有 var 或者 mutableState<T> 类型的参数，这个 data class 就被认为是不稳定的
    - 所以如果一个 Composable 的参数被判定为**不稳定**，则在 父 Composable 重组时，该函数一定会重组，**即使前后两个实例的 equals 返回 true**
## @Stable 注解
- ```kotlin
  @Composable
  fun composableTest(user: User) {
  	...
  }

  @Stable
  data class User(var name: String)
  ```
- @Stable 用来保证被注解的类型是 **稳定的**，这样，只要 equals 返回 true，就会跳过重组
