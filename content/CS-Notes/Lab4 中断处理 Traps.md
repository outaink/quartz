这个实验探索使用 traps 来实现 system call。首先有一个热身训练，然后将要实现一个用户层级的 trap 处理示例

实验前置操作
```shell
git fetch
git checkout traps
make clean
```

# RISC-V assembly 汇编代码
`easy`
> 理解一些 RISC-V 汇编指令很重要，有一个 `user/call.c` 文件在 xv6 仓库中. `make fs.img` 可以编译并生成一个可阅读的程序 `user/call.asm`。
> 阅读 `g`, `f`, `main` 函数，回答下面的几个问题

1. 哪几个寄存器存储函数的参数？例如，哪个寄存器存了 `printf` 的参数 13
2. 函数 `f` 的汇编调用在 `main` 的哪里？函数`g`？
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
  1c:	1141                	addi	sp,sp,-16
  1e:	e406                	sd	ra,8(sp)
  20:	e022                	sd	s0,0(sp)
  22:	0800                	addi	s0,sp,16
  printf("%d %d\n", f(8)+1, 13);
  24:	4635                	li	a2,13
  26:	45b1                	li	a1,12
  28:	00000517          	auipc	a0,0x0
  2c:	7b050513          	addi	a0,a0,1968 # 7d8 <malloc+0xea>
  30:	00000097          	auipc	ra,0x0
  34:	600080e7          	jalr	1536(ra) # 630 <printf>
  exit(0);
  38:	4501                	li	a0,0
  3a:	00000097          	auipc	ra,0x0
  3e:	27e080e7          	jalr	638(ra) # 2b8 <exit>
```