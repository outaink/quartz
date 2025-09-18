- 在 C++ 中，我们要尽可能避免使用 C 类型的 string
- ```c
  int main() {
      char name[5] = "mhhh";
      cout << strlen(name);
  }
  ```
- 我们要使用
- ```cpp
  int main() {
      string name = "mhhh";
      cout << strlen(name);
  }
  ```
