# 模板与泛型编程

本节详细阐述了泛型编程思想、函数模板与类模板的语法规则、模板精确匹配与重载决议、非类型模板参数、模板继承及著名的 CRTP 模式、以及类模板编译时的物理组织限制。

---

### 为什么需要模板？

在传统开发中，如果我们需要为不同类型编写相同的逻辑结构（例如存储 `int` 的列表和存储 `double` 的列表），通常面临以下困境：

1. 要求共同基类：强制所有存入的对象继承同一个抽象基类。但这在逻辑上并不总是成立。
2. 复制代码：虽然类型安全，但代码极其臃肿，难以维护，通常表现为一改全改。
3. 无类型列表：使用 `void*` 指针。但这会丧失编译器类型安全检查，强制转换极易出错。

**模板（Templates）** 彻底解决了这一矛盾：它允许将**类型（Type）**本身作为参数进行传递，实现真正的**泛型编程（Generic Programming）**。

---

### 函数模板

#### 函数模板语法
利用 `template <class T>` 或 `template <typename T>` 声明模板。其中 `T` 是参数化类型名/占位符。当然`T`只是一个不成文习惯表示，你可以是使用其他的字母或者表达。
    ```cpp
    template <class T>
    void swap(T& x, T& y) {
        T temp = x;
        x = y;
        y = temp;
    }
    ```

#### 模板实例化
* 原理：模板本身不是真正的函数，不产生机器码。当调用 `swap(a, b)` 时，编译器会根据实参类型（例如 `int`），自动推导并生成一个具体类型的函数（如 `swap(int&, int&)`）。这个过程称为**实例化**。而*模板函数就是函数模板的实例化结果*
* 显式指定模板参数：如果函数没有形参，或者无法自动推导类型，可以在函数名后加尖括号显式指定：
        ```cpp
        template <class T> void foo() {}
        foo<int>();   // 实例化 T 为 int
        foo<float>(); // 实例化 T 为 float
        ```

#### 模板的交互原则
!!! info "核心规则：模板匹配不允许任何隐式类型转换"
    普通函数调用支持隐式类型转换（如将 `float` 转换为 `double`），但函数模板匹配时**要求操作数类型必须精确匹配（Exact Match）**。

    * `swap(int, int)` —— OK（T 被推导为 int）。
    * `swap(double, double)` —— OK（T 被推导为 double）。
    * `swap(int, double)` —— **编译报错！** 编译器不会尝试将 `int` 强转为 `double` 或将 `double` 强转为 `int`，因为它无法断定 `T` 究竟代表哪个类型。

#### 模板重载决议规则
当普通函数、重载函数和函数模板同时共存时，编译器的选择优先级为：

1. *第一优先级*：寻找参数完全匹配的**普通非模板函数**。如果存在，优先调用。
2. *第二优先级*：寻找参数完全精确匹配的**函数模板实例化版本**。
3. *第三优先级*：尝试通过**普通函数的隐式类型转换**进行匹配决议。
例如：
    ```cpp
    f(1, 2)：优先匹配 f(int, int)。
    f(1.0, 2.0)：发现匹配f(int, int)还需要隐式转换，而f(T, T)可以直接匹配为double，因此选择f(T, T)。
    f(1, 2.0)：这里无法进行模板匹配，所以选择普通函数f(int, int)进行隐式转换。
    ```

---

### 类模板

#### 类模板语法与类外成员实现
类模板用于定义泛型容器（如 `Stack`、`Vector`、`List`）。
    ```cpp
    // Vector 类模板定义
    template <class T>
    class Vector {
    public:
        Vector(int size);
        T& operator[](int index);
    private:
        T* m_elements;
        int m_size;
    };
    
    // 成员函数在类外定义时，注意双重声明及类名限定符
    template <class T>
    Vector<T>::Vector(int size) : m_size(size) {
        m_elements = new T[m_size];
    }
    
    template <class T>
    T& Vector<T>::operator[](int index) {
        return m_elements[index];
    }
    ```

#### 类模板的多参数与嵌套
* 多参数：模板可以接受多个参数，如 `template <class Key, class Value> class HashTable {};`。
* 嵌套模板：模板可以任意嵌套。

    *注：在旧版 C++ 编译器中，嵌套模板的右尖括号之间必须留有空格（如 `Vector<Vector<double*> >`），否则会被解析为流提取运算符 `>>`。现代 C++ 已经修复此问题。*

---

### 非类型模板参数

除了类型，模板还可以接受**编译期常量表达式**作为参数（称为非类型模板参数（Non-Type Template Parameters））。
    ```cpp
    template <class T, int bounds = 100>
    class FixedVector {
    private:
        T elements[bounds]; // 在编译期直接确定数组大小，无需在堆上动态分配
    };
    
    FixedVector<int, 50> v1;      // bounds = 50
    FixedVector<int, 10*5> v2;    // bounds = 50 (常量表达式)
    FixedVector<int> v3;          // bounds = 100 (采用默认值)
    ```

* 优点：规避了堆内存分配的额外运行期开销，极大提高了数组存取速度。
* 缺点：代码膨胀。每一个不同的常量参数都会让编译器生成一份独立的类代码（例如 `FixedVector<int, 50>` 与 `FixedVector<int, 100>` 属于完全不同的两个类），容易导致代码体积增大。

---

### 模板与继承

模板与普通类之间可以自由进行继承组合：

1. **模板继承非模板类**：
        ```cpp
        template <class T> class Derived : public Base {};
        ```
2. **模板继承模板类**：
        ```cpp
        template <class T> class Derived : public List<T> {};
        ```
3. **非模板类继承模板类的具体实例**：
        ```cpp
        class SupervisorGroup : public List<Employee*> {};
        ```

#### 奇异递归模板模式
这是一种在泛型编程中利用继承模拟动态多态（虚函数）的经典技术。它通过静态绑定在编译期实现多态效果，消除了运行期虚函数表查询的开销。
??? example "点击查看代码"
    ```cpp
    template <class T>
    struct Base {
        void implementation() {
            // 在基类中直接强转为子类指针，调用子类的具体实现
            static_cast<T*>(this)->implementation();
        }
    };
    
    struct Derived : public Base<Derived> {
        void implementation() {
            cout << "Derived implementation" << endl;
        }
    };
    ```

---

### 核心物理组织规则：头文件定义法

!!! info "模板的声明与定义必须全部放在同一个头文件内"
    在普通类中，我们习惯于 `.h` 放声明，`.cpp` 放实现。但对于类模板和函数模板而言：

    1. **原因**：当其他源文件（如 `main.cpp`）调用模板时，编译器需要为具体的类型（如 `Vector<int>`）进行实例化。实例化要求编译器必须**同时看到模板的声明与具体实现代码**。如果实现写在 `Vector.cpp` 中，编译器在编译 `main.cpp` 时只包含了 `Vector.h`，无法获取函数体，链接时就会抛出“未定义的引用”错误。
    2. **组织方式**：将所有的模板声明与成员函数实现全部写在同一个 `.h` 头文件内。不必担心多重定义，链接器会自动去重。

---

### 编写模板的推荐步骤

不要直接开始手写模板，应当遵循以下步骤以降低调试难度：

1. **先写一个非模板的具体版本**（如专门处理 `int` 的 `Vector` 类）。
2. 编写测试用例，确保非模板类工作完全正确。
3. 对程序进行性能测试与代码审计，确定哪些类型需要被参数化。
4. **将非模板版本改造为模板类**：将所有的具体类型替换为 `T`，并在类头部声明 `template <class T>`。
5. 针对已建立的测试用例进行测试验证，修正可能存在的精确类型转换报错。
