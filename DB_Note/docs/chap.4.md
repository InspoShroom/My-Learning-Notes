## Intermediate SQL

### Join Expressions (连接表达式)

#### Joined Relations 综述

> 连接操作接受两个关系作为输入, 并返回另一个关系作为结果; 通常用作 FROM 子句中的子查询表达式

- **连接类型(Join Type)**

  - 定义如何处理两个关系中**没有匹配**的元组

  - 三大类型:
    - **Natural Join**: 自然连接
    - **Inner Join**: 内连接
    - **Outer Join**: 外连接

- **连接条件(Join Condition)**

  - 定义两个关系中哪些元组**匹配**, 以及结果中包含哪些属性

#### Natural Join (自然连接)

> 已在 Chap.3 中有过提及, 此处重点是**陷阱问题**

- **特点回顾:**  自动匹配所有同名属性, 结果中去除重复列

- **陷阱: 不相关同名属性被强制等值匹配**

  > **经典例子:**  查询学生姓名和他们所学的课程标题
  >
  > `from student natural join takes natural join course`
  >
  > - `student` 有属性: `ID`, `name`, `dept_name`, ...
  > - `course` 有属性: `course_id`, `title`, `dept_name`, ...
  > - **问题:** 系统除了匹配 `student.ID = takes.ID`, 还会强制匹配 `student.dept_name = course.dept_name`
  > - **后果:** 只能查到学生在**自己所在系**教的课, 跨系选课的记录会被漏掉!

- **解决方案: `JOIN ... USING(属性)`**

  > 只在指定的属性上进行连接, 避免其他同名列被强制匹配

```sql
-- 错误写法 (可能丢数据)
SELECT name, title
FROM student NATURAL JOIN takes NATURAL JOIN course;

-- 正确写法 A: 手动指定连接条件
SELECT name, title
FROM student NATURAL JOIN takes, course
WHERE takes.course_id = course.course_id;

-- 正确写法 B: 使用 JOIN...USING
SELECT name, title
FROM (student NATURAL JOIN takes) JOIN course USING (course_id);
```

#### Outer Join (外连接)

- **作用:**  是普通连接的扩展, 避免连接时因为没有匹配而**丢失数据**; 用 `null` 填充缺失部分

- **三种外连接**

  - **Left Outer Join (左外连接):** 保留**左表**所有元组, 右表没有匹配的用 null 填充
  - **Right Outer Join (右外连接):** 保留**右表**所有元组, 左表没有匹配的用 null 填充
  - **Full Outer Join (全外连接):** 左右表都保留, 两边匹配不上的都用 null 填充

  > **Inner Join (内连接):** 普通连接; 与外连接相对, 关键字 `inner` 可省略

- **SQL 示例:**

```sql
-- 左外连接
SELECT * FROM course NATURAL LEFT OUTER JOIN prereq;

-- 右外连接
SELECT * FROM course NATURAL RIGHT OUTER JOIN prereq;

-- 全外连接
SELECT * FROM course NATURAL FULL OUTER JOIN prereq;

-- 使用 ON 条件的外连接
SELECT * FROM course LEFT OUTER JOIN prereq
    ON course.course_id = prereq.course_id;

-- USING 语法同样适用
SELECT * FROM course FULL OUTER JOIN prereq USING (course_id);
```

- **JOIN...ON 与 Natural Join 的区别**

  > `course INNER JOIN prereq ON course.course_id = prereq.course_id`
  >
  > 与自然连接不同: 结果中**保留两份** `course_id` 列(两边各一列), 而自然连接会去重

---

### Views (视图)

#### 视图的概念

- **背景:**  有时并不希望所有用户都能看到整个逻辑模型(比如工资信息)

- **定义:**

  > **视图(View):** 不是概念模型的组成部分, 但作为**虚拟关系**对用户可见的关系; 即: 数据库中并没有真正存储这个关系的数据, 而是在查询时**动态计算**的

- **作用:**  提供一种机制, 向特定用户**隐藏**某些数据

#### 视图的定义与使用

- **创建视图:**

```sql
CREATE VIEW v AS <query expression>;

-- 示例: 创建隐藏薪资的教师视图
CREATE VIEW faculty AS
    SELECT ID, name, dept_name
    FROM instructor;

-- 示例: 创建带自定义列名的视图
CREATE VIEW departments_total_salary(dept_name, total_salary) AS
    SELECT dept_name, SUM(salary)
    FROM instructor
    GROUP BY dept_name;
```

- **使用视图:**  视图名可以像普通表名一样使用

```sql
-- 用视图查询
SELECT name
FROM faculty
WHERE dept_name = 'Biology';
```

- **视图定义的本质:**

  > 视图定义**不是**在创建一个新的物理关系; 而是保存了一个表达式; 查询时将表达式**替换**进去执行

#### 视图展开(View Expansion)

- **定义:**  当一个视图中又用到了另一个视图, 系统会递归地把视图展开替换成原始的基础表查询

- **视图依赖关系**

  - 视图 v1 **直接依赖** v2: v2 被用在 v1 的定义表达式中
  - 视图 v1 **依赖** v2: 存在从 v1 到 v2 的依赖路径(可以是间接的)
  - **递归视图(Recursive View):** 视图依赖于自身

- **展开逻辑:**

  ```
  repeat
      在表达式 e1 中找到任意视图关系 vi
      将 vi 替换为定义 vi 的表达式
  until e1 中不再有视图关系
  ```

  > 只要视图定义不是递归的, 此循环一定终止

#### 物化视图(Materialized Views)

- **定义:**  某些数据库系统允许视图被**物理存储**——视图定义时就创建实际的物理副本

- **问题:**  当底层关系被更新时, 物化视图的结果就会**过时**, 需要维护/更新

  > 物化视图的**维护(maintenance)**: 当底层关系更新时, 同步更新物化视图的内容

#### 视图的更新(View Update)

- **视图更新的本质:**  对视图的插入/修改/删除操作, 最终必须转换为对底层基表的操作

- **可更新视图的条件** (SQL 对 "简单视图" 才允许更新):

  - `FROM` 子句只有**一个**数据库关系
  - `SELECT` 子句只包含关系的**属性名**, 没有表达式、聚合、DISTINCT
  - 未出现在 `SELECT` 中的属性可以被置为 null
  - 没有 `GROUP BY` 或 `HAVING` 子句

- **无法更新的情况举例:**

  > 场景 1: 视图定义涉及**多表连接**, 插入时无法确定数据属于哪个关系
  >
  > 场景 2: 插入的元组不满足视图的 `WHERE` 条件——数据进入了基表, 但在视图中看不到

---

### Transactions (事务)

- **定义:**

  > **事务(Transaction):** 由一系列查询和/或更新语句组成的**工作单元**

- **事务的起止**

  - **开始:** 当第一条 SQL 语句执行时, 事务**隐式**开始
  - **结束:** 必须以以下之一结束:
    - `COMMIT WORK`: 提交; 将事务的所有更新**永久写入**数据库
    - `ROLLBACK WORK`: 回滚; **撤销**事务中所有的更新

- **原子性(Atomicity):**

  > 事务要么完全执行, 要么完全回滚, 就好像从未发生过一样

  > **eg:** 银行转账操作: A 账户扣款 + B 账户加款, 这两步必须作为一个原子单元——不能只执行其中一步

- **隔离性(Isolation):**

  > 事务与并发的其他事务相互隔离, 不互相干扰

---

### Integrity Constraints (完整性约束)

- **作用:**  防止对数据库的意外损坏, 确保对数据库的授权更改不会导致数据一致性丢失

#### 单关系上的约束

> 四类约束: `NOT NULL`, `PRIMARY KEY`, `UNIQUE`, `CHECK(P)`

- **NOT NULL 约束**

  ```sql
  name VARCHAR(20) NOT NULL
  budget NUMERIC(12, 2) NOT NULL
  ```

- **UNIQUE 约束**

  ```sql
  UNIQUE (A1, A2, ..., Am)
  ```

  > 指定属性集 (A1, ..., Am) 构成**候选码(Candidate Key)**
  >
  > 注意: 候选码的属性**允许为 null**(与主码不同)

- **CHECK 子句**

  - 作用: 指定每个元组必须满足的谓词 P

  ```sql
  -- 示例: 限制 semester 只能是特定值
  CREATE TABLE section (
      course_id VARCHAR(8),
      semester  VARCHAR(6),
      ...
      CHECK (semester IN ('Fall', 'Winter', 'Spring', 'Summer'))
  );
  ```

  - **复杂 CHECK 条件:** 谓词可以包含子查询

  ```sql
  CHECK (time_slot_id IN (SELECT time_slot_id FROM time_slot))
  ```

  > 注意: 当子查询引用的关系发生变化时, 也需要重新检查约束条件

#### 参照完整性(Referential Integrity)

> 即外码约束; 确保在一个关系中出现的值, 在另一个关系中也存在

- **级联操作(Cascading Actions):**

  > 当参照完整性约束被违反时, 默认是拒绝该操作; 也可以设置为**级联**

  ```sql
  CREATE TABLE course (
      course_id CHAR(5) PRIMARY KEY,
      dept_name VARCHAR(20),
      FOREIGN KEY (dept_name) REFERENCES department
          ON DELETE CASCADE      -- 级联删除
          ON UPDATE CASCADE,     -- 级联更新
      ...
  );
  ```

  > 除了 `CASCADE`, 还可以用 `SET NULL` 或 `SET DEFAULT`

- **事务中的约束违反:**

  > 场景: 创建一张自引用的 person 表 (mother 和 father 都引用自身 ID), 插入第一条数据时无法满足约束
  >
  > **解决方案:**
  > 1. 先插入 father 和 mother 记录, 再插入 person
  > 2. 先将 father/mother 置为 null, 插入后再更新
  > 3. 使用**延迟约束检查(defer constraint checking)**

#### Assertions (断言)

- **定义:**  一个谓词, 表达我们希望数据库**始终满足**的条件

  ```sql
  CREATE ASSERTION <assertion-name> CHECK (<predicate>);
  ```

- **例子:**

  ```sql
  -- 确保每个学生的总学分等于其通过课程的学分之和
  CREATE ASSERTION credits_earned_constraint CHECK
  (NOT EXISTS (
      SELECT ID FROM student
      WHERE tot_cred <> (
          SELECT SUM(credits)
          FROM takes NATURAL JOIN course
          WHERE student.ID = takes.ID
            AND grade IS NOT NULL
            AND grade <> 'F'
      )
  ));
  ```

  > **技巧:** `for all X, P(X)` 等价于 `not exists X such that not P(X)`

---

### SQL Data Types and Schemas (SQL 数据类型与模式)

#### 内置数据类型

- **日期时间类型**

  | 类型 | 说明 | 示例 |
  | --- | --- | --- |
  | `date` | 日期 (年-月-日) | `date '2005-7-27'` |
  | `time` | 时间 (时:分:秒) | `time '09:00:30'` |
  | `timestamp` | 日期+时间 | `timestamp '2005-7-27 09:00:30.75'` |
  | `interval` | 时间段 | `interval '1' day` |

  > interval 的特殊用法: 日期/时间值相减得到 interval; interval 可以加到日期/时间上

- **大对象类型(Large-Object Types)**

  - **blob (binary large object):** 存储大量**二进制**数据(照片、视频、CAD 文件等), 其解释由数据库系统外部的应用负责
  - **clob (character large object):** 存储大量**字符**数据

  > 当查询返回大对象时, 返回的是一个**指针**, 而不是对象本身

#### 用户自定义类型(User-Defined Types)

```sql
-- 创建自定义类型
CREATE TYPE Dollars AS NUMERIC(12, 2) FINAL;

-- 使用自定义类型
CREATE TABLE department (
    dept_name VARCHAR(20),
    building  VARCHAR(15),
    budget    Dollars
);
```

#### 域(Domains)

```sql
-- 创建域
CREATE DOMAIN person_name CHAR(20) NOT NULL;

-- 带约束的域
CREATE DOMAIN degree_level VARCHAR(10)
    CONSTRAINT degree_level_test
        CHECK (value IN ('Bachelors', 'Masters', 'Doctorate'));
```

> **类型 vs 域:**  两者相似; 但**域**可以在其上指定约束(如 `NOT NULL`), 更灵活

#### 索引(Index)

- **背景:**  很多查询只涉及表中一小部分记录, 全表扫描效率很低

- **定义:**  索引是一种**数据结构**, 允许数据库系统高效找到具有特定属性值的元组, 而无需扫描整张表

```sql
-- 创建索引
CREATE INDEX studentID_index ON student(ID);

-- 索引效果: 以下查询可以直接用索引定位, 不扫描全表
SELECT * FROM student WHERE ID = '12345';
```

---

### Authorization (授权)

#### 权限类型

- **数据操作权限**

  | 权限 | 说明 |
  | --- | --- |
  | `SELECT` | 允许读取数据 |
  | `INSERT` | 允许插入新元组 |
  | `UPDATE` | 允许修改数据 |
  | `DELETE` | 允许删除元组 |
  | `ALL PRIVILEGES` | 所有可用权限的简写 |

- **模式修改权限**

  | 权限 | 说明 |
  | --- | --- |
  | `INDEX` | 允许创建和删除索引 |
  | `RESOURCES` | 允许创建新关系 |
  | `ALTERATION` | 允许在关系中增删属性 |
  | `DROP` | 允许删除关系 |

#### 授权(GRANT)

```sql
GRANT <privilege list>
ON <relation name or view name>
TO <user list>;

-- 示例
GRANT SELECT ON instructor TO U1, U2, U3;
GRANT SELECT ON department TO Amit, Satoshi;
```

> `<user list>` 可以是:
> - 具体用户 ID
> - `PUBLIC` — 授权给所有合法用户
> - 角色(Role)

> 注意: 授予视图上的权限**不隐含**授予底层基表的权限

#### 撤销授权(REVOKE)

```sql
REVOKE <privilege list>
ON <relation name or view name>
FROM <user list>;

-- 示例
REVOKE SELECT ON branch FROM U1, U2, U3;
```

- **CASCADE vs RESTRICT**

  ```sql
  -- 级联撤销: 同时撤销依赖该权限的所有权限
  REVOKE SELECT ON department FROM Amit, Satoshi CASCADE;

  -- 限制撤销: 如果有依赖权限则拒绝撤销
  REVOKE SELECT ON department FROM Amit, Satoshi RESTRICT;
  ```

  > 所有依赖于被撤销权限的权限也会被一并撤销

#### 角色(Roles)

- **作用:**  将用户按访问权限分组, 通过角色统一管理权限

```sql
-- 创建角色
CREATE ROLE instructor;

-- 将角色赋给用户
GRANT instructor TO Amit;

-- 给角色授权
GRANT SELECT ON takes TO instructor;

-- 角色可以赋给其他角色 (角色链)
CREATE ROLE teaching_assistant;
GRANT teaching_assistant TO instructor;   -- instructor 继承 TA 的所有权限

-- 角色链示例
CREATE ROLE dean;
GRANT instructor TO dean;
GRANT dean TO Satoshi;
```

#### 视图上的授权

```sql
-- 创建视图并授权
CREATE VIEW geo_instructor AS (
    SELECT * FROM instructor WHERE dept_name = 'Geology'
);
GRANT SELECT ON geo_instructor TO geo_staff;
```

> **关键点:**
> - 视图的**创建者**必须对底层基表有 SELECT 权限, 否则创建请求会被拒绝
> - `geo_staff` 用户通过视图访问数据, 即使他对 instructor 表没有直接权限也没关系

#### 其他授权特性

- **外码引用权限:**

  ```sql
  -- 允许 Mariano 在 taken 表中创建引用 department.dept_name 的外码
  GRANT REFERENCE (dept_name) ON department TO Mariano;
  ```

  > 为什么需要这个? 因为创建外码约束实际上限制了被引用表的删除操作, 需要特别授权

- **权限转让(WITH GRANT OPTION):**

  ```sql
  -- 允许 Amit 将自己的 SELECT 权限再授予其他人
  GRANT SELECT ON department TO Amit WITH GRANT OPTION;
  ```
