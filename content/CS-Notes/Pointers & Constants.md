## Data is constant
  - ```cpp
	  int main() {
	      const int x = 10;
	      const int* ptr = &x;

	      return 0;
	  }
	  ```
  - x is constant,  ptr is not constant
## Pointer is constant
  - ```cpp
	  int main() {
	      int x = 10;
	      int* const ptr = &x;

	   	// int y = 20;
	    	// 
	      return 0;
	  }
	  ```
## Both data and pointer are constant
- ```cpp
  int main() {
      const int x = 10;
      const int* const ptr = &x;

      return 0;
  }
  ```
