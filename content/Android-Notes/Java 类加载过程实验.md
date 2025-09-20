
这个实验将分为几个部分：
1. **理论先行**：简述类加载的三个主要阶段。
2. **实验设计**：编写特定的 Java 代码，这些代码将在类加载的不同阶段打印信息。
3. **观测工具**：使用 JVM 自带的参数来监控类加载过程。
4. **分步执行与分析**：通过执行不同的代码路径，观察并分析输出，理解每个阶段的行为。

---
### 第一部分：理论先行：类加载过程简介

Java 虚拟机（JVM）把描述类的数据从 Class 文件加载到内存，并对数据进行校验、转换解析和初始化，最终形成可以被虚拟机直接使用的 Java 类型，这个过程被称作虚拟机的类加载机制。

整个类加载过程包括三个大的阶段：
1. **加载 (Loading)**
    - 这是类加载的第一个阶段。
    - JVM 在这个阶段的主要任务是：通过一个类的全限定名来获取定义此类的二进制字节流，并将这个字节流所代表的静态存储结构转化为方法区的运行时数据结构，最后在内存中生成一个代表这个类的 `java.lang.Class` 对象，作为方法区这个类的各种数据的访问入口。
    - 简单说就是：**找到 `.class` 文件，读入内存**。
2. **链接 (Linking)**
    - 这个阶段相对复杂，又可细分为三个小步骤：
        - **验证 (Verification)**：确保 Class 文件的字节流中包含的信息符合《Java虚拟机规范》的全部约束要求，保证这些信息被当作代码运行后不会危害虚拟机自身的安全。
        - **准备 (Preparation)**：为**类变量**（即 `static` 修饰的变量）分配内存并设置其**初始值**。注意，这里设置的是数据类型的零值（如 `int` 为 0，`boolean` 为 `false`，引用类型为 `null`），而不是代码中显式赋予的初始值。`final static` 修饰的常量在此阶段会直接赋值。
        - **解析 (Resolution)**：将常量池内的**符号引用**替换为**直接引用**的过程。符号引用就是一组用字符串表示的引用，直接引用就是指向目标的指针或句柄。
3. **初始化 (Initialization)**
    - 这是类加载过程的最后一步。
    - 此阶段才真正开始执行类中定义的 Java 程序代码。JVM 会执行类的**构造器方法 `<clinit>()`**。
    - `<clinit>()` 方法是由编译器自动收集类中的所有**类变量的赋值动作**和**静态语句块（`static{}`块）**中的语句合并产生的。
    - **触发初始化的条件**是主动使用一个类，例如：`new`一个对象、读取或设置一个类的静态字段（final static常量除外）、调用一个类的静态方法等。
---
### 第二部分：实验设计与代码
我们将创建两个类：`MyClass` 用来被加载和观察，`Main` 用来触发加载过程
#### `MyClass.java`

这个类包含了静态变量、静态常量、静态代码块和构造函数。我们在关键位置都加上了打印语句，以便跟踪执行顺序
```java
public class MyClass {

    // 静态常量 (在编译期确定)
    public static final String COMPILE_TIME_CONSTANT = "Hello, World!";

    // 静态变量
    public static int staticVar = 1;

    // 静态代码块
    static {
        System.out.println("1. MyClass --- 静态代码块执行 (Static Block Execution)");
        System.out.println("   此时 staticVar 的值是: " + staticVar + " (准备阶段赋的零值，然后被代码赋值为1)");
        staticVar = 2; // 在初始化阶段，将 staticVar 赋值为 2
        System.out.println("   赋值后 staticVar 的值是: " + staticVar);
    }

    // 成员变量
    private int instanceVar = 10;

    // 构造函数
    public MyClass() {
        System.out.println("3. MyClass --- 构造函数执行 (Constructor Execution)");
        System.out.println("   instanceVar: " + instanceVar + ", staticVar: " + staticVar);
    }
}
```

#### `Main.java`
这个类用来控制触发 `MyClass` 加载的不同场景
```java
public class Main {
    public static void main(String[] args) throws ClassNotFoundException {
        System.out.println("--- 实验开始 ---");

        // 场景1: 访问静态常量 (不会触发初始化)
        System.out.println("\n--- 场景1: 访问静态常量 ---");
        System.out.println("MyClass.COMPILE_TIME_CONSTANT: " + MyClass.COMPILE_TIME_CONSTANT);
        
        System.out.println("\n--- [分割线，观察是否已初始化] ---\n");

        // 场景2: 访问静态变量 (会触发初始化)
        System.out.println("--- 场景2: 访问静态变量 ---");
        System.out.println("MyClass.staticVar 的值是: " + MyClass.staticVar);

        System.out.println("\n--- [分割线，观察第二次访问是否再次初始化] ---\n");

        // 场景3: 第二次访问静态变量 (不会再次触发初始化)
        System.out.println("--- 场景3: 第二次访问静态变量 ---");
        System.out.println("MyClass.staticVar 的值是: " + MyClass.staticVar);

        System.out.println("\n--- [分割线，观察 new 对象过程] ---\n");
        
        // 场景4: new一个对象实例
        System.out.println("--- 场景4: new 一个对象实例 ---");
        new MyClass();

        // 场景5: 使用 Class.forName() 加载类
        // System.out.println("\n--- 场景5: Class.forName() ---");
        // Class.forName("MyClass"); // 第一个参数为 true (默认), 会进行初始化
        // Class.forName("MyClass", false, Main.class.getClassLoader()); // 设置为 false，只加载不初始化
    }
}
```

---

### 第三部分：观测工具：JVM 参数

为了让“加载”这个动作变得可见，我们将使用一个非常强大的 JVM 参数：`-verbose:class`。这个参数能让 JVM 在加载和卸载类时打印出详细信息

---

### 第四部分：分步执行与分析
#### 准备工作
1. 将上述两个 Java 文件 (`MyClass.java` 和 `Main.java`)保存在同一个文件夹中。
2. 打开你的命令行/终端，进入该文件夹。
3. 编译代码：
```shell
    javac MyClass.java Main.java
``` 

#### 实验步骤与分析

##### **步骤 1：完整运行，观察全过程**

执行以下命令，注意我们添加了 `-verbose:class` 参数：
```bash
java -verbose:class Main
```
**你将会看到非常多的输出，我们只关注和我们自己相关的部分。*

**预期输出分析 (节选并解释):**
```Plaintext
[0.027s][info][class,load] java.lang.Object source: jrt:/java.base
// ... 大量 JDK 核心类的加载信息 ...
[0.098s][info][class,load] Main source: file:/your/path/
--- 实验开始 ---

--- 场景1: 访问静态常量 ---
MyClass.COMPILE_TIME_CONSTANT: Hello, World!
// 注意：到这里为止，没有任何 MyClass 加载或初始化的信息，因为 COMPILE_TIME_CONSTANT 是编译期常量，它的值直接被存储到了 Main 类的常量池中，访问它根本不需要去加载 MyClass。

--- [分割线，观察是否已初始化] ---

--- 场景2: 访问静态变量 ---
[0.101s][info][class,load] MyClass source: file:/your/path/  <-- **[加载]** MyClass.class 文件被找到并加载进内存
1. MyClass --- 静态代码块执行 (Static Block Execution)     <-- **[初始化]** 静态代码块被执行
   此时 staticVar 的值是: 1                           <-- 在执行<clinit>前，staticVar=1的赋值已完成
   赋值后 staticVar 的值是: 2                           <-- 静态代码块中的赋值语句执行
MyClass.staticVar 的值是: 2

--- [分割线，观察第二次访问是否再次初始化] ---

--- 场景3: 第二次访问静态变量 ---
MyClass.staticVar 的值是: 2                            <-- 类只会被初始化一次，所以静态代码块不会再次执行

--- [分割线，观察 new 对象过程] ---

--- 场景4: new 一个对象实例 ---
3. MyClass --- 构造函数执行 (Constructor Execution)         <-- **[实例化]** 构造函数被调用
   instanceVar: 10, staticVar: 2
```

**结论:**
- **加载 (Loading)**: `-verbose:class` 输出的 `[class,load] MyClass ...` 清晰地显示了“加载”阶段的发生时机——即在**首次主动使用**（场景2）时。
- **准备 (Preparation)**: 我们无法直接观察到 `staticVar` 被赋零值的瞬间，但可以推断：在**初始化**阶段（静态代码块执行）之前，**准备**阶段已经完成。在静态块中我们第一次访问 `staticVar` 时，它的值是我们在代码里赋的 `1`，而不是准备阶段的 `0`，这是因为 `<clinit>()` 方法会将所有静态变量赋值和静态代码块收集到一起按顺序执行。`staticVar = 1` 这个赋值动作和静态代码块一起在初始化阶段执行。
- **初始化 (Initialization)**: `静态代码块执行` 的打印信息，明确地告诉我们 `<clinit>()` 方法被执行了。并且它只执行了一次。

##### **步骤 2：高级实验 - `Class.forName()` 的区别**

现在，修改 `Main.java`，注释掉场景1到4，只保留场景5，并分别测试两种 `Class.forName()`。

**测试A: `Class.forName("MyClass")`**
```java
public class Main {
    public static void main(String[] args) throws ClassNotFoundException {
        System.out.println("--- 实验开始 ---");
        System.out.println("\n--- 场景5A: Class.forName(\"MyClass\"), 默认会初始化 ---");
        Class.forName("MyClass");
        System.out.println("类已加载并初始化。");
    }
}
```
编译并运行 `java -verbose:class Main`，你会看到 `MyClass` 被加载，并且**静态代码块被执行**。

**测试B: `Class.forName("MyClass", false, ...)`**
```java
public class Main {
    public static void main(String[] args) throws ClassNotFoundException {
        System.out.println("--- 实验开始 ---");
        System.out.println("\n--- 场景5B: Class.forName(..., false, ...), 只加载不初始化 ---");
        Class.forName("MyClass", false, Main.class.getClassLoader());
        System.out.println("类已加载，但未初始化。");
    }
}
```

编译并运行 `java -verbose:class Main`，你会看到 `MyClass` 被加载 (`[class,load] MyClass ...`)，但**静态代码块没有被执行**！

**结论:**
- `Class.forName(className)` 默认会立即对类进行初始化，是主动使用类的一种方式。
- `ClassLoader.loadClass(className)` 或者 `Class.forName(className, false, ...)` 只会执行到**加载**阶段（可能也包括链接），但不会触发**初始化**。这给了我们更灵活的控制权。
---
### 总结

通过这个分步骤的实验，我们能够非常直观地观察到：
1. **加载时机**：通过 `-verbose:class` 日志，我们看到了 JVM 何时去文件系统查找并加载 `.class` 文件。
2. **初始化时机**：通过 `static` 代码块中的打印语句，我们精确地捕捉到了初始化的触发条件
3. **编译期常量 vs 静态变量**：我们验证了访问 `public static final` 常量通常不会触发类的初始化，而访问 `public static` 变量则会。
4. **初始化唯一性**：一个类在同一个类加载器中只会被初始化一次。
5. **加载与初始化的分离**：通过 `Class.forName` 的不同参数，我们证明了加载和初始化是可以分离的两个步骤。