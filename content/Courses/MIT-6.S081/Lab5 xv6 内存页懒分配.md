操作系统利用页表硬件实现的诸多巧妙技巧之一，便是对用户空间堆内存的延迟分配。Xv6应用程序通过 `sbrk()` 系统调用向内核请求堆内存。在我们提供的内核中，`sbrk()` 会分配物理内存并将其映射到进程的虚拟地址空间。对于大型内存请求，内核完成分配和映射可能耗时良久。例如，1GB内存由 `262,144` 个 `4096` 字节页面组成；即使每次分配成本很低，总数依然庞大。此外，某些程序分配的内存会超出实际使用量（如实现稀疏数组），或提前大量预分配内存。为使 `sbrk()` 在这些场景下更快完成，先进内核采用延迟分配机制：`sbrk()` 不分配物理内存，仅记录已分配的用户地址，并在用户页表中标记这些地址为无效。当进程首次尝试使用延迟分配的内存页时，CPU会触发页错误，此时内核才执行物理内存分配、清零及映射操作。在本实验中，你将为xv6内核添加这项延迟分配功能
>在开始编码之前，阅读 [[xv6 book 阅读笔记]] Chapter 4（主要是 4.6），相关文件
>`kernel/trap.c
>`kernel/vm.c
>`kernel/sysproc.c

```shell
git checkout lazy
```

# 在 `sbrk()` 中删除内存分配逻辑
`easy`
> 第一个任务是在 `sbrk()` 中删除内存分配的实现，新的 `sbrk()` 只会增加进程的大小，但是不会分配内存

尝试猜测这个修改的结果：什么东西会坏掉
进程这个修改后，启动 xv6，然后 `echo hi` ，你会看见
```shell
init: starting sh
$ echo hi
usertrap(): unexpected scause 0x000000000000000f pid=3
            sepc=0x0000000000001258 stval=0x0000000000004008
va=0x0000000000004000 pte=0x0000000000000000
panic: uvmunmap: not mapped
```

`usertrap():...` 这个信息是来源于 `trap.c` 的陷阱处理器，此时陷阱处理器不知道如何处理这个异常。确保明白这个缺页异常的原因。`stval=0x0000000000004008` 意味着这个虚拟地址导致的缺页异常地址为 `0x4008`

## 实验过程
核心代码
```c
uint64
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = myproc()->sz;
  // if(growproc(n) < 0)
  //   return -1;

  if (n > 0) {
    myproc()->sz += n;
  } else if( n < 0 ) {
    myproc()->sz = uvmdealloc(myproc()->pagetable, myproc()->sz, myproc()->sz + n);
  } else 
    return -1;

  return addr;
}
```

结果
```shell
hart 2 starting
hart 1 starting
init: starting sh
$ echo hi
usertrap(): unexpected scause 0x000000000000000f pid=3
            sepc=0x00000000000012ac stval=0x0000000000004008
panic: uvmunmap: not mapped
```

# 懒分配 Lazy allocation
`moderate`
> 修改 `trap.c` ，将一个新映射的物理内存页地址到缺页错误地址来响应用户空间的页错误，然后返回用户空间让程序继续执行。你应该在生成 `usertrap():...` 信息的 `printf` 前新增代码。想办法让 `echo hi` 来工作

提示：
- `r_cause()` 可以确认是否是页错误（`usertrap()`）
- `r_stval` 返回 RISC-V `stval` 寄存器的值，这个值表示造成页错误的虚拟地址
- 从 `uvmalloc()` 抄代码
- 使用 `PGROUNDDOWN(va)` 来将导致页错误的虚拟地址对齐到页边缘
- `uvmunmap()` 会报异常，解决这些异常
如果一切顺利，你的延迟分配代码应该能使 echo hi 正常工作。你至少会遇到一次页面故障（从而触发延迟分配），也可能遇到两次

## 实验过程

核心代码
```c
// kernel/trap.c
void
usertrap(void)
{
  ......
  } else if((which_dev = devintr()) != 0){
    // ok
  }
  else if (r_scause() == 13 || r_scause() == 15) {      // 惰性分配导致的缺页异常
      uint64 fault_va = r_stval();      // 获取引发缺页异常的虚拟地址
      char* pa = 0;                     // 分配的物理地址
      // 判断fault_va是否在进程栈空间之中
      if (PGROUNDUP(p->trapframe->sp) - 1 < fault_va && fault_va < p->sz && (pa = kalloc()) != 0) {
          memset(pa, 0, PGSIZE);
          // 物理内存映射
          if (mappages(p->pagetable, PGROUNDDOWN(fault_va), PGSIZE, (uint64)pa, PTE_R | PTE_W | PTE_X | PTE_U) != 0) {      
              printf("lazy alloc: failed to map page\n");
              kfree(pa);
              p->killed = 1;
          }
      }
  }else {
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    p->killed = 1;
  }

  ......
}
```

# Lazytests & Usertests
`moderate`
`lazytests` 是一个 xv6 用户程序，用来测试一些特殊用例，这可能对懒分配器造成压力。想办法让 `lazytests` 和 `usertests` 全部通过
- 处理 `sbrk()` 的负值
- 如果页错误的虚拟地址高于 `sbrk()` 分配的地址，就杀掉这个线程
- 正确处理 `fork()` 中父子进程间的内存复制
- 处理进程将 `sbrk()` 返回的有效地址传递给 `read` 或 `write` 等系统调用时，该地址对应内存尚未分配的情况
- 正确处理内存不足：若 `kalloc()` 在页面故障处理程序中失败，则终止当前进程
- 处理用户栈下方无效页面的故障
