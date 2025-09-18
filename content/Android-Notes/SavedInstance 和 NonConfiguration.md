## 相同
- 都在可预期的时候存储数据
- 都可以恢复
- 
- **1. 保存实例状态 (Saved Instance State)**
- **目的**: 主要用于保存**少量、轻量级的数据**，这些数据足以将 UI（特别是 View 的状态）恢复到用户离开前的样子。它设计用来应对**配置更改**以及**系统因资源紧张而终止后台应用的进程（Process Death）**后用户导航回应用这两种情况。
- **机制**:
  - 使用 `Bundle` 对象来存储键值对数据。
  - Activity 通过 `onSaveInstanceState(Bundle outState)` 回调来保存数据到 `outState` Bundle 中。这通常在 Activity 即将被销毁（但在 `onStop()` 之前）时调用。
  - Activity 通过 `onCreate(Bundle? savedInstanceState)` 或 `onRestoreInstanceState(Bundle savedInstanceState)` 回调来恢复数据。`onCreate` 中的 `savedInstanceState` 参数在 Activity 首次创建时为 `null`，在因配置更改或进程终止而重建时会包含之前保存的数据。
  - Compose 中的 `rememberSaveable` 底层就是利用了这个机制。
- **生命周期**: 数据**能在配置更改和进程终止后存活**（只要用户之后返回该 Activity 且系统恢复了其状态）。
- **数据类型/大小限制**:
  - 只能存储可以放入 `Bundle` 的数据类型：基本类型（`int`, `float`, `boolean`, `String` 等）、`Parcelable`、`Serializable`（不推荐，效率低）、以及它们的数组或部分集合类型 (`SparseArray`, `ArrayList` of Parcelables/Strings/Integers)。
  - 有**严格的大小限制** (系统限制 Bundle 的总大小，跨进程传输时通常在 1MB 左右，但实际应用中应远小于此，建议几十 KB 内)，因为数据需要被序列化并通过 Binder 传输（尤其是在进程终止恢复时）。存储大量数据会导致 `TransactionTooLargeException`。
- **主要用途**:
  - 保存 UI 控件的状态（如 `EditText` 的文本、`CheckBox` 的选中状态、`RecyclerView`/`LazyColumn` 的滚动位置）。
  - 保存临时的、用于恢复 UI 状态的标识符或简单数据（如当前查看的项目的 ID）。
- **现代实践**: 在 `ViewModel` 中，可以通过 `SavedStateHandle` 访问和存储 Saved Instance State 数据，使其与 `ViewModel` 的生命周期更好地结合。在 Compose 中使用 `rememberSaveable`。

  **2. 保留 NonConfiguration 实例 (Retained NonConfiguration Instances / ViewModel)**
- **目的**: 主要用于在**配置更改期间**保留那些**创建成本高、不应随 Activity/Fragment 销毁重建而丢失的复杂对象或大量数据**。它**不能**在进程终止后存活。
- **机制**:
  - **旧方法 (已弃用/不推荐)**:
    - `Activity.onRetainNonConfigurationInstance()`: 返回一个 `Object`，在 Activity 重建后通过 `getLastNonConfigurationInstance()` 获取。需要手动管理类型转换和生命周期。
    - Retained Fragments (`Fragment.setRetainInstance(true)`): Fragment 实例本身在配置更改时不被销毁，可以持有数据。
  - **现代方法 (推荐)**:
    - **`ViewModel` (来自 Android Architecture Components)**: `ViewModel` 对象被设计为能在配置更改后存活。它们由 `ViewModelStoreOwner` (如 Activity 或 Fragment) 管理，并通过 `ViewModelProvider` 获取。框架负责在配置更改期间保留 `ViewModel` 实例，并在 `ViewModelStoreOwner` 最终销毁时（例如 Activity `finish()` 或 Fragment 被移除）才销毁 `ViewModel` (调用 `onCleared()`)。
- **生命周期**: 对象**仅能在配置更改期间存活**。如果应用进程被系统终止，`ViewModel` 及其持有的数据会**丢失**。
- **数据类型/大小限制**:
  - 可以持有**任何类型**的对象（包括网络连接、数据库引用、复杂的业务逻辑对象、大量数据列表等）。
  - 大小主要受限于应用的可用**内存**。
- **主要用途**:
  - 持有从网络或数据库加载的数据，避免屏幕旋转后重新加载。
  - 管理正在进行的后台任务（例如通过 `ViewModelScope` 启动的协程）。
  - 持有业务逻辑和准备要在 UI 上展示的数据。
- **现代实践**: 使用 `ViewModel` 是处理配置更改期间数据保留的标准方式。

  **总结对比**

  | **特性** | **保存实例状态 (Saved Instance State)** | **NonConfiguration 实例 (ViewModel)** |
  | **主要目的** | 保存轻量级 UI 状态 | 保留在内存中的复杂对象/数据 |
  | **跨配置更改** | ✅ 保存 | ✅ 保存 |
  | **跨进程终止恢复** | ✅ 保存 | ❌ **丢失** |
  | **数据形式/存储** | `Bundle` (键值对) | 任意对象实例 (内存中) |
  | **数据类型限制** | Bundle 支持的类型 | 任何类型 |
  | **数据大小限制** | 小 (KB 级别，硬限制 ~1MB) | 受限于可用内存 |
  | **生命周期管理** | 手动 (onSave/onCreate) 或 `rememberSaveable` | 自动 (由 ViewModel 框架管理) |
  | **现代推荐实现** | `SavedStateHandle` / `rememberSaveable` | `ViewModel` (AAC) |
  | **典型用途** | 用户输入、滚动位置、简单 UI 状态标识符 | 网络/数据库数据、后台任务管理、业务逻辑 |

  **如何协同工作:**

  这两种机制通常一起使用以提供健壮的用户体验：
- **`ViewModel`** 用于持有和管理核心数据（如从网络或数据库加载的用户列表）。它确保在屏幕旋转时数据不会丢失，避免了重新加载。
- **Saved Instance State** (通常通过 `ViewModel` 中的 `SavedStateHandle` 或 Compose 中的 `rememberSaveable`) 用于保存那些需要跨进程终止恢复的关键标识符（例如当前用户的 ID、搜索查询词）或轻量级的 UI 状态（如 `TextField` 的内容）。当进程被终止并恢复后，`ViewModel` 会被重新创建，此时它可以从 `SavedStateHandle` 中读取这些关键标识符，用它们来重新加载所需的核心数据，并将 UI 恢复到接近之前的状态。

  简单说：用 `ViewModel` 保留内存中的大数据和对象以应对配置更改；用 Saved Instance State (通常配合 `ViewModel` 或 `rememberSaveable`) 保存少量关键状态以应对配置更改 *和* 进程终止。
