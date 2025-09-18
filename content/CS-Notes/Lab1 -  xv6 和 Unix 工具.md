# Sleep
- `easy`
- > 实现 Unix 程序 `sleep` for xv6:
  > 暂停指定的 ticks（ticks 的定义由xv6内核提供）
  > 解决方案应该在 `user/sleep.c`
- 提示：
  - https://pdos.csail.mit.edu/6.S081/2020/xv6/book-riscv-rev1.pdf 的 Chapter 1
  - 参考 `user` 目录下的其他命令
  - 如果用户忘记传参数，应该返回错误信息
  - 命令行参数应该以 string 类型传递，可以在代码层使用 `user/lib.c` 下的 `atoi` 函数将字符串转换成一个 integer
  - 使用系统调用 `sleep`
  - 查看 `kernel/sysproc.c` 中实现的 `sleep` 系统调用，`user/user.h` 中定义了 `sleep` 用户调用的函数名，`user/usys.S` 中的汇编代码实现了 `sleep` 调用从用户态跳转到内核态
  - 确保 `main` 调用 `exit()` 结束代码
  - 加入实现的 `sleep` 程序到 Makefile 的 `UPROGS` 中。这样在重新 make qemu 时就能运行 `sleep`
  - 学习 C 语言开发
### 实验过程
  - 运行：
  - ```shell
	  make qemu

	  sleep 10
	  ```
  - 进行评分
  - ```shell
	  ./grade-lab-util sleep
	  ```
- 
### 实验笔记
[[xv6 book]]
- {{embed ((68c3424b-2a2a-4e9f-b4ea-ab13675a5098))}}
- 核心代码：
  ```css
  #include "kernel/types.h"
  #include "kernel/stat.h"
  #include "user/user.h"

  int main(int argc, char **argv) {
      if (argc < 2) {
          printf("usage: sleep <ticks>\n");
          exit(1);
      }
      sleep(atoi(argv[1]));
      exit(0);
  }
  ```
- 
# pingpong
- `easy`
  - > 编写一个程序，程序使用 UNIX 的系统调用将一个字节“打乒乓球”似的在两个管道进程中传递。父进程发送一个字节到子进程，子进程应该打印`<pid>:received ping`，`<pid>` 是这个进程的PID，并且子进程写回这个字节给父进程，然后退出。父进程读取到这个子进程发送回的字节，打印 `<pid>: received pong`，然后退出。解决方案应该在 `user/pingpong.c`
- **提示**：
  - 使用 `pipe` 创建一个管道
  - 使用 `fork`创建一个子进程
  - 使用 `read` 从管道中读取，使用 `write` 写入管道
  - 添加到 `UPROGS` 到 Makefile
  - 用户程序的库是有限的
- **核心代码**：
  ```c
  #include "kernel/types.h"
  #include "kernel/stat.h"
  #include "user/user.h"

  int main(int argc, char **argv) {
      int pipe_p2c[2], pipe_c2p[2];

      // 创建管道，在数组中写入管道读端和写端的文件描述符，[0]是读取端，[1]是写入端
      pipe(pipe_p2c);
      pipe(pipe_c2p);

      char ball = '.';

      if (fork() != 0) {
          write(pipe_p2c[1], &ball, 1);
          close(pipe_p2c[1]);

          char buf;
          read(pipe_c2p[0], &buf, 1);
          printf("%d: received pong\n", getpid());
          wait(0);
      } else {
          char buf;
          read(pipe_p2c[0], &buf, 1);
          printf("%d: received ping\n", getpid());

          write(pipe_c2p[1], &buf, 1);
          close(pipe_c2p[1]);
      }

      close(pipe_c2p[0]);
      close(pipe_p2c[0]);

      exit(0);
  }
  ```
- 
# Primes
- `hard`
- > 编写一个并发版本的质数筛。 ![image.png](../assets/image_1757310741950_0.png){:height 175, :width 698}
- 核心代码：
  ```c
  #include "kernel/types.h"
  #include "kernel/stat.h"
  #include "user/user.h"

  #define END_MARKER -1
  #define MAX_NUMBER 35

  void sieve_process(int read_fd) {
      int prime;
      int bytes_read = read(read_fd, &prime, sizeof(prime));

      if (bytes_read == 0 || prime == END_MARKER) {
          close(read_fd);
          exit(0);
      }

      printf("prime %d\n", prime);

      int next_pipe[2];
      pipe(next_pipe);

      if (fork() == 0) {
          close(read_fd);
          close(next_pipe[1]);
          sieve_process(next_pipe[0]);
      } else {
          close(next_pipe[0]);

          int number;
          while (read(read_fd, &number, sizeof(number)) > 0) {
              if (number == END_MARKER) {
                  write(next_pipe[1], &number, sizeof(number));
                  break;
              }
              if (number % prime != 0) {
                  write(next_pipe[1], &number, sizeof(number));
              }
          }

          close(read_fd);
          close(next_pipe[1]);
          wait(0);
          exit(0);
      }
  }

  int main(int argc, char **argv) {
      int numbers_pipe[2];
      pipe(numbers_pipe);

      if (fork() == 0) {
          close(numbers_pipe[1]);
          sieve_process(numbers_pipe[0]);
      } else {
          close(numbers_pipe[0]);

          for (int i = 2; i <= MAX_NUMBER; i++) {
              write(numbers_pipe[1], &i, sizeof(i));
          }

          int end_marker = END_MARKER;
          write(numbers_pipe[1], &end_marker, sizeof(end_marker));
          close(numbers_pipe[1]);

          wait(0);
      }

      exit(0);
  }
  ```
