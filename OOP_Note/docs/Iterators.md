# 迭代器与基于策略的模板设计

本节深入讲解了迭代器模式（Iterator Pattern）的解耦思想、迭代器关联类型获取难题、类型萃取（Traits）与模板偏特化技术的演进、以及现代 C++ 中用于解决对象组合爆炸的“基于策略的设计”（Policy-based Design）思想。

---

### 迭代器模式（Iterator Pattern）

#### 引入目的：容器与算法的解耦
传统的容器（如数组、链表、树）具有截然不同的内部数据结构，使得遍历逻辑完全绑定在特定容器上。
* **迭代器**：提供一种统一且抽象的接口，使得外部算法（如查找 `find`、排序 `sort`）能够在无需知晓容器内部物理实现（指针跳转细节）的前提下，按序访问容器内的各个元素。
* **接口特征**：迭代器在行为上表现得像一个指针。它重载了 `++` 运算符用于前进，重载了 `*` 和 `->` 运算符用于访问元素的值。
    ```cpp
    // 泛型find算法:容器通过一对迭代器[first, last)与算法进行通信
    template <class InputIterator, class T>
    InputIterator find(InputIterator first, InputIterator last, const T &value) {
        while (first != last && *first != value)
            ++first;
        return first;
    }
    ```

---

### 迭代器关联类型（Associated Type）与 Traits 萃取技巧

#### 关联类型获取难题
考虑编写一个泛型交换函数 `myswap`：
    ```cpp
    template <typename Iterator>
    void myswap(Iterator i, Iterator j) {
        // ??? temp = *i; // 问题：如何知道 Iterator 指向的数据类型（T）从而声明 temp？
        // *i = *j;
        // *j = temp;
    }
    ```
问题：如何知道 Iterator 指向的数据类型（T）从而声明 temp？
-
#### 方案一：模板参数自动推导包装器（Implementation Wrapper）
利用辅助函数参数的隐式推导：
    ```cpp
    template <class I, class T>
    void myswap_impl(I i, I j, T v) { // T 位置实参传递 *i，使得编译器自动推导出 T
        T tmp = *i; // 拥有类型 T 就可以定义临时变量了
        *i = *j;
        *j = tmp;
    }
    
    template <class I>
    void myswap(I i, I j) {
        myswap_impl(i, j, *i); // 委托包装调用
    }
    ```
解决了临时变量的定义，但是没解决返回值类型的问题：如果函数需要返回这个关联类型（`value_type`），或者类型在更深层嵌套中使用，包装器推导方案就无法工作了。

#### 方案二：类内声明嵌套类型（typedef）
在自定义迭代器类中显式定义关联类型名：
    ```cpp
    template <class T>
    struct myIter {
        typedef T value_type; // 内部起别名
        T* ptr;
        T& operator*() { return *ptr; }
    };
    
    template <class I>
    typename I::value_type func(I iter) { // 使用 typename 关键字指明它是类型而非静态成员
        return *iter; 
    }
    ```
解决了前两者的问题，但还有一个致命伤：**无法支持原生指针**（如 `int*`、`double*`）作为迭代器。原生指针是内置类型，内部不可能包含 `typedef` 嵌套声明。然而，STL 必须让原生指针和普通迭代器具有同等泛型调用地位。

#### 方案三：偏特化萃取技术（Traits Trick）
设计一个中介类——**类型萃取器（`iterator_traits`）**，专门用来查询迭代器的属性。
    ```cpp
    // 1. 通用模板：处理内部包含 value_type 嵌套声明的自定义迭代器
    template <class I>
    class iterator_traits {
    public:
        typedef typename I::value_type value_type;
    };
    
    // 2. 偏特化版本（Partial Specialization）：专门处理原生指针 (T*)
    template <class T>
    class iterator_traits<T*> {
    public:
        typedef T value_type; // 将指针指向的 int* 还原萃取为 int 类型
    };
    
    // 3. 偏特化版本：处理只读原生指针 (const T*)
    template <class T>
    class iterator_traits<const T*> {
    public:
        typedef T value_type; // 萃取出来的依然是可修改非 const 的 T，以便外部能定义临时变量进行交换
    };
    ```
在 STL 中，标准 `iterator_traits` 包含了 5 种核心萃取属性：

* `iterator_category`：迭代器分类（如输入、双向、随机访问等）。
* `value_type`：所指元素类型。
* `difference_type`：两个迭代器之间的距离类型。
* `pointer`：所指元素的指针类型。
* `reference`：所指元素的引用类型。

---

### 基于策略的设计（Policy-based Design）

#### 软件设计的组合爆炸问题
编写底层组件库（如智能指针 `SmartPtr`）时，需要应对极其丰富的业务场景组合：

* 线程模型：单线程（无锁） vs 多线程（有锁）。
* 检查机制：不检查 vs 强行空指针检查。
* 内存回收：引用计数法 vs 链式引用法。
为了支持这些不同的组合，若采用传统继承或实现多个具体类（如 `SingleThreadedSafeSmartPtr`、`MultiThreadedSafeSmartPtr`），会使类数量随选项增加呈**指数级爆炸**（组合冲突）。

#### 策略设计思想
将复杂类拆解为多个正交的、独立的**策略（Policies）**。

* **策略（Policy）**：规定了一组类接口规范（如包含哪些静态方法或类型定义）。
* **主类（Host Class）**：通过模板参数接受不同的策略类，并通过**继承（Inheritance）**或成员拥有的方式把这些策略组合起来，成为一个高效的“代码生成引擎”。

#### 策略类的设计实例：对象创建者策略（Creator Policy）
??? example "点击查看代码"
    ```cpp
    // 策略 1：使用 new 创建对象
    template <class T>
    struct OpNewCreator {
        static T* Create() { return new T; }
    };
    
    // 策略 2：使用 malloc + 定位 new 创建对象
    template <class T>
    struct MallocCreator {
        static T* Create() {
            void* buf = std::malloc(sizeof(T));
            return buf ? new(buf) T : nullptr;
        }
    };
    
    // 主类：WidgetManager。CreationPolicy 作为一个策略参数传入
    template <class CreationPolicy>
    class WidgetManager : public CreationPolicy {
        // ...
    };
    
    // 用户根据需求组装具体行为
    WidgetManager<OpNewCreator<Widget>> wgtManager;
    ```

#### 进阶：模板模板参数（Template Template Parameters）
在上面的例子中，用户需要手动写 `OpNewCreator<Widget>`，存在冗余指定。可以使用**模板模板参数**，让主类自己控制子对象的类型匹配：

??? example "点击查看代码"
    ```cpp
    template <template <class> class CreationPolicy> // 声明 CreationPolicy 本身是一个类模板
    class WidgetManager : public CreationPolicy<Widget> {
    public:
        void DoSomething() {
            // 主类内部可以使用相同的策略去构造其他类型的对象（如 Gadget）
            Gadget* pG = CreationPolicy<Gadget>().Create();
        }
    };
    
    // 调用端更加简洁，只需传入模板名字即可
    WidgetManager<OpNewCreator> wgtManager;
    ```

#### 策略设计的核心优势
1. **彻底消除组合爆炸**：只需编写 $N$ 个独立的策略类，就能拼装出 $2^N$ 种不同的主类行为。
2. **极高的运行效率（静态绑定）**：策略的拼装在编译期完成，不使用虚函数，不依赖动态绑定，从而彻底消除了运行期虚表查表开销。
3. **高可扩展性**：用户可以根据特定应用场景定制自己的策略类，只要符合策略接口约定，即可直接套用主类的庞大逻辑。
