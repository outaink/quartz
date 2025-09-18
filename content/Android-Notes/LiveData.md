## LiveData的post和set有什么区别？
- 这背后其实是 `LiveData` 内部针对 `postValue` 的一个优化机制，以及主线程消息队列处理任务的特性共同作用的结果。

  **核心机制回顾:**
- **`postValue(value)` (子线程调用):**
  - 它不会直接修改 LiveData 的值。
  - 它会将 `value` 存储到一个临时的内部变量中（我们称之为 `mPendingValue`）。
  - 它会检查是否已经有一个“待处理的 `setValue` 任务”被 post 到了主线程的消息队列但尚未执行。
  - **关键优化:** 如果**没有**待处理的任务，它才会创建一个 `Runnable`（我们称之为 `mPostValueRunnable`），这个 `Runnable` 的工作是读取 `mPendingValue` 并调用 `setValue()`，然后将这个 `Runnable` post 到主线程的 `MessageQueue`。如果**已经有**一个任务在队列中等待执行，`postValue` **不会**再 post 新的任务，它仅仅更新 `mPendingValue` 就结束了。
- **主线程 `Looper` 和 `MessageQueue`:**
  - 主线程有一个 `Looper` 在不断循环，从它的 `MessageQueue` 中取出 `Message` (其 `callback` 可能就是我们 post 的 `Runnable`) 并执行。
  - 消息队列是先进先出 (FIFO) 的。
  - 主线程除了处理这些 post 过来的任务，还要处理 UI 绘制、用户输入等其他事件，所以队列中的任务执行可能会有延迟。

	  **覆盖场景详解:**

	  假设我们在一个**后台线程 (Thread B)** 中快速地连续调用 `postValue`，而此时**主线程 (Thread A)** 可能因为处理其他事务（比如 UI 绘制）而暂时繁忙：
- **T1 时刻 (Thread B):** 调用 `liveData.postValue("Value A")`。
  - `LiveData` 内部：`mPendingValue` 被设为 `"Value A"`。
  - `LiveData` 内部：检测到没有待处理的任务，于是创建一个 `mPostValueRunnable` (它知道要去读取 `mPendingValue` 并调用 `setValue`)。
  - `LiveData` 内部：将 `mPostValueRunnable` 添加到 Thread A 的 `MessageQueue`。
  - `MessageQueue` (Thread A): `[..., mPostValueRunnable]`
- **T2 时刻 (Thread B, T1 后很短时间):** Thread A 的 `Looper` 还没来得及执行 `mPostValueRunnable`，Thread B 又调用了 `liveData.postValue("Value B")`。
  - `LiveData` 内部：`mPendingValue` 被**更新**为 `"Value B"` (覆盖了 `"Value A"`)。
  - `LiveData` 内部：检测到**已经有**一个 `mPostValueRunnable` 在 Thread A 的队列中等待执行。
  - `LiveData` 内部：**因此，不再 post 新的任务**。仅仅更新 `mPendingValue` 就结束了。
  - `MessageQueue` (Thread A): `[..., mPostValueRunnable]` (队列内容没变，还是只有一个任务)
- **T3 时刻 (Thread B, T2 后很短时间):** Thread A 仍然繁忙，`mPostValueRunnable` 还没执行。Thread B 再次调用 `liveData.postValue("Value C")`。
  - `LiveData` 内部：`mPendingValue` 被**再次更新**为 `"Value C"` (覆盖了 `"Value B"`)。
  - `LiveData` 内部：检测到**仍然有**一个 `mPostValueRunnable` 在队列中等待。
  - `LiveData` 内部：**仍然不 post 新的任务**。
  - `MessageQueue` (Thread A): `[..., mPostValueRunnable]` (队列内容依然没变)
- **T4 时刻 (Thread A):** 主线程终于空闲下来，`Looper` 从 `MessageQueue` 中取出了在 T1 时刻 post 的那个 `mPostValueRunnable` 并开始执行它。
  - `mPostValueRunnable` 执行：
    - 它读取 `LiveData` 内部的 `mPendingValue`。**此时 `mPendingValue` 的值是 `"Value C"`** (因为在 T3 时刻被最后更新了)。
    - 它调用 `liveData.setValue("Value C")`。
    - `setValue` 更新 LiveData 的实际值，并通知观察者，传递的值是 `"Value C"`。

		  **结果:**

		  在这个过程中，虽然我们调用了三次 `postValue`，分别是 "Value A", "Value B", "Value C"，但由于主线程处理 `mPostValueRunnable` 的延迟以及 `LiveData` 内部只 post 一个任务的优化，最终只有最后一个值 `"Value C"` 被真正地通过 `setValue` 设置并通知给观察者。中间的 "Value A" 和 "Value B" 在 `mPendingValue` 这个临时存储区被覆盖掉了，从未触发过 `setValue`。

		  **这就是 `postValue` 可能导致值覆盖的根本原因：** 它是异步的，并且 `LiveData` 会合并（coalesce）在主线程处理之前发生的连续多次 `postValue` 调用，只保留最后一次的值，并通过一个任务最终更新到主线程。
-
