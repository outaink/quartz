## 属性动画
- ```kotlin
  // 点击 View 会进行一个放大两倍的动画
  fun onClick(v: View) {
    v.animate().scaleY(2f)
    	.scaleX(2f)
      .start()
  }
  ```
- 不会改变属性（即不会影响控件的测量）
- 
## Transition动画
- ```kotlin
  // 点击 View 会进行一个放大两倍的动画
  fun onClick(v: View) {
  	TransitionManager.beginDelayedTransition(v.parent.smartCast())
      with(v.layoutParams.smartCast<LinearLayout.LayoutParams>()) {
        height *= 2
        width *= 2
      }

      // 手动触发页面测量
      v.requestLayout()
  }
  ```
- 会改变属性，即达成多个 View 的联动，大部分情况更符合需求
