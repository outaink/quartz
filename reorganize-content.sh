#!/bin/bash

# ========================================
# 博客内容重组织脚本
# 用于重新组织 Quartz 博客的内容结构
# ========================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印函数
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[→]${NC} $1"
}

echo "╔═══════════════════════════════════════╗"
echo "║     博客内容重组织脚本 v1.0          ║"
echo "╚═══════════════════════════════════════╝"
echo ""

# 检查是否在 content 目录
if [ ! -d "Android-Notes" ] || [ ! -d "CS-Notes" ]; then
    print_error "请在 content 目录下运行此脚本"
    exit 1
fi

# 备份提醒
print_warning "开始前请确保已经备份了所有内容！"
read -p "是否已经完成备份？(y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_error "请先备份后再运行此脚本"
    exit 1
fi

# 第一步：创建新的目录结构
print_info "创建新的目录结构..."

# Android 开发目录
mkdir -p Android-Dev/{Components,Architecture,UI,Compose,Framework,Performance}

# Java 核心目录
mkdir -p Java-Core/{Basics,Collections,Concurrency,JVM,Design-Patterns}

# 系统基础目录
mkdir -p System-Fundamentals/{Operating-System,Memory,Linking}

# 网络技术目录
mkdir -p Network/{Protocols,HTTP,Architecture,Practice}

# 数据结构目录
mkdir -p Data-Structures/{Trees,Database}

# 课程目录
mkdir -p Courses/{MIT-6.S081,CPP-Basics}

# 职业发展目录
mkdir -p Career

# 博客目录
mkdir -p Blog

print_status "目录结构创建完成"

# 第二步：迁移 Android-Notes 内容
print_info "迁移 Android-Notes 内容..."

# Components
[ -f "Android-Notes/Activity.md" ] && git mv "Android-Notes/Activity.md" "Android-Dev/Components/" 2>/dev/null || true
[ -f "Android-Notes/Service.md" ] && git mv "Android-Notes/Service.md" "Android-Dev/Components/" 2>/dev/null || true
[ -f "Android-Notes/Android四大组件.md" ] && git mv "Android-Notes/Android四大组件.md" "Android-Dev/Components/" 2>/dev/null || true

# Architecture
[ -f "Android-Notes/MVI.md" ] && git mv "Android-Notes/MVI.md" "Android-Dev/Architecture/" 2>/dev/null || true
[ -f "Android-Notes/ViewModel.md" ] && git mv "Android-Notes/ViewModel.md" "Android-Dev/Architecture/" 2>/dev/null || true
[ -f "Android-Notes/LiveData.md" ] && git mv "Android-Notes/LiveData.md" "Android-Dev/Architecture/" 2>/dev/null || true
[ -f "Android-Notes/SavedInstance 和 NonConfiguration.md" ] && git mv "Android-Notes/SavedInstance 和 NonConfiguration.md" "Android-Dev/Architecture/" 2>/dev/null || true
[ -f "Android-Notes/架构模式.md" ] && git mv "Android-Notes/架构模式.md" "Android-Dev/Architecture/" 2>/dev/null || true

# UI
[ -f "Android-Notes/View.md" ] && git mv "Android-Notes/View.md" "Android-Dev/UI/" 2>/dev/null || true
[ -f "Android-Notes/布局过程解析.md" ] && git mv "Android-Notes/布局过程解析.md" "Android-Dev/UI/" 2>/dev/null || true
[ -f "Android-Notes/Android触摸事件分发机制.md" ] && git mv "Android-Notes/Android触摸事件分发机制.md" "Android-Dev/UI/" 2>/dev/null || true
[ -f "Android-Notes/属性动画和Transition动画.md" ] && git mv "Android-Notes/属性动画和Transition动画.md" "Android-Dev/UI/" 2>/dev/null || true

# Compose
[ -f "Android-Notes/Compose.md" ] && git mv "Android-Notes/Compose.md" "Android-Dev/Compose/" 2>/dev/null || true
[ -f "Android-Notes/Compose 重组的性能风险和优化.md" ] && git mv "Android-Notes/Compose 重组的性能风险和优化.md" "Android-Dev/Compose/" 2>/dev/null || true

# Framework
[ -f "Android-Notes/Handler机制.md" ] && git mv "Android-Notes/Handler机制.md" "Android-Dev/Framework/" 2>/dev/null || true
[ -f "Android-Notes/全局监听 Activity 的销毁.md" ] && git mv "Android-Notes/全局监听 Activity 的销毁.md" "Android-Dev/Framework/" 2>/dev/null || true

# Performance
[ -f "Android-Notes/LeakCanary原理.md" ] && git mv "Android-Notes/LeakCanary原理.md" "Android-Dev/Performance/" 2>/dev/null || true

# Java 相关内容
[ -f "Android-Notes/Object类.md" ] && git mv "Android-Notes/Object类.md" "Java-Core/Basics/" 2>/dev/null || true
[ -f "Android-Notes/抽象类和接口.md" ] && git mv "Android-Notes/抽象类和接口.md" "Java-Core/Basics/" 2>/dev/null || true
[ -f "Android-Notes/Map.md" ] && git mv "Android-Notes/Map.md" "Java-Core/Collections/" 2>/dev/null || true
[ -f "Android-Notes/HashMap、HashTable、ConcurrentHashMap有什么相同和不同.md" ] && git mv "Android-Notes/HashMap、HashTable、ConcurrentHashMap有什么相同和不同.md" "Java-Core/Collections/" 2>/dev/null || true
[ -f "Android-Notes/Java 反射机制.md" ] && git mv "Android-Notes/Java 反射机制.md" "Java-Core/JVM/" 2>/dev/null || true
[ -f "Android-Notes/Java 类加载过程实验.md" ] && git mv "Android-Notes/Java 类加载过程实验.md" "Java-Core/JVM/" 2>/dev/null || true
[ -f "Java 类加载器.md" ] && git mv "Java 类加载器.md" "Java-Core/JVM/" 2>/dev/null || true
[ -f "Android-Notes/责任链模式.md" ] && git mv "Android-Notes/责任链模式.md" "Java-Core/Design-Patterns/" 2>/dev/null || true

# 网络相关
[ -f "Android-Notes/TCP三次握手四次挥手.md" ] && git mv "Android-Notes/TCP三次握手四次挥手.md" "Network/Protocols/" 2>/dev/null || true
[ -f "Android-Notes/HTTP特性与简述.md" ] && git mv "Android-Notes/HTTP特性与简述.md" "Network/HTTP/" 2>/dev/null || true
[ -f "Android-Notes/在浏览器中输入URL后按下回车会发生什么.md" ] && git mv "Android-Notes/在浏览器中输入URL后按下回车会发生什么.md" "Network/Practice/" 2>/dev/null || true
[ -f "Android-Notes/计算机网络.md" ] && git mv "Android-Notes/计算机网络.md" "Network/Architecture/" 2>/dev/null || true

# 职业相关
[ -f "Android-Notes/实习经历.md" ] && git mv "Android-Notes/实习经历.md" "Career/" 2>/dev/null || true

print_status "Android-Notes 内容迁移完成"

# 第三步：迁移 CS-Notes 内容
print_info "迁移 CS-Notes 内容..."

# MIT 6.S081 课程
[ -f "CS-Notes/MIT 6.s081.md" ] && git mv "CS-Notes/MIT 6.s081.md" "Courses/MIT-6.S081/" 2>/dev/null || true
[ -f "CS-Notes/xv6 book 阅读笔记.md" ] && git mv "CS-Notes/xv6 book 阅读笔记.md" "Courses/MIT-6.S081/" 2>/dev/null || true
[ -f "CS-Notes/Lab1 xv6 和 Unix 工具.md" ] && git mv "CS-Notes/Lab1 xv6 和 Unix 工具.md" "Courses/MIT-6.S081/" 2>/dev/null || true
[ -f "CS-Notes/Lab2 系统调用.md" ] && git mv "CS-Notes/Lab2 系统调用.md" "Courses/MIT-6.S081/" 2>/dev/null || true
[ -f "CS-Notes/Lab3 页表.md" ] && git mv "CS-Notes/Lab3 页表.md" "Courses/MIT-6.S081/" 2>/dev/null || true
[ -f "CS-Notes/Lab4 中断处理 Traps.md" ] && git mv "CS-Notes/Lab4 中断处理 Traps.md" "Courses/MIT-6.S081/" 2>/dev/null || true

# 操作系统
[ -f "CS-Notes/操作系统.md" ] && git mv "CS-Notes/操作系统.md" "System-Fundamentals/Operating-System/" 2>/dev/null || true
[ -f "CS-Notes/进程与线程.md" ] && git mv "CS-Notes/进程与线程.md" "System-Fundamentals/Operating-System/" 2>/dev/null || true
[ -f "CS-Notes/IPC通信方式.md" ] && git mv "CS-Notes/IPC通信方式.md" "System-Fundamentals/Operating-System/" 2>/dev/null || true
[ -f "CS-Notes/时钟中断.md" ] && git mv "CS-Notes/时钟中断.md" "System-Fundamentals/Operating-System/" 2>/dev/null || true
[ -f "CS-Notes/死锁的必要条件和处理方式.md" ] && git mv "CS-Notes/死锁的必要条件和处理方式.md" "System-Fundamentals/Operating-System/" 2>/dev/null || true

# 内存管理
[ -f "CS-Notes/虚拟内存.md" ] && git mv "CS-Notes/虚拟内存.md" "System-Fundamentals/Memory/" 2>/dev/null || true
[ -f "CS-Notes/物理内存.md" ] && git mv "CS-Notes/物理内存.md" "System-Fundamentals/Memory/" 2>/dev/null || true
[ -f "CS-Notes/段存储、页存储、段页存储.md" ] && git mv "CS-Notes/段存储、页存储、段页存储.md" "System-Fundamentals/Memory/" 2>/dev/null || true
[ -f "CS-Notes/缺页中断.md" ] && git mv "CS-Notes/缺页中断.md" "System-Fundamentals/Memory/" 2>/dev/null || true
[ -f "CS-Notes/PTE.md" ] && git mv "CS-Notes/PTE.md" "System-Fundamentals/Memory/" 2>/dev/null || true
[ -f "CS-Notes/虚拟地址、逻辑地址、线性地址、物理地址的区别.md" ] && git mv "CS-Notes/虚拟地址、逻辑地址、线性地址、物理地址的区别.md" "System-Fundamentals/Memory/" 2>/dev/null || true

# 链接与加载
[ -f "CS-Notes/动态链接、静态链接.md" ] && git mv "CS-Notes/动态链接、静态链接.md" "System-Fundamentals/Linking/" 2>/dev/null || true
[ -f "CS-Notes/实验：观察MacOS上的动态链接和静态链接.md" ] && git mv "CS-Notes/实验：观察MacOS上的动态链接和静态链接.md" "System-Fundamentals/Linking/" 2>/dev/null || true

# 网络协议
[ -f "CS-Notes/TCP&IP.md" ] && git mv "CS-Notes/TCP&IP.md" "Network/Protocols/" 2>/dev/null || true
[ -f "CS-Notes/DHCP.md" ] && git mv "CS-Notes/DHCP.md" "Network/Protocols/" 2>/dev/null || true
[ -f "CS-Notes/CDN.md" ] && git mv "CS-Notes/CDN.md" "Network/Protocols/" 2>/dev/null || true

# HTTP 相关
[ -f "CS-Notes/HTTP版本演变和特点.md" ] && git mv "CS-Notes/HTTP版本演变和特点.md" "Network/HTTP/" 2>/dev/null || true
[ -f "CS-Notes/HTTP2.0.md" ] && git mv "CS-Notes/HTTP2.0.md" "Network/HTTP/" 2>/dev/null || true
[ -f "CS-Notes/HTTP3.0.md" ] && git mv "CS-Notes/HTTP3.0.md" "Network/HTTP/" 2>/dev/null || true
[ -f "CS-Notes/QUIC.md" ] && git mv "CS-Notes/QUIC.md" "Network/HTTP/" 2>/dev/null || true
[ -f "CS-Notes/HTTP缓存.md" ] && git mv "CS-Notes/HTTP缓存.md" "Network/HTTP/" 2>/dev/null || true
[ -f "CS-Notes/HTTP短链接和长链接.md" ] && git mv "CS-Notes/HTTP短链接和长链接.md" "Network/HTTP/" 2>/dev/null || true
[ -f "CS-Notes/状态码.md" ] && git mv "CS-Notes/状态码.md" "Network/HTTP/" 2>/dev/null || true

# 网络架构
[ -f "CS-Notes/计算机网络.md" ] && git mv "CS-Notes/计算机网络.md" "Network/Architecture/" 2>/dev/null || true
[ -f "CS-Notes/计算机网络体系结构.md" ] && git mv "CS-Notes/计算机网络体系结构.md" "Network/Architecture/" 2>/dev/null || true

# 数据结构
[ -f "CS-Notes/树.md" ] && git mv "CS-Notes/树.md" "Data-Structures/Trees/" 2>/dev/null || true
[ -f "CS-Notes/AVL平衡二叉搜索树.md" ] && git mv "CS-Notes/AVL平衡二叉搜索树.md" "Data-Structures/Trees/" 2>/dev/null || true
[ -f "CS-Notes/红黑树.md" ] && git mv "CS-Notes/红黑树.md" "Data-Structures/Trees/" 2>/dev/null || true
[ -f "CS-Notes/B+树.md" ] && git mv "CS-Notes/B+树.md" "Data-Structures/Trees/" 2>/dev/null || true

# 数据库
[ -f "CS-Notes/数据库.md" ] && git mv "CS-Notes/数据库.md" "Data-Structures/Database/" 2>/dev/null || true
[ -f "CS-Notes/索引.md" ] && git mv "CS-Notes/索引.md" "Data-Structures/Database/" 2>/dev/null || true

# Java 并发
[ -f "CS-Notes/JUC.md" ] && git mv "CS-Notes/JUC.md" "Java-Core/Concurrency/" 2>/dev/null || true
[ -f "CS-Notes/Atomic原子类.md" ] && git mv "CS-Notes/Atomic原子类.md" "Java-Core/Concurrency/" 2>/dev/null || true
[ -f "CS-Notes/读写锁.md" ] && git mv "CS-Notes/读写锁.md" "Java-Core/Concurrency/" 2>/dev/null || true

# C++ 相关
[ -f "CS-Notes/C++.md" ] && git mv "CS-Notes/C++.md" "Courses/CPP-Basics/" 2>/dev/null || true
[ -f "CS-Notes/Pointers & Constants.md" ] && git mv "CS-Notes/Pointers & Constants.md" "Courses/CPP-Basics/" 2>/dev/null || true
[ -f "CS-Notes/Smart Pointers.md" ] && git mv "CS-Notes/Smart Pointers.md" "Courses/CPP-Basics/" 2>/dev/null || true
[ -f "CS-Notes/String.md" ] && git mv "CS-Notes/String.md" "Courses/CPP-Basics/" 2>/dev/null || true

print_status "CS-Notes 内容迁移完成"

# 第四步：移动 assets 目录
print_info "移动资源文件..."
[ -d "Android-Notes/assets" ] && git mv "Android-Notes/assets" "Android-Dev/" 2>/dev/null || true
[ -d "CS-Notes/assets" ] && git mv "CS-Notes/assets" "System-Fundamentals/" 2>/dev/null || true
print_status "资源文件移动完成"

# 第五步：清理空目录和剩余文件
print_info "清理剩余文件..."

# 移动未分类的文件到 Blog 目录
remaining_android=$(ls Android-Notes/*.md 2>/dev/null | wc -l)
remaining_cs=$(ls CS-Notes/*.md 2>/dev/null | wc -l)

if [ "$remaining_android" -gt 0 ]; then
    print_warning "Android-Notes 中还有 $remaining_android 个文件未分类，移动到 Blog 目录"
    for file in Android-Notes/*.md; do
        [ -f "$file" ] && git mv "$file" "Blog/" 2>/dev/null || true
    done
fi

if [ "$remaining_cs" -gt 0 ]; then
    print_warning "CS-Notes 中还有 $remaining_cs 个文件未分类，移动到 Blog 目录"
    for file in CS-Notes/*.md; do
        [ -f "$file" ] && git mv "$file" "Blog/" 2>/dev/null || true
    done
fi

print_status "清理完成"

# 第六步：创建各分类的索引文件
print_info "创建分类索引文件..."

# Android-Dev 索引
cat > "Android-Dev/index.md" << 'EOF'
---
title: Android 开发
---

# 📱 Android 开发

Android 开发相关的技术文档和学习笔记。

## 目录结构

- **Components** - Android 四大组件
- **Architecture** - 架构模式（MVVM、MVI等）
- **UI** - 用户界面和视图系统
- **Compose** - Jetpack Compose 相关
- **Framework** - Android Framework 层
- **Performance** - 性能优化
EOF

# Java-Core 索引
cat > "Java-Core/index.md" << 'EOF'
---
title: Java 核心技术
---

# ☕ Java 核心技术

Java 语言基础到高级特性的学习笔记。

## 目录结构

- **Basics** - 基础语法和概念
- **Collections** - 集合框架
- **Concurrency** - 并发编程
- **JVM** - Java 虚拟机
- **Design-Patterns** - 设计模式
EOF

# System-Fundamentals 索引
cat > "System-Fundamentals/index.md" << 'EOF'
---
title: 系统基础
---

# 🖥️ 系统基础

操作系统、内存管理等底层知识。

## 目录结构

- **Operating-System** - 操作系统原理
- **Memory** - 内存管理
- **Linking** - 链接与加载
EOF

# Network 索引
cat > "Network/index.md" << 'EOF'
---
title: 网络技术
---

# 🌐 网络技术

从 TCP/IP 到 HTTP/3 的网络协议栈学习笔记。

## 目录结构

- **Protocols** - 网络协议
- **HTTP** - HTTP 协议族
- **Architecture** - 网络架构
- **Practice** - 实践案例
EOF

# Data-Structures 索引
cat > "Data-Structures/index.md" << 'EOF'
---
title: 数据结构与算法
---

# 📊 数据结构与算法

经典数据结构和算法的学习与实现。

## 目录结构

- **Trees** - 树结构
- **Database** - 数据库相关
EOF

# Courses 索引
cat > "Courses/index.md" << 'EOF'
---
title: 课程学习
---

# 🎓 课程学习

优质课程的学习笔记。

## 目录结构

- **MIT-6.S081** - MIT 操作系统课程
- **CPP-Basics** - C++ 基础学习
EOF

print_status "索引文件创建完成"

# 第七步：生成迁移报告
print_info "生成迁移报告..."

cat > "migration-report.md" << EOF
# 内容重组织迁移报告
生成时间：$(date '+%Y-%m-%d %H:%M:%S')

## 迁移统计

### Android-Dev
- Components: $(ls Android-Dev/Components/*.md 2>/dev/null | wc -l) 个文件
- Architecture: $(ls Android-Dev/Architecture/*.md 2>/dev/null | wc -l) 个文件
- UI: $(ls Android-Dev/UI/*.md 2>/dev/null | wc -l) 个文件
- Compose: $(ls Android-Dev/Compose/*.md 2>/dev/null | wc -l) 个文件
- Framework: $(ls Android-Dev/Framework/*.md 2>/dev/null | wc -l) 个文件
- Performance: $(ls Android-Dev/Performance/*.md 2>/dev/null | wc -l) 个文件

### Java-Core
- Basics: $(ls Java-Core/Basics/*.md 2>/dev/null | wc -l) 个文件
- Collections: $(ls Java-Core/Collections/*.md 2>/dev/null | wc -l) 个文件
- Concurrency: $(ls Java-Core/Concurrency/*.md 2>/dev/null | wc -l) 个文件
- JVM: $(ls Java-Core/JVM/*.md 2>/dev/null | wc -l) 个文件
- Design-Patterns: $(ls Java-Core/Design-Patterns/*.md 2>/dev/null | wc -l) 个文件

### System-Fundamentals
- Operating-System: $(ls System-Fundamentals/Operating-System/*.md 2>/dev/null | wc -l) 个文件
- Memory: $(ls System-Fundamentals/Memory/*.md 2>/dev/null | wc -l) 个文件
- Linking: $(ls System-Fundamentals/Linking/*.md 2>/dev/null | wc -l) 个文件

### Network
- Protocols: $(ls Network/Protocols/*.md 2>/dev/null | wc -l) 个文件
- HTTP: $(ls Network/HTTP/*.md 2>/dev/null | wc -l) 个文件
- Architecture: $(ls Network/Architecture/*.md 2>/dev/null | wc -l) 个文件
- Practice: $(ls Network/Practice/*.md 2>/dev/null | wc -l) 个文件

### 其他
- Data-Structures: $(find Data-Structures -name "*.md" 2>/dev/null | wc -l) 个文件
- Courses: $(find Courses -name "*.md" 2>/dev/null | wc -l) 个文件
- Career: $(ls Career/*.md 2>/dev/null | wc -l) 个文件
- Blog: $(ls Blog/*.md 2>/dev/null | wc -l) 个文件

## 总计
- 文件总数：$(find . -name "*.md" -not -path "./Android-Notes/*" -not -path "./CS-Notes/*" | wc -l) 个
EOF

print_status "迁移报告已生成：migration-report.md"

echo ""
echo "╔═══════════════════════════════════════╗"
echo "║         内容重组织完成！              ║"
echo "╚═══════════════════════════════════════╝"
echo ""
print_info "后续步骤："
echo "1. 检查 migration-report.md 确认迁移结果"
echo "2. 更新 index.md 中的链接"
echo "3. 运行 'npx quartz build' 构建网站"
echo "4. 提交更改：git add . && git commit -m '重组织内容结构'"
echo ""
print_warning "注意：原始的 Android-Notes 和 CS-Notes 目录可能还有剩余文件，请手动检查"