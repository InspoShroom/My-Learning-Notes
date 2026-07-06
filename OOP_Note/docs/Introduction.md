# C++概述与面向对象基础

​	第一节主要介绍了面向对象编程的发展背景，C++ 语言的历史以及 C++ 相比于 C 语言的核心改进与特性。

---

### 面向对象编程的发展背景

#### 两次软件危机

* **第一次软件危机**：主要体现在软件的**复杂性**（Complexity）激增。这次危机促进了结构化程序设计（Structured Programming）与面向过程方法的诞生与推广。
* **第二次软件危机**：主要体现在软件的**可扩展性**（Scalability）和**可维护性**（Maintainability）上面。传统的面向过程方法（如结构化设计）由于数据与操作的分离，难以适应快速、多变的业务需求。这直接推动了面向对象编程（OOP）思想的快速发展与普及。

#### 核心概念与词汇

面向对象的核心支柱与关键特性包括：

* **封装（Encapsulation）**：将数据和操作数据的方法绑定在一起，提供访问控制。
* **继承（Inheritance）**：允许从现有类派生新类，实现行为和实现的重用。
* **多态（Polymorphism）**：通过动态绑定实现同一接口的多种形态调用。
* 其他相关概念：模板（Templates）、内聚（Cohesion）、耦合（Coupling）、接口（Interface）、迭代器（Iterators）、责任驱动设计（Responsibility-Driven Design）等。

---

### C++ 语言起源

* 创始人：Bjarne Stroustrup，于 20 世纪 80 年代初在 AT&T 贝尔实验室设计并实现。
* **定位**：C++ 是一种**混合型语言**（Hybrid Language），它既支持面向过程编程（POP），又支持面向对象编程（OOP），同时还支持泛型编程（Generic Programming）。C++ 可以被视为“更好的 C”，但其设计理念已经超越了单纯的 C 语言扩展。

---

### 首个 C++ 程序示例

#### Hello World 程序

在 C++ 中，标准输入输出流取代了 C 语言中的 `printf` 和 `scanf`。

??? example "点击查看代码"
    ```cpp
    #include <iostream>  // 包含标准输入输出流头文件
    using namespace std; // 使用标准命名空间
    
    int main() {
        // cout 是标准输出流对象，<< 是流插入运算符
        cout << "Hello, World! I am " << 18 << " Today!" << endl;
        return 0;
    }
    ```

#### 基本输入与读取
利用 `cin` 进行格式化输入读取：

??? example "点击查看代码"
    ```cpp
    #include <iostream>
    using namespace std;
    
    int main() {
        int number;
        cout << "Enter a decimal number: ";
        // cin 是标准输入流对象，>> 是流提取运算符
        cin >> number;
        cout << "The number you entered is " << number << "." << endl;
        return 0;
    }
    ```

---

### C++ 对 C 语言的改进

C++ 引入了大量高级特性，使其相比 C 语言更加安全、强大且适合大型软件开发：

#### 类型安全与易用性改进
* **更严格的类型检查**：减少隐式类型转换带来的 Bug。
* **引用（References）**：`&`，引入起别名的机制，避免了指针的繁琐与危险。
* **名字控制（Name Control）**：通过命名空间（`namespace`）和类作用域解决全局命名冲突。
* **常量系统（Constants）**：增强的 `const` 关键字，默认具有内部链接属性。

#### 面向对象与抽象支持
* **数据抽象与访问控制**：通过 `class` 结合 `public`/`private`/`protected` 关键字实现封装。
* **初始化与清理机制**：引入构造函数（Constructor）与析构函数（Destructor），保证对象生命周期的安全。
* **函数重载（Function Overloading）**：允许同名但参数列表不同的函数共存。
* **内联函数（Inline Functions）**：在保持函数封装性的同时，消除函数调用开销。
* **运算符重载（Operator Overloading）**：为自定义对象提供直观的运算语义。

#### 高级语言特性
* **更安全强大的内存管理**：使用 `new` 和 `delete` 运算符取代 `malloc` 和 `free`。
* **模板（Templates）**：支持泛型编程，实现高度可复用的容器与算法。
* **异常处理（Exception Handling）**：引入 `try`/`catch` 结构，提供结构化的错误处理方式。
* **标准模板库（STL）**：提供极其丰富的容器（如 `vector`, `list`）、迭代器和算法。
