- macOS 静态链接 vs 动态链接演示
  - **目标**：
    - 在 macOS 上使用命令行（终端）和标准的 clang 编译器（随 Xcode Command Line Tools 提供）创建一个简单的示例，以演示静态链接和动态链接之间的区别。
  - **先决条件**：
    - 确保你已经安装了 Xcode Command Line Tools。
    - 可以通过打开终端（应用程序 -> 实用工具 -> 终端）并运行以下命令来安装它们：
		  ```bash
		  xcode-select --install
		  ```
  - **步骤 1: 创建库代码**
    - 在一个新目录（例如 `linking_demo`）中创建两个文件：
    - `mylib.h` (库头文件)
		  ```c
		  #ifndef MYLIB_H
		  #define MYLIB_H

		  // 声明我们的库提供的函数
		  void say_hello_from_lib(const char *link_type);

		  #endif // MYLIB_H
		  ```
    - `mylib.c` (库源文件)
		  ```c
		  #include <stdio.h>
		  #include "mylib.h"

		  // 定义函数
		  void say_hello_from_lib(const char *link_type) {
		      printf("来自 mylib 的问候！这是通过 %s 链接的。\n", link_type);
		      // Original: printf("Hello from mylib! This was linked %s.\n", link_type);
		  }
		  ```
  - **步骤 2: 创建主程序代码**
    - 创建一个名为 `main.c` 的文件：
		  ```c
		  #include "mylib.h" // 包含我们库的头文件

		  int main(int argc, char *argv[]) {
		      // 为了在输出中更清晰，我们将链接方式作为参数传递
		      const char *link_type = (argc > 1) ? argv[1] : "未知方式";

		      say_hello_from_lib(link_type); // 调用库函数
		      return 0;
		  }
		  ```
  - **步骤 3: 静态链接演示**
    - 将库源代码编译为目标文件：
		  ```bash
		  clang -c mylib.c -o mylib.o
		  ```
      - `-c`: 只编译，不链接。创建 `mylib.o`。
    - 创建静态库归档文件（`.a` 文件）：
		  ```bash
		  ar rcs libmylib.a mylib.o
		  ```
      - `ar`: 归档工具。
      - `r`: 将文件（`mylib.o`）插入/替换到归档中。
      - `c`: 如果归档（`libmylib.a`）不存在，则创建它。
      - `s`: 在归档中写入一个目标文件索引（对链接器很重要）。
      - `libmylib.a`: 标准命名约定（前缀 `lib`，后缀 `.a`）。
    - 将主程序源代码编译为目标文件：
		  ```bash
		  clang -c main.c -o main.o
		  ```
    - 将主目标文件与静态库链接：
		  ```bash
		  clang main.o -L. -lmylib -o main_static
		  ```
      - `main.o`: 主程序的目标代码。
      - `-L.`: 告诉链接器在当前目录（`.`）中查找库。
      - `-lmylib`: 告诉链接器链接名为 `mylib` 的库。它会在指定路径中搜索 `libmylib.a`（或者在进行动态链接时搜索 `libmylib.dylib`）。
      - `-o main_static`: 将最终的可执行文件命名为 `main_static`。
  - **步骤 4: 动态链接演示**
    - 将库源代码编译为位置无关的目标文件：
      - (如果我们之前已经用 `-fPIC` 编译了 `mylib.o`，可以复用，但这里明确指出)
			  ```bash
			  clang -fPIC -c mylib.c -o mylib_dynamic.o
			  ```
      - `-fPIC`: 生成位置无关代码（Position-Independent Code），这对于共享库是必需的。
    - 创建共享库（在 macOS 上是 `.dylib` 文件）：
		  ```bash
		  clang -dynamiclib mylib_dynamic.o -o libmylib.dylib
		  ```
      - `-dynamiclib`: 指定我们正在创建一个共享库。
      - `libmylib.dylib`: macOS 上动态库的标准命名约定。
    - 将主目标文件与共享库链接：
      - (我们可以复用 `main.o`)
			  ```bash
			  clang main.o -L. -lmylib -o main_dynamic
			  ```
      - 这个命令与静态链接中的相同。但是，链接器（由 `clang` 调用的 `ld`）通常在两者都存在且使用了 `-l` 选项时，优先选择 `.dylib` 而不是 `.a`。它在当前目录 (`-L.`) 找到 `libmylib.dylib` 并动态地链接它。
      - `-o main_dynamic`: 将输出的可执行文件命名为 `main_dynamic`。
  - **步骤 5: 观察差异**
    - **文件大小**：
		  ```bash
		  ls -l main_static main_dynamic libmylib.a libmylib.dylib mylib.o
		  ```
      - **观察**： 你应该看到 `main_static` 比 `main_dynamic` 大。大小的差异大致是因为 `main_static` 包含了 `mylib.o` 中的实际代码，而 `main_dynamic` 只包含了引用。`libmylib.a` 的大小将与 `mylib.o` 相似，而 `libmylib.dylib` 可能因为动态链接的开销/元数据而稍大一些。
    - **库依赖关系**：
		  ```bash
		  otool -L main_static
		  ```
		  ```bash
		  otool -L main_dynamic
		  ```
      - `otool -L`: 这个命令列出可执行文件或库所依赖的动态库。
      - **对于 `main_static` 的观察**： 你很可能只会看到系统库（如 `/usr/lib/libSystem.B.dylib`）。你应该看不到 `libmylib.dylib` 被列出。
      - **对于 `main_dynamic` 的观察**： 你会看到 `libmylib.dylib` 被列出（它可能只显示名称，或者根据链接器标志显示为 `@rpath/libmylib.dylib`），同时还有系统库。这表明它在运行时依赖于外部的共享库文件。
  - **步骤 6: 运行可执行文件**
    - **运行静态链接的版本**：
		  ```bash
		  ./main_static static
		  ```
      - **输出**： `来自 mylib 的问候！这是通过 static 链接的。`
      - **观察**： 它能正常运行，因为所有来自 `mylib` 的必要代码都在 `main_static` 内部。
    - **运行动态链接的版本**：
		  ```bash
		  ./main_dynamic dynamic
		  ```
      - **潜在问题**： 这可能会失败，并出现类似以下的错误：`dyld: Library not loaded: libmylib.dylib ... Reason: image not found`
      - **原因？** 动态链接器默认情况下不知道在运行时去当前目录（`.`）查找 `.dylib` 文件。`main_dynamic` 知道它需要 `libmylib.dylib`，但系统找不到它。
      - **解决方案 1 (临时环境变量)**： 仅为本次命令告诉动态链接器去哪里查找：
			  ```bash
			  DYLD_LIBRARY_PATH=. ./main_dynamic dynamic
			  ```
        - `DYLD_LIBRARY_PATH=.` 设置一个环境变量，告诉链接器搜索当前目录。
        - **输出**： `来自 mylib 的问候！这是通过 dynamic 链接的。`
      - **解决方案 2 (嵌入运行时路径 - RPATH)**： 重新链接 `main_dynamic`，告诉它在运行时相对于自身在哪里查找库：
			  ```bash
			  clang main.o -L. -lmylib -o main_dynamic_rpath -Wl,-rpath,@executable_path
			  ```
        - `-Wl,-rpath,@executable_path`: 将 `-rpath` 选项传递给链接器 (`ld`)，告诉它将包含可执行文件的目录 (`@executable_path`) 添加到运行时搜索路径中。
        - 现在运行新的可执行文件
				  ```bash
				  ./main_dynamic_rpath dynamic
				  ```
        - **输出**： `来自 mylib 的问候！这是通过 dynamic 链接的。` 这个版本可以直接运行，因为位置提示被嵌入了。
  - **清理**：
	  ```bash
	  rm main.c mylib.c mylib.h mylib.o mylib_dynamic.o libmylib.a libmylib.dylib main.o main_static main_dynamic main_dynamic_rpath
	  ```
  - 这个实践练习清晰地展示了静态链接的可执行文件是自包含的（文件更大，对 `libmylib` 没有运行时依赖），而动态链接的可执行文件更小，但在运行时需要外部的 `libmylib.dylib` 文件可用且能被找到。
