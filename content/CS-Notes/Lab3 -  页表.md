- 这个 lab 将会探索页表，并且修改页表的定义来简化从用户空间拷贝数据到内核空间的函数
- 涉及的文件：
  - `kernel/memlayout.h` -> 捕获内存页
  - `kernel/vm.c` -> 包括了大多数虚拟内存代码
  - `kernel/kalloc.c` -> 包括了分配和释放物理内存的代码
- **实验笔记**
  - {{embed ((68c34304-4829-459d-973b-1a3d3d9910ed))}}
# Print a page table
- `easy`
- 为了学习 RISC-V 的页表机制，并且也可能用于 debug，第一个任务是实现一个打印页表内容的函数
- > 定义一个`vmprint()`函数，参数为一个 `pagetable_t` ，按下面的格式打印这个页表。
  > 将 if(p->pid == 1) vmprint(p->pagetable) 插入到 `exec.c` 中，来打印第一个进城的页表
- ```shell
  page table 0x0000000087f6e000
  ..0: pte 0x0000000021fda801 pa 0x0000000087f6a000
  .. ..0: pte 0x0000000021fda401 pa 0x0000000087f69000
  .. .. ..0: pte 0x0000000021fdac1f pa 0x0000000087f6b000
  .. .. ..1: pte 0x0000000021fda00f pa 0x0000000087f68000
  .. .. ..2: pte 0x0000000021fd9c1f pa 0x0000000087f67000
  ..255: pte 0x0000000021fdb401 pa 0x0000000087f6d000
  .. ..511: pte 0x0000000021fdb001 pa 0x0000000087f6c000
  .. .. ..510: pte 0x0000000021fdd807 pa 0x0000000087f76000
  .. .. ..511: pte 0x0000000020001c0b pa 0x0000000080007000
  ```
- 第一行显示 `vmprint` 的参数。之后，每一个有效的页表项（PTE）都各占一行，包括那些指向树状结构中更深层页表页的 PTE。每一行 PTE 会通过一定数量的 " .." 进行缩进，以表示其在树状结构中的深度。每一行会显示该 PTE 在其页表页中的索引、PTE 的标志位（pte bits），以及从该 PTE 中提取出的物理地址。请不要打印无效的 PTE。
- 在上面的例子中，顶层页表页含有对条目 0 和 255 的映射。对于条目 0，其下一级页表中只有索引为 0 的条目被映射；而这个索引为 0 的条目所对应的最底层页表中，则含有对条目 0、1 和 2 的映射
- 核心代码：
  ```c
  // Helper function to print a single page table entry with proper indentation
  static void
  print_pte_entry(int index, pte_t pte, int level) {
    // Print indentation based on page table level (0=L2, 1=L1, 2=L0)
    for (int i = 0; i <= level; i++) {
      printf("..");
    }

    // Print the PTE index, raw value, and physical address
    printf("%d: pte %p pa %p\n", index, pte, PTE2PA(pte));
  }

  // Recursively walk and print page table entries
  static void
  vmprint_recursive(pagetable_t pagetable, int level) {
    // Iterate through all 512 entries in this page table
    for (int i = 0; i < 512; i++) {
      pte_t pte = pagetable[i];

      // Only process valid page table entries
      if (pte & PTE_V) {
        // Print the current entry
        print_pte_entry(i, pte, level);

        // Check if this PTE points to another page table (not a leaf)
        // A PTE is a pointer to next level if it doesn't have R/W/X bits set
        if ((pte & (PTE_R|PTE_W|PTE_X)) == 0) {
          // Extract the physical address of the next-level page table
          uint64 child_pa = PTE2PA(pte);
          // Recursively print the next level (level increases as we go deeper)
          vmprint_recursive((pagetable_t)child_pa, level + 1);
        }
      }
    }
  }

  // Print a visual representation of a page table hierarchy
  // Shows all valid page table entries in a tree-like format
  void
  vmprint(pagetable_t pagetable) {
    printf("page table %p\n", pagetable);
    vmprint_recursive(pagetable, 0);
  }
  ```
- 
# A kernel page table per process
- `hard`
[[Linux KPTI]]
- 
# Simplify
- `hard`
