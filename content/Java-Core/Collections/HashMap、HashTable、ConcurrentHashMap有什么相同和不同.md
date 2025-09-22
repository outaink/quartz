## 相同
  - 都是 KV 集合
  - 都实现了 Map 接口
  - 都基于哈希表实现 O(1) 时间复杂度的查找插入和删除
  - 都不保证映射中元素的迭代顺序（LinkedHashMap可以维护）
## 不同
  - 线程安全：HashMap 不安全，另外两个安全
  - 同步机制
    - HashMap无
    - HashTable 使用 synchronized 修饰大部分公共方法
    - ConcurrentHashMap 使用 CAS 锁 + Node 锁的细粒度锁
  - 性能上：
    - HashMap 单线程最快
    - HashTable 最慢
    - ConcurrentHashMap 并发下优秀
  - null key：
    - HashMap允许（最多一个）
    - HashTable 不允许
    - ConcurrentHashMap 不允许
  - null value
    - HashMap 允许
    - HashTable不允许
    - ConcurrentHashMap 不允许
  - 迭代器
    - HashMap：快速失败，并发导致不同步时抛出异常 `ConcurrentModificationException`
    - HashTable：没有快速失败
    - ConcurrentHashMap：弱一致性，不抛 `ConcurrentModificationException`，遍历时可能反映部分修改
## 对 Null key/value 的处理
  - HashMap：可以有一个 null key 多个 null value，null key进行特殊处理，在比较 key 时会用 key == null 而不是 key.hashcode()
- 
## 为什么 HashTable 和 ConcurrentHashMap 不支持 Null
  - **避免二义性**：为了防止 containsKey(key) 和 get(key) 之间的并发修改导致的数据不可靠，线程安全的 Map 严格限制 get(key) -> null 的含义为 key 不存在这个 Map 中（这个设计禁止 null value）
  - **健壮性**：HashMap 使用了特殊处理的方式对待 null，HashTable 和 ConcurrentHashMap 会认为这不够健壮
-
