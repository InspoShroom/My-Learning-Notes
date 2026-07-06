## Advanced SQL

### Accessing SQL From a Programming Language

#### 为什么需要从编程语言访问 SQL

- **SQL 的局限性:**  SQL 不能提供通用编程语言的完整表达能力
  - 无法实现打印报告、与用户交互、将结果发送给 GUI 等**非声明式操作**

- **两种访问方式:**

  | 方式 | 说明 |
  | --- | --- |
  | **Dynamic SQL (动态 SQL)** | 通用程序通过函数调用集合连接数据库并发送 SQL; 代表: **JDBC**, **ODBC** |
  | **Embedded SQL (嵌入式 SQL)** | 将 SQL 语句直接嵌入宿主语言; 编译时翻译为函数调用, 运行时通过 API 连接 |

---

### JDBC (Java Database Connectivity)

- **定义:**  用于 Java 程序与支持 SQL 的数据库系统进行通信的 Java API

- **工作模型:**

  ```mermaid
  graph LR
  A[Open Connection] --> B[Create Statement Object] --> C[Execute Queries/Updates] --> D[Handle Results]
  ```

#### 基本 JDBC 代码结构

```java
// Java 7+ 写法 (try-with-resources, 自动关闭资源)
public static void JDBCexample(String dbid, String userid, String passwd) {
    try (Connection conn = DriverManager.getConnection(
             "jdbc:oracle:thin:@db.yale.edu:2000:univdb", userid, passwd);
         Statement stmt = conn.createStatement()) {
        // 执行更新
        stmt.executeUpdate("INSERT INTO instructor VALUES('77987', 'Kim', 'Physics', 98000)");

        // 执行查询并处理结果
        ResultSet rset = stmt.executeQuery(
            "SELECT dept_name, AVG(salary) FROM instructor GROUP BY dept_name");
        while (rset.next()) {
            System.out.println(rset.getString("dept_name") + " " + rset.getFloat(2));
        }
    } catch (SQLException sqle) {
        System.out.println("SQLException: " + sqle);
    }
}
```

#### Prepared Statement (预处理语句)

- **作用:**  预先编译 SQL 语句, 然后用参数填充执行; 可以高效地重复执行

```java
PreparedStatement pStmt = conn.prepareStatement(
    "INSERT INTO instructor VALUES(?, ?, ?, ?)");
pStmt.setString(1, "88877");
pStmt.setString(2, "Perry");
pStmt.setString(3, "Finance");
pStmt.setInt(4, 125000);
pStmt.executeUpdate();
```

- **⚠️ SQL 注入(SQL Injection)**

  > **永远不要**通过字符串拼接来构造包含用户输入的 SQL 语句!
  >
  > 假设查询是: `"SELECT * FROM instructor WHERE name = '" + name + "'"`
  >
  > 如果用户输入: `X' OR 'Y' = 'Y`
  >
  > 则拼接后变为: `SELECT * FROM instructor WHERE name = 'X' OR 'Y' = 'Y'` —— 可以查看所有记录!
  >
  > 更糟糕: `X'; UPDATE instructor SET salary = salary + 10000; --`
  >
  > **解决方案: 始终使用 Prepared Statement, 将用户输入作为参数传入**

#### Metadata (元数据)

- **ResultSet 元数据:**  查询结果的结构信息

  ```java
  ResultSetMetaData rsmd = rs.getMetaData();
  for (int i = 1; i <= rsmd.getColumnCount(); i++) {
      System.out.println(rsmd.getColumnName(i));
      System.out.println(rsmd.getColumnTypeName(i));
  }
  ```

- **Database 元数据:**  数据库的结构信息(表名、列名、主键等)

  ```java
  DatabaseMetaData dbmd = conn.getMetaData();
  ResultSet rs = dbmd.getColumns(null, "univdb", "department", "%");
  while (rs.next()) {
      System.out.println(rs.getString("COLUMN_NAME") + rs.getString("TYPE_NAME"));
  }
  ```

#### JDBC 事务控制

```java
// 默认每条语句自动提交 (Auto-commit)
// 关闭自动提交 (多步更新时必须关闭)
conn.setAutoCommit(false);

// 手动提交或回滚
conn.commit();
conn.rollback();

// 重新开启自动提交
conn.setAutoCommit(true);
```

---

### ODBC (Open Database Connectivity)

- **定义:**  开放数据库连接标准; 应用程序通过标准 API 与数据库服务器通信, 最初为 C/Basic 定义

- **工作机制:**  每个支持 ODBC 的数据库系统提供一个**驱动库(driver)**, 客户端程序与之链接

- **ADO.NET:**  微软为 Visual Basic .NET 和 C# 设计的 API, 功能类似 JDBC/ODBC

  ```csharp
  // C# ADO.NET 示例
  SqlConnection conn = new SqlConnection("Data Source=<IPaddr>, Initial Catalog=<Catalog>");
  conn.Open();
  SqlCommand cmd = new SqlCommand("SELECT * FROM students", conn);
  SqlDataReader rdr = cmd.ExecuteReader();
  while (rdr.Read()) {
      Console.WriteLine(rdr[0], rdr[1]);
  }
  rdr.Close(); conn.Close();
  ```

---

### Embedded SQL (嵌入式 SQL)

- **定义:**  将 SQL 查询直接嵌入宿主语言(C, C++, Java, Fortran 等)的一种方式

- **宿主语言(Host Language):**  被嵌入 SQL 的编程语言

- **标识符:**  使用 `EXEC SQL` 标识嵌入 SQL 请求

  ```sql
  EXEC SQL <embedded SQL statement>;
  ```

- **宿主变量:**  宿主语言的变量在嵌入 SQL 中使用, 前面加**冒号 `:`** 以区分 SQL 变量

  ```c
  EXEC SQL BEGIN DECLARE SECTION;
      int credit_amount;
  EXEC SQL END DECLARE SECTION;
  ```

#### 游标(Cursor)

> 游标用于在嵌入式 SQL 中处理查询结果, 允许逐行遍历结果集

```sql
-- 1. 声明游标
EXEC SQL
    DECLARE c CURSOR FOR
        SELECT ID, name
        FROM student
        WHERE tot_cred > :credit_amount;
END_EXEC

-- 2. 打开游标 (此时执行查询, 保存到临时关系)
EXEC SQL OPEN c;

-- 3. 逐行获取 (fetch 一次取一行到宿主变量)
EXEC SQL FETCH c INTO :si, :sn END_EXEC
-- SQLSTATE = '02000' 时表示没有更多数据

-- 4. 关闭游标
EXEC SQL CLOSE c;
```

- **通过游标更新数据:**

  ```sql
  -- 声明 for update 的游标
  EXEC SQL
      DECLARE c CURSOR FOR
          SELECT * FROM instructor
          WHERE dept_name = 'Music'
          FOR UPDATE;
  
  -- 更新当前游标指向的行
  EXEC SQL
      UPDATE instructor
      SET salary = salary + 100
      WHERE CURRENT OF c;
  ```

---

### Functions and Procedures (函数与过程)

- **作用:**  将"业务逻辑"存储在数据库中, 可以从 SQL 语句中调用

- **定义方式:**  可以用 SQL 的过程化组件定义, 也可以用外部语言(Java, C, C++)定义

#### SQL 函数

```sql
-- 定义函数: 给定系名, 返回该系的教师数量
CREATE FUNCTION dept_count(dept_name VARCHAR(20))
    RETURNS INTEGER
    BEGIN
        DECLARE d_count INTEGER;
        SELECT COUNT(*) INTO d_count
        FROM instructor
        WHERE instructor.dept_name = dept_name;
        RETURN d_count;
    END

-- 使用函数
SELECT dept_name, budget
FROM department
WHERE dept_count(dept_name) > 12;
```

- **表函数(Table Functions):**  返回值是一个**表**的函数

  ```sql
  CREATE FUNCTION instructor_of(dept_name CHAR(20))
      RETURNS TABLE (
          ID        VARCHAR(5),
          name      VARCHAR(20),
          dept_name VARCHAR(20),
          salary    NUMERIC(8, 2)
      )
      RETURN TABLE (
          SELECT ID, name, dept_name, salary
          FROM instructor
          WHERE instructor.dept_name = instructor_of.dept_name
      );
  
  -- 使用
  SELECT * FROM TABLE(instructor_of('Music'));
  ```

#### SQL 过程

- **函数 vs 过程的区别:**  函数有返回值; 过程通过 `in/out` 参数传递输入输出

```sql
-- 定义过程
CREATE PROCEDURE dept_count_proc(
    IN  dept_name VARCHAR(20),
    OUT d_count   INTEGER
)
BEGIN
    SELECT COUNT(*) INTO d_count
    FROM instructor
    WHERE instructor.dept_name = dept_count_proc.dept_name;
END

-- 调用过程
DECLARE d_count INTEGER;
CALL dept_count_proc('Physics', d_count);
```

> **名称重载(Overloading):** SQL:1999 允许同名函数/过程, 只要参数数量或类型不同即可

#### 过程化编程结构

```sql
-- 复合语句 (begin...end)
BEGIN
    DECLARE n INTEGER DEFAULT 0;
    -- while 循环
    WHILE n < 10 DO
        SET n = n + 1;
    END WHILE;
    -- repeat 循环 (先执行后判断)
    REPEAT
        SET n = n - 1;
    UNTIL n = 0
    END REPEAT;
END

-- for 循环 (遍历查询结果)
DECLARE n INTEGER DEFAULT 0;
FOR r AS
    SELECT budget FROM department
DO
    SET n = n + r.budget;
END FOR;

-- 条件语句
IF ... THEN ...
ELSEIF ... THEN ...
ELSE ...
END IF;

-- 异常处理
DECLARE out_of_classroom_seats CONDITION;
DECLARE EXIT HANDLER FOR out_of_classroom_seats
BEGIN
    ...
    SIGNAL out_of_classroom_seats;
END;
```

#### 外部语言函数/过程

```sql
-- 用 C 语言定义过程
CREATE PROCEDURE dept_count_proc(IN dept_name VARCHAR(20), OUT count INTEGER)
    LANGUAGE C
    EXTERNAL NAME '/usr/avi/bin/dept_count_proc';

-- 用 C 语言定义函数
CREATE FUNCTION dept_count(dept_name VARCHAR(20))
    RETURNS INTEGER
    LANGUAGE C
    EXTERNAL NAME '/usr/avi/bin/dept_count';
```

- **优点:**  更高效, 表达能力更强
- **缺点:**  安全风险(可能破坏数据库结构或访问未授权数据)

- **安全解决方案:**

  1. 使用**沙箱(Sandbox)**技术: 使用安全语言(如 Java)
  2. 在**独立进程**中运行外部函数, 通过进程间通信传递参数和结果

  > 两种方案都有性能开销; 许多数据库系统同时支持以上两种方案以及直接在数据库地址空间执行

---

### Triggers (触发器)

#### 触发器的概念

- **定义:**

  > **触发器(Trigger):** 当数据库发生特定修改时, 系统**自动**执行的语句; 是数据库修改的**副作用**

- **设计触发器需要明确两件事:**
  1. 触发器在什么**条件**下执行 (When?)
  2. 触发器执行什么**动作** (What?)

#### 触发器示例

- **场景:** `time_slot_id` 不是 `time_slot` 的主键, 无法创建外码约束; 用触发器来强制完整性

```sql
-- 插入时检查 (AFTER INSERT)
CREATE TRIGGER timeslot_check1 AFTER INSERT ON section
    REFERENCING NEW ROW AS nrow
    FOR EACH ROW
    WHEN (nrow.time_slot_id NOT IN (
        SELECT time_slot_id FROM time_slot))
    BEGIN
        ROLLBACK;
    END;

-- 删除时检查 (AFTER DELETE)
CREATE TRIGGER timeslot_check2 AFTER DELETE ON time_slot
    REFERENCING OLD ROW AS orow
    FOR EACH ROW
    WHEN (orow.time_slot_id NOT IN (SELECT time_slot_id FROM time_slot)
          AND orow.time_slot_id IN (SELECT time_slot_id FROM section))
    BEGIN
        ROLLBACK;
    END;
```

- **维护 tot_cred 字段的触发器:**

```sql
CREATE TRIGGER credits_earned AFTER UPDATE OF takes ON (grade)
    REFERENCING NEW ROW AS nrow
    REFERENCING OLD ROW AS orow
    FOR EACH ROW
    WHEN (nrow.grade <> 'F' AND nrow.grade IS NOT NULL
          AND (orow.grade = 'F' OR orow.grade IS NULL))
    BEGIN ATOMIC
        UPDATE student
        SET tot_cred = tot_cred + (
            SELECT credits FROM course
            WHERE course.course_id = nrow.course_id)
        WHERE student.id = nrow.id;
    END;
```

#### 触发事件与动作

- **触发事件:**  `INSERT`, `DELETE`, `UPDATE`

  - UPDATE 可以限定特定属性: `AFTER UPDATE OF takes ON grade`

- **新旧行引用:**

  | 子句 | 适用场景 |
  | --- | --- |
  | `REFERENCING OLD ROW AS ...` | 删除和更新 (引用操作前的行) |
  | `REFERENCING NEW ROW AS ...` | 插入和更新 (引用操作后的行) |

- **BEFORE vs AFTER:**

  - `BEFORE`: 在事件发生前触发, 可用来做额外约束检查或数据转换

    ```sql
    -- 将空白成绩转为 null
    CREATE TRIGGER setnull_trigger BEFORE UPDATE OF takes
        REFERENCING NEW ROW AS nrow
        FOR EACH ROW
        WHEN (nrow.grade = ' ')
        BEGIN ATOMIC
            SET nrow.grade = NULL;
        END;
    ```

#### 语句级触发器(Statement Level Triggers)

```sql
-- FOR EACH STATEMENT: 对一次更新操作执行一次 (而非对每行执行一次)
-- 使用 referencing old table / referencing new table 引用受影响的行的集合 (transition tables)
CREATE TRIGGER ... AFTER UPDATE ON ...
    REFERENCING OLD TABLE AS old_t
    REFERENCING NEW TABLE AS new_t
    FOR EACH STATEMENT
    ...
```

> 当 SQL 语句一次更新大量行时, 语句级触发器比行级触发器更高效

#### 何时不该用触发器

- **过去触发器常被用于:**
  - 维护汇总数据(如各系总工资)
  - 数据库复制(记录变更日志)

- **现在有更好的替代方案:**
  - **物化视图**来维护汇总数据
  - **内置复制支持**来做数据库复制
  - **封装方法**来替代触发器中的逻辑

- **触发器的风险:**
  - 加载备份数据时触发器意外执行
  - 远程站点复制时触发器触发
  - 触发器错误导致关键事务失败
  - **级联触发(Cascading Execution):** 触发器触发另一个触发器, 形成链式反应
