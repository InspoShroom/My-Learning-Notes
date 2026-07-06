# 运算符重载与类型转换

第八节深入讲解了 C++ 运算符重载的基本语法与规则限制、成员重载与全局重载的设计取舍、经典自增自减与输入输出流的重载实现、类赋值运算符（`operator=`）、隐式/显式类型转换、以及 C++ 四种标准类型强转转换运算符（Casts）。

---

### 运算符重载的基本规则与限制

#### 目的
允许用户自定义类型表现得像内置类型一样（如直接对两个类对象进行加减 `a + b`），提高代码的可读性与维护性。它本质上是另一种形式的函数调用。

#### 允许重载的运算符
C++ 几乎允许重载所有的单目和双目运算符（如 `+ - * / % ++ -- == [] -> () new delete` 等）。

#### 禁止重载的运算符
以下 5 个运算符在 C++ 中禁止被重载：

* **成员访问运算符**：`.`
* **成员指针访问运算符**：`.*`
* **作用域解析运算符**：`::`
* **条件三目运算符**：`?:`
* **字节大小运算符**：`sizeof`

此外，类型信息运算符 `typeid` 和四种 Casts 强转关键字也无法被重载。

#### 语法规则约束
1. **不能创造新符号**：例如不能重载 `**` 来表示乘方。
2. **必须包含自定义类型**：重载的操作数中必须至少有一个是类（`class`/`struct`）或枚举（`enum`）类型，不能修改内置基本类型（如 `int + int`）的语义。
3. **保留运算数个数**：单目运算符重载后仍为单目，双目仍为双目。
4. **保留优先级与结合性**：例如重载的 `*` 优先级依然高于 `+`。

---

### 成员函数重载 vs 全局函数重载

运算符重载可以通过类成员函数实现，也可以通过非成员的全局自由函数（常声明为友元 `friend`）实现。

??? example "点击查看代码"
    ```cpp
    // 1. 成员函数重载方式
    class String {
    public:
        const String operator+(const String& that) const; // 隐式包含第一个参数（this）
    };
    
    // 2. 全局函数重载方式
    const String operator+(const String& lhs, const String& rhs); // 两个参数都显式声明
    ```

#### 两者的设计取舍

| 特性 | 成员函数重载 | 全局自由函数重载 |
| :--- | :--- | :--- |
| 参数匹配 | 第一个参数为隐式的 `*this` 指针 | 所有参数均为显式参数 |
| 左操作数类型转换 | **不对左操作数进行任何隐式类型转换**。例如 `x + 3` 可运行，但 `3 + x` 会报错，因为 `3` 不是该类对象，无法调用成员 `operator+` | **对左右操作数均可进行隐式类型转换**。例如 `3 + x` 能够将 `3` 隐式构造为类对象，实现对称调用 |
| 访问控制 | 天然拥有访问私有成员的权限 | 通常需在类中声明为 `friend` 才能访问私有数据 |

#### 重载选择指南
* **必须作为成员函数重载**的 4 个运算符：`=`（赋值）、`()`（函数调用）、`[]`（下标访问）、`->`（指针成员访问）。
* **推荐作为成员函数重载**：单目运算符（如 `-`、`!`、`++`、`--`）以及复合赋值运算符（如 `+=`、`-=`）。
* **推荐作为全局自由函数重载**：其他所有的对称双目运算符（如 `+`、`-`、`*`、`/`、`==`、`<` 等），以便允许左右操作数进行对称的隐式类型转换。

---

### 典型运算符重载实例

#### 1. 前/后置自增/自减（`++` 和 `--`）
* **前后置区分方式**：后置形式在形参列表中多出一个无用的占位符 `int` 参数。当调用后置形式时，编译器会自动传入 `0`。
* 代码示例：
        ```cpp
        class Integer {
            int i;
        public:
            // 前置: ++x 递增对象并返回其引用.无拷贝开销,效率高
            const Integer& operator++() {
                i += 1;
                return *this;
            }
            // 后置: x++ 保存旧值副本,递增原对象.返回旧值副本,有拷贝开销.
            const Integer operator++(int) {
                Integer old(*this); // 保存副本
                ++(*this);          // 调用前置自增
                return old;         // 返回副本
            }
        };
        ```

#### 2. 关系运算符（`==`, `!=`, `<`, `>` 等）
* 为了减少逻辑冗余和潜在的不一致 Bug，应当只实现核心运算符（如 `==` 和 `<`），其他运算符均调用核心运算符来实现
* 代码示例：
        ```cpp
        class Point {
            int x, y;
        public:
            Point(int x = 0, int y = 0) : x(x), y(y) {}

            // 核心运算符: ==
            bool operator==(const Point& rhs) const {
                return x == rhs.x && y == rhs.y;
            }

            // 核心运算符: <
            bool operator<(const Point& rhs) const {
                if (x != rhs.x) return x < rhs.x;
                return y < rhs.y;
            }

            // 其他关系运算符均通过调用 == 和 < 实现
            bool operator!=(const Point& rhs) const {
                return !(*this == rhs); // 调用 operator==
            }
            bool operator>(const Point& rhs) const {
                return rhs < *this;     // 调用 operator<
            }
            bool operator<=(const Point& rhs) const {
                return !(rhs < *this);  // 调用 operator<
            }
            bool operator>=(const Point& rhs) const {
                return !(*this < rhs);  // 调用 operator<
            }
        };
        ```

#### 3. 下标运算符 `operator[]`
* 必须是成员函数。
* 规则：通常需要返回元素的**引用**，以便对象可以像普通数组一样支持左值赋值（如 `v[10] = 45;`）。
* 代码示例：
    ??? example "点击查看下标运算符重载代码"
        ```cpp
        class Array {
            int data[10];
        public:
            // 1. 非 const 版本：返回元素的引用，允许作为左值被修改（如 a[0] = 5;）
            int& operator[](int index) {
                return data[index];
            }

            // 2. const 版本：返回常引用或副本，仅允许只读访问 const Array 对象
            const int& operator[](int index) const {
                return data[index];
            }
        };
        ```

#### 4. 赋值运算符 `operator=`
* 必须是成员函数。如果未手动实现，编译器会自动生成默认版本（进行逐成员赋值）。
* 编写防线：
    1. 必须检查**自赋值**（Self-assignment），对比物理地址 `this != &rhs`。
    2. 释放原对象占用的动态内存，重新分配并深拷贝数据。
    3. **返回 `*this` 的引用**：以支持 C++ 标准的链式赋值（如 `A = B = C;`）。
* *注：如果类内部包含动态内存分配，必须显式重载 `operator=`，或者将其声明为 `private` 锁死以禁止赋值。*
* **代码示例**：
    ??? example "点击查看赋值运算符重载代码"
        ```cpp
        class IntArray {
            int* data;
            int size;
        public:
            IntArray(int sz) : size(sz), data(new int[sz]) {}
            ~IntArray() { delete[] data; }

            // 拷贝构造函数 (作为对比)
            IntArray(const IntArray& other) : size(other.size), data(new int[other.size]) {
                for (int i = 0; i < size; ++i) {
                    data[i] = other.data[i];
                }
            }

            // 重载赋值运算符 (operator=)
            IntArray& operator=(const IntArray& rhs) {
                // 1. 防御第一线：检查自赋值 (对比物理地址)
                if (this == &rhs) {
                    return *this;
                }

                // 2. 防御第二线：释放原有的堆内存
                delete[] data;

                // 3. 防御第三线：根据新尺寸重新申请空间并深拷贝
                size = rhs.size;
                data = new int[size];
                for (int i = 0; i < size; ++i) {
                    data[i] = rhs.data[i];
                }

                // 4. 防御第四线：返回 *this 的引用以支持链式赋值
                return *this;
            }
        };
        ```

#### 5. 输入输出流重载（`operator<<` 和 `operator>>`）
* **必须作为全局自由函数重载**。因为 `<<` 的左操作数是 `std::ostream`，而我们无法修改标准库类。
* **实现规范**：
        ```cpp
        // 输出流重载
        ostream& operator<<(ostream& os, const MyClass& obj) {
            os << obj.data;
            return os; // 必须返回 ostream& 引用以支持链式输出 (cout << a << b)
        }
        ```

---

### 用户自定义类型转换

编译器在进行隐式类型转换时，会尝试利用以下两种类内部的定义：

#### 1. 单参数构造函数（或带默认参数的构造函数）
* **作用**：将源类型（如 `string`）隐式转换为目标类对象。
* **防止隐式强转**：在构造函数前加上 **`explicit`** 关键字。这样该构造函数只能用于显式构造（如 `PathName xyz(abc);`），而禁止了任何隐式的赋值强转（如 `xyz = abc;` 将报错）。

#### 2. 自定义类型转换操作符
* **语法**：`X::operator T() const;`（**无返回值类型声明**，且参数列表为空，函数名即为转换的目标类型 `T`）。
* **示例**：

    ??? example "点击查看代码"
        ```cpp
        class Rational {
        public:
            operator double() const { return num / (double)den; } // 将 Rational 隐式转换为 double
        };
        ```
!!! warning "尽量避免使用类型转换操作符"
    隐式类型转换经常会导致编译器在解析重载函数时发生意料之外的隐式转换和二义性错误。推荐使用显式的成员转换函数代替（例如写一个 `double toDouble() const` 函数）。

---

### C++ 标准四种 Casts 强转运算符

C++ 抛弃了 C 语言危险、粗暴的圆括号强转 `(Type)val`，引入了四种职责划分极其明确的 Cast 运算符：

#### 1. `static_cast<Type>(expr)`
* 职责：**静态类型转换**。用于编译器认可的隐式安全转换的显式化（如 `char` 转 `int`，非 const 转 const，`double` 转 `int` 截断）。
* 限制：**无法去除 const 属性**；在进行类指针的向下转型（Downcast，父类指针转子类指针）时是不安全的，因为没有运行期安全检查。

#### 2. `dynamic_cast<Type>(expr)`
* 职责：**动态类型转换**。用于**多态继承体系下指针或引用的安全向下转型**。
* 原理：在运行期查询对象的 RTTI（运行期类型信息）。如果转型是安全的，则成功转型；如果不安全（如把真正的父类对象转为子类指针），**则会返回 `nullptr`**（对引用强转失败会抛出异常）。
* 限制：要求被转型的基类中**必须至少包含一个虚函数**。

#### 3. `const_cast<Type>(expr)`
* 职责：**专门用于添加或去除指针/引用的 `const` 或 `volatile` 属性**。
* 限制：这是 C++ 中唯一能够去除只读属性的转换器，其目标类型必须是指针或引用。

#### 4. `reinterpret_cast<Type>(expr)`
* 职责：**重新解释转换**。对内存中的二进制位进行直接的、粗暴的重新解释（例如把指针直接解释为整数，或把一个类型的指针强转为另一个毫无关联的指针）。
* 限制：极为危险，不具备任何可移植性，只在底层硬件开发或特定指针运算时使用。
