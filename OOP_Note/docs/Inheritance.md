# 内联函数、对象组合与继承基础

第六节系统阐述了 C++ 代码复用的三种核心机制：内联函数（Inline）、对象组合（Composition）与类继承（Inheritance）的基本语法、构造/析构链及访问控制规则。

---

### 内联函数（Inline Functions）

#### 函数调用的系统开销（Overhead）
在 C++ 中，普通函数调用会带来一定的系统级时间与空间开销：

1. 参数压栈（Push parameters）。
2. 保存返回地址（Push return address）。
3. 执行跳转指令，开辟函数栈帧并执行函数体。
4. 清理栈帧，恢复调用处上下文（Pop all pushed）。

#### 内联的运行机制
**内联函数**在编译时，由编译器将函数体直接在调用处原地展开<u>（类似宏替换）</u>，从而彻底消除函数调用的跳转与压栈开销。

* **定义规则**：内联函数的定义/实现必须放在**头文件**中。
* **底层原理**：在 C++ 中，多处定义同名普通函数会导致链接器抛出“重定义（Multiple Definition）”错误。但 `inline` 关键字会向链接器发出特殊指示：“此函数为内联展开，如果在多个 `.obj` 文件中看到其函数体，请视作同一份，不要报错。”

#### 空间与时间的权衡（Tradeoff）

* **优点**：消除函数调用开销，提高运行速度。且与宏相比，内联是真正的函数，拥有严格的类型检查（Type Checking）并遵循类作用域规则，非常安全。
* **缺点**：会导致**代码膨胀（Code Bloat）**。若内联函数体较长并在多处调用，会显著增大可执行程序（`.exe`）的体积。
* **编译器可能拒绝内联**：`inline` 只是对编译器的建议，而非强制命令。如果函数体过大（如超过 20 行）、包含循环/复杂的 `switch` 分支，或者是递归函数，编译器会自动拒绝内联。
* **自动内联**：<u>在类声明内部直接编写函数体的成员函数，会被编译器自动视作内联函数。</u>

---

### 对象组合（Composition）

#### 组合的概念与 "Has-A" 关系
组合是指在新类中嵌入已存在类的对象作为成员变量，以构建更复杂的对象。它表达的是 **"Has-A"（拥有）** 的逻辑关系（例如：汽车拥有引擎与轮胎）。

* **包含方式**：
    * 完全包含（Fully）：子对象是新类的一部分，生命周期完全受控于新类。
    * 引用/指针包含（By reference）：新类仅保存子对象的指针或引用，可以实现多个类对象共享同一子对象。

#### 构造初始化与任务委托（Delegation）
* **嵌入对象初始化**：嵌入的成员对象必须被初始化。如果不在新类的初始化列表中显式指定其构造参数，编译器将自动调用其默认构造函数（无默认构造函数将报错）。
* **效率对比（初始化 vs 赋值）**：

    ??? example "点击查看代码"
        ```cpp
        // 1. 效率低下：在构造函数体内赋值（m_saver 已经先经历了一次默认构造）
        SavingsAccount::SavingsAccount(const char* name, int cents) {
            m_saver.set_name(name);
            m_balance.set_cents(cents);
        }
        
        // 2. 高效：在初始化列表中直接构造（只经历一次带参构造，更安全且快）
        SavingsAccount::SavingsAccount(const char* name, int cents) 
            : m_saver(name), m_balance(cents) {}
        ```

* **任务委托**：大对象在执行操作时，通常将具体动作委派给其内部的嵌入对象执行（如调用 `SavingsAccount::print()` 实则在内部调用 `m_saver.print()`）。

---

### 类继承基础（Inheritance）

#### 继承的概念与 "Is-A" 关系
继承允许子类/派生类（Derived Class）克隆并扩展基类（Base Class）的属性、方法和接口。它表达的是 **"Is-A"（是一个）** 的逻辑关系（例如：学生是一个人；圆形是一个图形）。

* **超集（Superset）**：从集合论角度，子类包含了父类的所有属性和行为，并在此基础上进行了扩充，因此**子类是父类的超集**。

#### DoME 多媒体数据库案例批判
* 重构前设计：CD 类与 DVD 类作为独立类并排存在，它们有 80% 的字段（标题、时长、备注、got-it）和打印函数完全重复。管理它们的 Database 类中也充斥着双份的容器列表、双份的 `add` 方法和双份的循环打印。
* 带来的问题：代码大量冗余，不易维护，添加新媒体类型（如 VideoGame）时需要对系统进行大改，极易引入 Bug。
* 继承重构方案：提取出通用的基类 `Item`，将公共属性（title, playingTime 等）和 `print()` 接口移入其中。让 CD 和 DVD 继承 `Item`，数据库只需维护 `ArrayList<Item>`，从而完全消除了冗余，提高了系统的可扩展性。

#### 继承与访问控制权限
C++ 提供了三种成员访问控制修饰符：
1. `public`：对外部客户端和子类均可见。
2. `protected`：对外部客户端隐藏，但**对子类可见**（留给子类的家族遗产）。
3. `private`：仅对当前类自身可见，子类亦无法直接访问。

!!! tip "Protected 的安全隐患"
    `protected` 虽然为子类访问父类数据提供了便利，但它对于所有派生类来说等同于 `public`，如果派生类行为不端，极易破坏父类的数据封装。因此，在工业界开发中，通常推荐**将成员变量保持为 `private`，而将成员函数/接口声明为 `protected`**。

#### 继承中的构造与析构链
* **构造顺序**：**基类（父类）总是最先被构造**，然后构造子类的特有部分。
  * 子类构造函数必须在**初始化列表**中显式调用基类构造函数（如 `Manager::Manager(...) : Employee(name, ssn), m_title(title) {}`）。若未写明，编译器将尝试调用基类的默认无参构造函数。
* **析构顺序**：析构的顺序与构造**完全相反**——先析构子类，再自动析构父类。

#### 无法被继承的类成员
以下类成员**不会**被子类自动继承，必须由子类自行实现或显式调用：

1. 构造函数与析构函数。
2. 拷贝构造函数与拷贝赋值运算符（`operator=`）。

---

### 继承下的名称隐藏（Name Hiding）

* **定义**：如果在派生类中重新定义了与基类同名的成员函数，那么**基类中所有其他同名重载函数在子类作用域中都将变得不可直接访问**。
* **案例分析**：

    ??? example "点击查看代码"
        ```cpp
        class Employee {
        public:
            void print(ostream& out) const;
            void print(ostream& out, const string& msg) const; // 重载版本
        };
        
        class Manager : public Employee {
        public:
            void print(ostream& out) const; // 仅重定义了无参数消息的 print
        };
        
        Manager bill;
        bill.print(cout, "Message:"); // ERROR！Employee::print(ostream&, const string&) 已在子类作用域被隐藏
        ```
* **解决隐藏的方法**：在派生类中使用 `using Employee::print;` 声明，显式将父类同名重载函数引入子类作用域。

---

### 继承类型对可访问性的影响（三种继承方式）

派生类在声明继承时（如 `class B : public A`），不同的继承修饰符会改变基类成员在派生类中的最终访问级别：

| 基类成员访问修饰符 | 公有继承（`public`）后的访问级别 | 保护继承（`protected`）后的访问级别 | 私有继承（`private`，默认）后的访问级别 |
| :--- | :--- | :--- | :--- |
| **`public`** | `public` (对外部和子类可见) | `protected` (仅子类及子孙类可见) | `private` (仅子类内部可见) |
| **`protected`** | `protected` (仅子类可见) | `protected` (仅子类及子孙类可见) | `private` (仅子类内部可见) |
| **`private`** | `hidden` (隐藏，子类不可访问) | `hidden` (隐藏，子类不可访问) | `hidden` (隐藏，子类不可访问) |

---

### C++ 常用容器与 STL 基础

在后半部分，专门对 C++ 中的标准模板库（STL）常用容器、迭代器、常见算法及性能陷阱进行了详细讲解。

#### 常用容器与核心语法

##### ① 动态数组 Vector
* **概念**：连续内存存储的动态数组，支持随机访问。
* **两种常用方式**：
    * 预分配（Preallocate）：`vector<int> v(100);`。提前分好空间，可通过下标直接修改元素。注意：下标访问必须在已分配范围内（如访问 `v[200]` 会造成越界）。
    * 尾部动态增长：`vector<int> v2;`。初始为空，使用 `push_back(val)` 动态向尾部追加，容器会自动按需扩容。
* **经典陷阱**：对空 vector 直接通过下标赋值 `v[100] = 1;` 属于**越界访问（Undefined Behavior）**。必须使用 `push_back()` 或提前调用 `reserve()` / `resize()`。

##### ② 映射表 Map
* **概念**：提供键-值对（Key-Value）映射的关联容器，内部基于红黑树实现，键值有序。
* **语法示例**：

    ??? example "点击查看 Map 基础使用代码"
        ```cpp
        #include <map>
        #include <string>
        
        std::map<std::string, float> price;
        price["snapple"] = 0.75;
        price["coke"] = 0.50;
        
        std::string item;
        double total = 0;
        while (std::cin >> item) {
            total += price[item];
        }
        ```
        
* **隐式插入陷阱**：在 Map 中，使用 `price["bob"]` 访问一个**不存在的键**时，Map 会**自动且默默地插入**该键并将其值初始化为默认值（如 `0.0`）。
* **解决方案**：如果只想查找或验证键是否存在，而不希望改变 Map，应使用 `count()` 方法进行预检：

    ??? example "点击查看 Map 安全查询代码"
        ```cpp
        if (price.count("bob")) {
            price["bob"] = 1.0;
        }
        ```

##### ③ 双向链表 List
* **概念**：双向链表，支持在任意位置进行快速插入与删除，不支持随机访问。
* **元素删除**：`L.erase(++L.begin());` 可删除链表中的第二个元素。
* **高效打印（`std::copy` 与流迭代器）**：

    ??? example "点击查看 List 操作及高级打印代码"
        ```cpp
        #include <list>
        #include <algorithm>
        #include <iterator>
        #include <iostream>
        
        std::list<int> L;
        for (int i = 1; i <= 5; ++i) {
            L.push_back(i);
        }
        
        // 删除第二个元素（即数字 2）
        L.erase(++L.begin());
        
        // 使用 std::copy 将链表数据直接拷贝到标准输出流 ostream_iterator，每个数字后跟一个逗号分隔符
        std::copy(L.begin(), L.end(), std::ostream_iterator<int>(std::cout, ","));
        // 最终输出: 1,3,4,5,
        ```

#### 迭代器（Iterators）与算法

* **迭代器的本质**：迭代器可以看作是“智能指针”，是容器与算法之间的桥梁。
  * `L.begin()` 返回指向容器中第一个元素的迭代器。
  * `L.end()` 返回指向容器**最后一个元素之后**位置的迭代器（哨兵位置，不可解引用）。
  * 通过 `++li` 递增指向下一元素；通过 `*li` 解引用来读取或修改数据。
* **算法跨容器操作**：STL 算法不直接操作容器，而是接受迭代器范围。例如：

    ??? example "点击查看跨容器拷贝代码"
        ```cpp
        std::list<int> L;
        std::vector<int> V(5);
        // 通过迭代器将 list 里的全部数据复制到 vector 中
        std::copy(L.begin(), L.end(), V.begin());
        ```

* **迭代器失效陷阱**：擦除元素后，指向被擦除位置的迭代器将失效，此时对其执行 `++` 或解引用会导致崩溃。

    ??? example "点击查看迭代器擦除避坑代码"
        ```cpp
        // ❌ 错误做法：li 被删除后失效，++li 会导致崩溃
        L.erase(li);
        ++li;
        
        // ✅ 正确做法：利用 erase 的返回值（返回指向被删除元素下一个位置的有效迭代器）
        li = L.erase(li);
        ```

#### 3. STL 容器对自定义类型的要求

如果您想把自定义的 `struct` 或 `class` 存入 STL 容器中，必须满足以下条件：

* **基础要求**：自定义类型必须支持**默认构造函数**（用于容器内部元素创建）与**赋值运算符 `operator=`**（用于拷贝和移动）。
* **有序容器要求（如 Map, Set）**：容器需要对元素进行排序，因此自定义类型**必须重载小于运算符 `operator<`**。

    ??? example "点击查看自定义排序结构体代码"
        ```cpp
        struct full_name {
            char* first;
            char* last;
            
            // 重载小于运算符
            bool operator<(const full_name& a) const {
                return strcmp(first, a.first) < 0;
            }
        };
        
        std::map<full_name, int> phonebook;
        ```

#### 4. 性能分析与工程实践

* 手写实现 vs STL 容器：
    * 案例 1（Deque 双端队列）：虽然手写优化的“循环缓冲区数组”在特定场景下可能比 STL 的 `std::deque` 快约 40%，但手写会耗费数天时间用于调试和处理复杂的边界问题。在现代开发中，非极端场景通常**不值得**手写。
    * 案例 2（List 链表）：手写“侵入式链表”（Intrusive List，即指针 `next` 直接写在结构体内部）通常比 `std::list` 快 5% 左右，且减少了内存分配次数。但侵入式链表有一个致命缺陷：**一个对象节点同一时间只能被加入到一个链表中**，而 STL 容器允许同一对象存在于多个不同列表中。
* 判断容器为空的效率陷阱：
    * ❌ 错误写法：`if (my_list.size() == 0)`。在某些老旧的 C++ 编译器和标准库实现中，`size()` 需要遍历整个链表，时间复杂度是 $O(N)$。
    * **✅ 正确写法**：`if (my_list.empty())`。在所有 C++ 标准和所有容器中，`empty()` 的复杂度始终是固定的 **$O(1)$**，速度极快。

#### 5. 常见编译错误与其它数据结构

* **双层模板嵌套的空格问题（C++11 之前）**：
    * 在老版本 C++ 编译器中，`vector<vector<int>>` 尾部的两个 `>` 会被词法分析器误当成右移运算符 `>>` 从而报错。必须写成 `vector<vector<int> >`（中间加空格）。*注：C++11 及以后的标准已彻底修复此问题。*
* **其它常用 STL 数据结构**：
    * **关联容器**：`set`（集合）、`multiset`（允许重复元素的集合）、`multimap`（允许一个 Key 映射多个 Value）。
    * **容器适配器**：`queue`（普通队列）、`priority_queue`（优先队列，底层为堆）、`stack`（栈）。
    * **特殊容器**：`deque`（双端队列）、`bitset`（高效二进制位操作位图）、`valarray`（用于数学向量的高效科学计算数组）。
