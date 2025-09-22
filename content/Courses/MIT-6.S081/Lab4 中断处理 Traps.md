这个实验探索使用 traps 来实现 system call。首先有一个热身训练，然后将要实现一个用户层级的 trap 处理示例

实验前置操作
```shell
git fetch
git checkout traps
make clean
```

## RISC-V 汇编指令速记
**数据传输**
`ld` -> `load double word`
`lw` -> `load word`
`sd` -> `store double`
`sw` -> `store word`

**算术运算**
`add`
`sub`
`addi` -> `add immediate`
`li` -> `load immediate`
`mul` -> `multiply`
`div` -> `divide`

**逻辑运算**
`and/or/xor`
`andi/ori` -> `and/or imm`
`slt` -> `set if less than`
`slti` -> `set if less than imm`

**程序控制**
`beq` -> `branch if equal`
`bne` -> `branch if not equal`
`blt/bge` -> `branch if less/greater-equal`
`jal` -> `jump and link` 跳转并链接（普通函数调用）
`jalr` -> `jump and link register` 寄存器跳转并链接（间接/动态调用）
`ret` -> `return` 返回（伪指令，`jalr zero, 0(ra)` 的简写）

**32位立即数加载**
`lui` -> `load upper imm` 加载高位立即数
`auipc` -> `add upper imm to PC` 程序计数器加载高位立即数

# RISC-V assembly 汇编代码
`easy`
> 理解一些 RISC-V 汇编指令很重要，有一个 `user/call.c` 文件在 xv6 仓库中. `make fs.img` 可以编译并生成一个可阅读的程序 `user/call.asm`。
> 阅读 `g`, `f`, `main` 函数，回答下面的几个问题

1. 哪几个寄存器存储函数的参数？例如，哪个寄存器存了 `printf` 的参数 13
2. 函数 `f` 的汇编调用在 `main` 的哪里？函数`g`？（提示：编译器可能会把函数内联）
3. 函数 `printf` 的地址在哪
4. `main` 函数在 `jalr` 到 `printf` 之后 `ra` 的值是什么
5. 运行下面的代码：
```c
unsigned int i = 0x00646c72;
printf("H%x Wo%s", 57616, &i);
```
输出是什么
输出依赖于 RISC-V 的小端存储，如果是大端存储，会发生什么
在下面的代码中，`y=` 后面会打印什么？（答案不是一个确定值）为什么会这样？
`printf("x=%d y=%d", 3);`



### 解答 1
`call.c` 的原始代码
```c
#include "kernel/param.h"
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int g(int x) {
  return x+3;
}

int f(int x) {
  return g(x);
}

void main(void) {
  printf("%d %d\n", f(8)+1, 13);
  exit(0);
}
```

`main` 函数的汇编代码
```asm
void main(void) {
  1c:	1141                	addi	sp,sp,-16 # 分配 16 字节空间
  1e:	e406                	sd	ra,8(sp) # 保存 main 的返回地址
  20:	e022                	sd	s0,0(sp)
  22:	0800                	addi	s0,sp,16
  printf("%d %d\n", f(8)+1, 13); # 编译器算出了 f(8) + 1 是 12
  24:	4635                	li	a2,13
  26:	45b1                	li	a1,12
  28:	00000517          	auipc	a0,0x0
  2c:	7b050513          	addi	a0,a0,1968 # 7d8 <malloc+0xea> # linker 计算的字符串存储位置
  30:	00000097          	auipc	ra,0x0
  34:	600080e7          	jalr	1536(ra) # 630 <printf>
  exit(0);
  38:	4501                	li	a0,0
  3a:	00000097          	auipc	ra,0x0
  3e:	27e080e7          	jalr	638(ra) # 2b8 <exit>
```

`a0,a1,a2...` 存储函数参数，13 存在了 `a2`

### 解答 2
`f` 和 `g` 的汇编调用都被内联了 

### 解答 3
`0x630`

### 解答 4
`0x38` 也就是 `li a0, 0` 这条指令的地址

### 解答 5
57616 = 0xE110
0x00646c72 小端存储从低位到高位依次为 `72-6c-64-00` = `rld`
大端存储则需要改为 `0x726c6400`

## 解答 6
原本需要传两个参数却只传了一个，y= 取决于 `a2` 保存的值

# Backtrace 回溯
`moderate`
需要一个 debug 工作 backtrace：在错误发生点之上的栈上的一个函数调用列表
>在 `kernel/printf.c` 实现一个 `backtrace()` 函数。在 `sys_sleep` 函数中插入一个 `backtrace()` ，运行 `bttest`，这会调用 `sys_sleep`。输出应该是：
	backtrace:
	0x0000000080002cda
	0x0000000080002bb6
	0x0000000080002898
>在 `bttest` 结束之后退出 qemu。运行 `addr2line -e kernel/kernel` 或者 `riscv64-unknown-elf-addr2line -e kernel/kernel` 然后复制粘贴刚才得到的地址
	addr2line -e kernel/kernel
	 0x0000000080002de2
    0x0000000080002f4a
    0x0000000080002bfc
    Ctrl-D
>应该会发现下面类似的情况
> kernel/sysproc.c:74
	kernel/syscall.c:224
    kernel/trap.c:85

编译器在每个栈帧放了一个帧指针存储了调用者的帧信息。`backtrace` 将使用这些帧指针来向上打印栈帧的返回地址

提示：
- 在 `kernel/defs.h` 增加 `backtrace` 的原型函数这样就可以在 `sys_sleep` 里调用 `backtrace`
- `GCC` 编译器把当前正在执行的函数的帧指针存在寄存器 `s0`。将下面的函数添加到 `kernel/riscv.h`
```c
static inline uint64
r_fp()
{
  uint64 x;
  asm volatile("mv %0, s0" : "=r" (x) );
  return x;
}
```
调用这个函数来读取当前函数栈帧中的 `s0` 中的值（帧指针）
![[Pasted image 20250921042643.png]]

- xv6 在内核为每个栈分配一页”页对齐“地址。可以通过 `PGROUNDUP(rp)` 和 `PGROUNDDOWN(rp)` 来计算栈的底部和顶部地址（这可以帮助 `backtrace` 结束无限循环）
当 `backtrace` 能够运行了， 在 `kernel/printf.c` 的 `panic` 中调用，这样就能在内核 panic 的时候看到调用栈信息

## 实验过程
### 核心代码
```c
void
backtrace(void)
{
  uint64 frame_pointer = r_fp();
  printf("backtrace:\n");
  while (PGROUNDDOWN(frame_pointer) != PGROUNDUP(frame_pointer)) {
    uint64 ra = *(uint64*)(frame_pointer - 8);
    printf("%p\n", ra);
    frame_pointer = *(uint64*)(frame_pointer - 16);
  }
}
```

## Alarm
`hard`
>在这个练习中将要为 xv6 加入一个功能，周期性警告表示一个线程在使用 CPU 时间。对于一些边界计算线程可能适用于它们想限制吃掉时间片的情况，或者是想周期性做一些动作的情况。更一般的说，你将要实现一个用户级别的中断/错误处理器原型。可以使用一些类似 [[缺页中断]] 的应用。如果解决方法正确的话会通过 `alarmtest` 和 `usertests`。

你应该增加一个新的 `sigalarm(intervel, handler)` 系统调用。如果一个应用调用 `sigalarm(n, fn)` ，然后每 `n` 个 ticks内核会让应用函数 `fn` 调用。

## 实验过程
该实验涉及了 [[时钟中断]] 机制
### 核心代码
```c
void
usertrap(void)
{
	// ...
  // Handle timer interrupt
  if(which_dev == 2) {
    // Check if periodic alarm should fire
    if (p->alarm_interval > 0 && !p->alarm_in_progress) {
      p->alarm_ticks_remaining--;
  
      if (p->alarm_ticks_remaining <= 0) {
        // Reset counter for next alarm
        p->alarm_ticks_remaining = p->alarm_interval;

        // Save current user context before calling handler
        *p->alarm_saved_state = *p->trapframe;

        // Redirect execution to alarm handler
        p->trapframe->epc = (uint64)p->alarm_handler;

        // Mark that alarm handler is running
        p->alarm_in_progress = 1;
      }
    }
    yield();
  }

  usertrapret();

}
```