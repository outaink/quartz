- Remembering when and where to delete those pointers after use is difficult
- Deleting a pointer twice will lead to the program crash
- **Smart pointers**: we don't need to manually manage their allocated memory
- 
## Unique pointers
- ```cpp
  int main() {
    unique_ptr<int> x(new int);
- // 更简单的创建智能指针的方法
    auto y = make_unique<int>();
    auto numbers = make_unique<int[]>(10);
- // 打印指针
    cout << x << endl;
- // 解引用
    *x = 10;
    cout << *x << endl;
- // 无法进行指针运算
    return 0;
  }
  ```
## Shared pointers
- ```cpp
  int main() {
      auto x = make_shared<int>();
      *x = 10;

      auto y(x);
      if (x == y) {
          cout << "Equal";
      }

      return 0;
  }
  ```
- we can have two pointers pointing to the same memory location
