---
tags:
  - book
  - OS
author: Russ Cox, Frans Kaashoek, Robert Morris
rating: 🌟🌟🌟🌟🌟
---

**相关资源**
![book-riscv-rev1.pdf](assets/book-riscv-rev1_1757300923075_0.pdf)
## Chapter 1 工具
  - 进程标识符`Process identifier` aka. `PID`
  - `fork()` 命令会创建子进程，对于父进程，`fork()` 的返回值是子进程的 `PID`。对于子进程返回值为`0`
  - **系统调用**:
    - ![image.png](assets/image_1757301839494_0.png)
## Chapter 2 系统调用
  - 操作系统的三个要求：多路、隔离、交互
  - Xv6 运行在一个**多核**的 RISC-V 处理器上，RISC-V 是一个 64 位 CPU，xv6 的 Long 和 指针是 64 位的， int 是 32 位的
  - 为什么需要操作系统？一些嵌入式设备和 real-time 系统会运行应用直接操作硬件来获得最优性能。缺点是，例如应用可能不会慷慨地分享 CPU 资源。所以大多情况下 isolation
  - RISC-V 的三种模式：`machine mode`、`supervisor mode`、`user mode`，xv6 只在 machine mode 下执行几行代码就会进入 supervisor mode
  - 用户态转换到内核态，xv6 提供了 ecall 指令
  - 内核组成：
    - **宏内核**（monolithic kernel）：一个内核掌管所有硬件
      - 内核不同部分之间的交互很复杂，容易出现问题
      - 内核错误都是 fatal 致命的
    - **微内核**（micro kernel）： 一个微内核的职责范围有限，比如进程间通信，访问一些硬件。微服务等概念都是同一个思想
  - xv6 使用**页表**（硬件实现）让每个进程拥有专属的地址空间。RISC-V MMU内存管理器将**一个虚拟地址**映射到**物理地址**，简单来说，操作系统为每个进程创建一个页表，页表中包含了进程私有的堆栈和用户数据地址和内核数据地址（一般是一个向量）。由于虚拟内存硬件的存在，这些内容在进程视角中都是一致的，但是最终映射到不同的物理地址上
  - ![image.png](assets/image_1757433069706_0.png)
  - 上图可以看到，从虚拟地址0开始（从下往上）依次是用户数据（全局变量），栈，堆（最大）
  - [[MAXVA]] = Max Virtual Address = $$2^{38} - 1$$  = 0x3fffffffff
  - 一个xv6进程通过执行 RISC-V `ecall` 指令进行一个 system call -> 程序计数器指向一个内核定义的入口
	  system call 执行结束后通过 `sret` 指令返回用户空间
  - xv6 内核维护进程的许多状态，在 `struct proc`(kernel/proc.h)结构体中定义。重要的进程状态包括：页表，内核栈，运行状态。例：访问页表使用 `p->pagetable`
  - 每个进程都有一个执行绪（thread of execution）简称 thread 线程来执行进程指令
## Chapter 3 页表
### 3.1 分页硬件
- RISC-V 指令（用户指令和内核指令）都是操作[[虚拟地址]]的，机器的 RAM 是物理地址
- 页表通过映射连接[[虚拟地址]]和[[物理地址]]
- xv6 的虚拟地址长度为 39 bits（在 64 位机器上，剩余的 25 位不使用）
- 一张页表逻辑上是一个存储 [[PTE]] 的数组，每个[[PTE]]包含一个 44 bit 长的物理页号 [[PPN]] 和一些标志位
- ![image.png](assets/image_1757630543860_0.png)
  - 每个 PPN 对应的地址空间大小为 $$2^{12}$$，这个空间称为一个 Chunk
  - 实际的地址翻译是通过三级页表进行翻译的
	  ![image.png](CS-Notes/assets/image_1757630819806_0.png)
  - 如果任何一个 [[PTE]] 在翻译过程中没有被找到，分页硬件会抛出一个[[缺页中断]]，操作系统会陷入内核态来处理这个中断
  - 为什么需要三级页表？
    - 如果只有一级页表，一个 39 位的虚拟地址的高 27 位会一一对应一个页表项，这样页表的大小是 $$2^{27}$$ = 128M
    - 三级页表，每个单级页表的大小仅仅位 $$2^9$$ = 512 = 0.5K，空间使用几乎可以忽略不计，并且可以通过延迟构建二三级页表，加上快表辅助
  - [[虚拟地址]] 和 [[物理内存]] 是硬件概念，[[虚拟内存]] 不是硬件概念，而是一个管理 [[物理内存]] 和 [[虚拟地址]] 的机制
### 3.2 内核地址空间
- xv6 为每个进行维护一个描述用户空间的页表和一个全局唯一的描述内核地址空间的页表
- 内核页表记录了可访问的硬件资源和物理内存，`kernel/memlayout.h` 定义了 xv6 内核内存的分布
- ![image.png](CS-Notes/assets/image_1757633895210_0.png)
- RAM 和 内存映射设备寄存器通过 [[直接映射]] 将资源映射到[[虚拟地址]]和[[物理地址]]相等的位置上
- 例如：内核的起始地址在[[虚拟地址]]和[[物理地址]]上都为 `KERNBASE=0x80000000`
[[直接映射]] 简化了内核代码读写[[物理内存]]
- 例如：使用 `fork` 创建子进程的时候，可以直接复制内核的起始地址内容到子进程的虚拟内存的对应位置中
- 有一些内核虚拟地址不是[[直接映射]]：
- `trampoline` page -> 蹦床页，映射两次
  - [[物理地址]] -> `MAXVA - PGSIZE` 虚拟地址最高位，这里是给用户使用的
  - 直接映射: 映射到内核地址空间，给内核用于跳转回用户空间的
- `内核栈`页 -> 每个进程都有自己的内核栈，内核栈页之间会有一个 `Guard Page` 保护页
  - 保护页的 [[PTE]] 的 `PTE_V` 标志位为 0，用来防止内核栈移除对其他内核栈的影响
  - 如果对内核栈进行直接映射，那个保护页也要直接映射，那已使用
### 3.3 创建地址空间
- `kernel/vm.c` 处理了大多数控制地址空间的逻辑
### 3.4 物理内存分配
- 页表:
  - 本质：一个**数据结构**，是虚拟内存系统中的“地址翻译表”
  - 功能：存储虚拟地址到物理地址的映射关系
  - 位置：存储在**内核空间**中，每个进程都有自己的页表（在内核空间的哪个部分？）
- 用户内存：
  - 本质：一个**内存区域**，是操作系统为每个用户进程分配的虚拟地址空间的一部分
  - 功能：code/data/ 堆栈，是应用程序可以直接读写的空间
  - 位置：逻辑上属于用户空间
- 内核栈：
  - 本质：一个内存的内核空间
  - 功能：当进程因为[[系统调用]]或[[中断]]从用户态切换到内核态时，使用内核栈运行内核代码
  - 位置：位于内核空间，每个线程都有一个大小固定的内核栈
- 管道缓冲：
  - 本质：内核维护的一个缓冲区
  - 功能：管道 IPC 会用到这个区域
  - 位置：位于内核空间，是内核同一管理的，不会分配给特定进程
### 3.5 物理内存分配器
内存分配器代码 `kernel/kalloc.c`
```c
struct run {
	struct run *next;
};

struct {
	struct spinlock lock;
	struct run *freelist;
} kmem;
```
分配器数据结构是一个空闲的可以被分配的物理内存页列表

分配器初始化 `kinit`
```c
void
kinit()
{
	initlock(&kmem.lock, "kmem");
	freerange(end, (void*)PHYSTOP);
}

void
freerange(void *pa_start, void *pa_end)
{
	char *p;
	p = (char*)PGROUNDUP((uint64)pa_start);
	for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
	  kfree(p);
}
```
### 3.6 进程地址空间
- 每个进程都有独立的页表，进程切换页表也会切换
- 进程的用户内存从 0 到 [[MAXVA]]
- 用户向操作系统申请更多的用户内存时，xv6 使用 [[kalloc]] 来分配物理内存页，然后创建 [[PTE]] 连接虚拟地址和物理地址。xv6 会将 `PTE_W` `PTE_R` `PTE_X` `PTE_U` 和 `PTE_V` 置位
## Chapter 4 Traps and system calls
- 三种让 CPU 停止执行一般指令的事件
    - [[系统调用]]：用户程序执行 ecall 指令让内核干活
    - 异常（exception）：除0异常，使用非法虚拟地址
    - 设备[[中断]]：硬盘设备结束写入和读取，屏幕被触摸
    - 以上三种被称为 [[Trap]]
  - [[Trap]] 之后需要恢复
  - [[Trap]] 把控制权转移给内核，内核保存寄存器和各种状态让用户指令可以被恢复
### 4.1 RISC-V trap machinery
- RISC-V CPU 有一组内核写入的控制寄存器来告诉CPU如何处理 Traps，内核也可以读取这些控制寄存器来发现触发了什么 Trap
- xv6 一些重要的寄存器
  - `stvec` -> 内核在这个寄存器中写入了 trap 处理器的地址；RISC-V 跳转到这个地址来处理一个 Trap
  - `sepc` -> 一个 Trap 发生时，RISC-V 在这个寄存器保存程序计数器（因为 `pc` 寄存器刚被 `stvec` 覆写）。`sret` （trap 返回）命令把这个寄存器的内容复制到 `pc`。内核就可以写入 `sepc` 来控制 `sret` 的走向
  - `scause` -> RISC-V 在这里放一个数字表示 Trap 的原因
  - `sscratch` -> 内核可以在这里放一个变量
  - `sstatus` -> `SIE` 位是否响应设备中断
### 4.2 用户空间的 Trap
发生 Trap 的情况
- 系统调用
- 非法操作
- 用户空间时来了一个设备中断

观察下面内核空间和用户空间的地址分布
![image.png](CS-Notes/assets/image_1757633895210_0.png)

它们的分布情况很不同，除了 [[Trampoline]] 页
![image.png](CS-Notes/assets/image_1757433069706_0.png)
这样就可以看出，[[Trampoline]] 页是用户态进入内核态的关键
`trapframe` 是保存用户态寄存器信息的数据结构

### 4.3 流程：调用系统调用
以 `exec` 系统调用为例
```c
// 读取一个文件并执行内部指令
int exec(char *path, char **argv)
```
1. path 和 argv 两个参数分别存入 `a0` 和 `a1`，并且把系统调用号存入 `a7`
2. `ecall` 指令执行 `uservec` 地址的指令进入内核的 `usertrap`，然后 `syscall`
3. `syscall` 结合 `a7` 的系统调用号找到对应的`exec`系统调用实现
4. `exec` 运行结束后，`syscall` 将返回值存入 `p->trapframe->a0` ，用户空间的返回值就是在这里的，一般错误就是 -1，正确就是 >= 0
### 4.4 流程：系统调用参数
用户执行系统调用进入内核态，寄存器参数会被存入 `trapframe` 中，内核就是在这里找到参数的
```c
static int
argfd(int n, int *pfd, struct file **pf);

int             argint(int, int*);
int             argstr(int, char*, int);
int             argaddr(int, uint64 *);
```
这些内核辅助函数就是根据系统调用号从 `trapframe` 中获取对应的整型，字符串，地址，文件描述符等

> 问题：如果参数是一个地址（用户指定的地址），内核如何解引用或者对应的数据呢？

利用 `p->pagetable` 访问用户页表，就可以在代码层面翻译用户传入的地址到对应的[[物理地址]]，读取一个合适的偏移量就能获得需要的数据，以 `exec` 为例，它的第一个参数是一个字符串文件名

```c
uint64
sys_exec(void)
{
  char path[MAXPATH], *argv[MAXARG];
  int i;

  uint64 uargv, uarg;

  // 1. 使用 argstr 尝试获取地址对应的字符串
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    return -1;
  }
}

int
argstr(int n, char *buf, int max)
{
  uint64 addr;

  if(argaddr(n, &addr) < 0)
    return -1;
  // 2. 通过上面的 argaddr 获取到寄存器中保存的地址后，通过fetchstr寻找地址对应的字符串    
  return fetchstr(addr, buf, max);
}

int
fetchstr(uint64 addr, char *buf, int max)
{
  struct proc *p = myproc();
  // 3. 通过进程的用户页表 p->pagetable 翻译成物理地址，并将数据拷贝到 buf 中
  int err = copyinstr(p->pagetable, buf, addr, max);
  if(err < 0)
    return err;

  return strlen(buf);
}


int
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;
  while(got_null == 0 && max > 0){
    va0 = PGROUNDDOWN(srcva);
    // 4. 通过 walkaddr 找到 va0 对应的物理地址 pa0
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;

    n = PGSIZE - (srcva - va0);
    if(n > max)
      n = max;
      
    // 5. 下面就是一些偏移量计算
    // ... 
}

```

### 4.5 内核 Trap
和用户 Trap 类似，`uservec` 变为 `kernelvec`

### 4.6 Page-fault exceptions 缺页异常
xv6 处理异常的策略非常简陋
- 用户态发生异常就 kill process
- 内核态就进入 panic mode

缺页错误类型：
1. **加载页面错误**：`load` 指令（如 `li`）访问虚拟地址时找不到对应页面
2. **存储页面错误**：`store` 指令访问虚拟地址时找不到对应页面
3. **指令页面错误**：指令对应的虚拟地址找不到（代码段）

和缺页异常有关的寄存器：
`scause` -> 指示缺页错误类型
`stval` -> 保存无法转换的虚拟地址
`trapframe->epc` -> 触发 page fault 指令的地址

真实的操作系统处理方式会更有趣一些，例如：利用缺页异常实现 `copy-on-write` [[写时复制]] `fork`

**思考 xv6 的 fork：** `fork` 通过调用 `uvmcopy` 在物理内存上分配内存并且将父进程的内存复制到这块内存上，如果我们不需要复制，而是复用父进程的内存显然会更高效。但是这样，父子进程的写操作就可能破坏对方进程的内存结构
缺页异常驱动的 `copy-on-write fork` 就能很好地解决这个问题，同样利用缺页异常可以：
- [[内存懒加载]]
- [[从磁盘分页]]
- [[自增栈空间]]
- [[内存映射文件]]

# Chapter 7 进程调度
每个进程都会拥有自己的 **虚拟 CPU** ，实现多路复用

### 7.1 多路复用
每个 CPU 从一个进程切换到另一个进程有下面两种情况
- xv6 的 `sleep` 和 `wakeup` 机制在一个进程等待设备或者 I/O 完成时、等待子进程退出，等待 `sleep` 系统调用结束进行切换
- 