# 数据库系统期末考试双面 A4 纸 Cheat Sheet 与备考指南
**Database Systems Final Exam - Double-Sided A4 Cheat Sheet & Preparation Guide**

本文件结合 2021-2022 与 2022-2023 历年卷特点，对期末考试的题型分布、高频考点、常考公式及经典例题进行了系统性梳理。

---

## 第一部分：考试特征与笔记定位清单
**Exam Structure & Notes Mapping**

### 1. 题型分布与分值占比
期末考试卷面总分 100 分，结构极其稳定，题型分布如下：
* **一、 单项选择题 (Multiple Choice Questions)**：
  * 占比：24% ~ 36%（21-22 为 12题*3分=36分；22-23 为 8题*3分=24分）
* **二、 判断题 (True/False Questions)**：
  * 占比：0% ~ 12%（21-22 无判断题；22-23 为 6题*2分=12分）
* **三、 SQL 语句编写 (SQL Queries)**：
  * 占比：16%（4道题，每题4分）
* **四、 数据库设计与模式转换 (Database Design - ERD & Schemas)**：
  * 占比：16%（画 ER 图 8-10分，转关系模式并标注主外键 6-8分）
* **五、 并发控制与 2PL (Concurrency Control & 2PL)**：
  * 占比：8%（判断冲突可串行性、画优先图、论证 2PL 协议）
* **六、 ARIES 恢复算法 (ARIES Recovery)**：
  * 占比：12%（分析阶段脏页表、Redo起点、Undo补偿日志CLR生成、恢复后数据值）
* **七、 写优化索引结构 (Write-Optimized Indexes)**：
  * 占比：12%（21-22 考 LSM-Tree 读写开销估算；22-23 考 Buffer Tree 插入与分裂过程）

---

### 2. 核心考点与笔记对应位置索引
在复习和对照 [DB_Note](file:///e:/mkdocs/DB_Note/docs/) 笔记时，各高频考点对应的章节如下：

| 高频考点 | 对应笔记章节 | 核心考点说明 |
| :--- | :--- | :--- |
| **关系代数等价性** | [chap.2.md](file:///e:/mkdocs/DB_Note/docs/chap.2.md) & [chap.12.md](file:///e:/mkdocs/DB_Note/docs/chap.12.md) | 自连接重命名后的自然连接错误、选择/投影下推规则 |
| **外键级联约束** | [chap.3.md](file:///e:/mkdocs/DB_Note/docs/chap.3.md) & [chap.4.md](file:///e:/mkdocs/DB_Note/docs/chap.4.md) | `ON DELETE/UPDATE CASCADE` 级联删除与更新的行数计算 |
| **正则覆盖与分解** | [chap.7.md](file:///e:/mkdocs/DB_Note/docs/chap.7.md) | 求 Canonical Cover、无损连接性与保持依赖性判断 |
| **行存 vs. 列存** | [chap.9.md](file:///e:/mkdocs/DB_Note/docs/chap.9.md) | 列存储的优势（IO减小、压缩率高、不适合频繁更新删除） |
| **B⁺ 树高度与开销** | [chap.10.md](file:///e:/mkdocs/DB_Note/docs/chap.10.md) | 节点扇出 $n$ 的计算、B⁺ 树最坏高度 $h$、范围查询与等值查询 I/O 次数 |
| **外部归并排序开销**| [chap.11.md](file:///e:/mkdocs/DB_Note/docs/chap.11.md) | 外部归并排序（External Merge Sort）在不同缓冲区分配下的 Seeks 和 Transfers |
| **哈希连接内存计算**| [chap.11.md](file:///e:/mkdocs/DB_Note/docs/chap.11.md) | Hash Join 避免递归分块的最小内存 $M > \sqrt{b_r}$、I/O 代价公式 |
| **选择/连接大小估算**| [chap.12.md](file:///e:/mkdocs/DB_Note/docs/chap.12.md) | 选择度 $s$、等值/非等值选择大小估算、自然连接大小估计 |
| **SQL 复杂查询** | [chap.3.md](file:///e:/mkdocs/DB_Note/docs/chap.3.md) & [chap.4.md](file:///e:/mkdocs/DB_Note/docs/chap.4.md) | `GROUP BY`、`HAVING`、自连接、`LEFT JOIN`、`AVG/COUNT/MAX` 复合嵌套 |
| **ER 图与模式转换** | [chap.6.md](file:///e:/mkdocs/DB_Note/docs/chap.6.md) | 强/弱实体集表示、多对多/一对多联系、转化关系模式时主外键确立 |
| **并发优先图与 2PL** | [chap.14.md](file:///e:/mkdocs/DB_Note/docs/chap.14.md) | 冲突操作判定、画 Precedence Graph、2PL 是可串行化的充分非必要条件 |
| **ARIES 恢复过程** | [chap.15.md](file:///e:/mkdocs/DB_Note/docs/chap.15.md) | 脏页表 RecLSN、RedoLSN 确定、Undo 逆序回滚与 CLR 日志写入 |
| **写优化索引** | [chap.10.md](file:///e:/mkdocs/DB_Note/docs/chap.10.md) | LSM-Tree 层次合并代价与检索代价；Buffer Tree 插入、Overflow、下放与分裂 |

---
---

## 第二部分：A4 纸 Cheat Sheet 抄写蓝本
> **提示**：本部分排版紧凑，公式与例题并重，建议双面打印或手抄至考场 A4 纸。

### 1. 关系代数等价性与优化 (Relational Algebra)
* **核心公式/规则：**
  * 选择交换率：$\sigma_{\theta_1}(\sigma_{\theta_2}(E)) \equiv \sigma_{\theta_2}(\sigma_{\theta_1}(E))$
  * 选择与笛卡尔积结合（转为连接）：$\sigma_{\theta}(E_1 \times E_2) \equiv E_1 \bowtie_{\theta} E_2$
  * 选择下推（分配率）：$\sigma_{\theta}(E_1 \cup E_2) \equiv \sigma_{\theta}(E_1) \cup \sigma_{\theta}(E_2)$
  * **注意**：两个表进行自连接重命名为 $s_1$ 和 $s_2$ 时，由于其所有属性名称不同（如 $s_1.id$ 与 $s_2.id$），**不能**直接使用自然连接 $\bowtie$，必须显式使用条件连接 $\bowtie_{s_1.dept\_name=s_2.dept\_name}$。直接自然连接 $\rho_{s_1}(E) \bowtie \rho_{s_2}(E)$ 等同于无共同属性的笛卡尔积。
* **经典例题 (21-22 选择 1)：**
  查询 `select s1.id, s2.id from student s1, student s2 where s1.dept_name=s2.dept_name and s1.age<18 and s2.age>28`。
  * **等价写法**：
    * $\Pi_{s1.id, s2.id} ( \sigma_{s1.dept\_name=s2.dept\_name} ( \sigma_{age<18}(\rho_{s1}(student)) \times \sigma_{age>28}(\rho_{s2}(student)) ) )$
  * **不等价写法（错误选项）**：
    * $\Pi_{s1.id, s2.id} ( \sigma_{s1.age<18 \land s2.age>28} ( \rho_{s1}(student) \bowtie \rho_{s2}(student) ) )$
    * *错误原因*：$\rho_{s1}(student) \bowtie \rho_{s2}(student)$ 无同名属性，退化为笛卡尔积，丢失了 $s1.dept\_name=s2.dept\_name$ 的连接约束条件。

---

### 2. 级联更新与删除 (Foreign Key Cascade)
* **核心机制：**
  * `ON DELETE CASCADE`：父表记录被删除时，子表中所有引用该主键的记录一并被删除。
  * `ON UPDATE CASCADE`：父表主键值更新时，子表中所有引用该主键的字段同步更新为新值。
* **典型递推步骤 (21-22 选择 2)：**
  表 `r(pid primary key, qid references r on delete cascade on update cascade)`。
  数据：`11|null`, `22|11`, `33|22`, `44|22`, `55|11`。
  * 执行 a) `insert into r values ('11','55')` $\rightarrow$ 报错！因为 `55` 此时在外键中虽存在，但主键 `11` 已存在，不能插入。
    * *更正*：如果是 `insert into r values ('77','11')` 则成功。
  * 执行 b) `delete from r where pid='22'` $\rightarrow$ 级联删除引用 `22` 的记录，即 `33` 和 `44` 被自动删除。此时剩余：`11`, `55`。
  * 执行 c) `update r set pid='22' where pid ='11'` $\rightarrow$ 将 `11` 改为 `22`。级联更新引用 `11` 的记录，即 `55` 的 `qid` 变为 `22`。此时剩余：`22|null`，`55|22`。
  * 执行 d) `select count(*) from r where qid='22'` $\rightarrow$ 此时只有 `55` 的 `qid` 为 `22`。结果为 1。

---

### 3. 正则覆盖与保持依赖分解 (Functional Dependencies & 3NF)
* **Canonical Cover (正则覆盖 $F_c$) 求解算法：**
  1. 将所有函数依赖的右侧化为单一属性（使用合并规则 $X \rightarrow A \land X \rightarrow B \Rightarrow X \rightarrow AB$）。
  2. 在每个函数依赖 $X \rightarrow A$ 中，检查左侧 $X$ 是否含有外在（多余）属性。
     * 若 $Y \subset X$，且 $(X - Y)^+$ 在 $F$ 下包含 $A$，则 $Y$ 是多余的，从左侧删除 $Y$。
  3. 检查是否存在外在（多余）的函数依赖。
     * 对于 $F$ 中的某个 $X \rightarrow A$，若在 $F - \{X \rightarrow A\}$ 下计算 $X^+$ 仍包含 $A$，则该依赖多余，直接删除。
* **经典例题 1 (21-22 选择 3)：**
  求 $F = \{A \rightarrow B, B \rightarrow C, A \rightarrow CD, BD \rightarrow C\}$ 的正则覆盖。
  1. 合并右侧：$A \rightarrow BCD$ (因为 $A \rightarrow B, A \rightarrow CD$)。
  2. 检查左侧：对于 $BD \rightarrow C$，看 $D$ 是否多余。在 $F$ 中计算 $B^+ = BC$ 包含 $C$，故 $D$ 在左侧多余，依赖简化为 $B \rightarrow C$。
  3. 检查多余依赖：当前依赖集 $\{A \rightarrow BCD, B \rightarrow C\}$。
     * 检查 $A \rightarrow C$ 是否多余：在 $\{A \rightarrow BD, B \rightarrow C\}$ 下计算 $A^+ = ABCD$ 包含 $C$，故 $A \rightarrow C$ 多余，从 $A \rightarrow BCD$ 右侧剔除 $C$。
     * 最终得到 $F_c = \{A \rightarrow BD, B \rightarrow C\}$。
* **无损/保持依赖判断 (21-22 选择 4)：**
  $R(A, B, C, D, E)$，$F = \{A \rightarrow B, B \rightarrow CD\}$。
  * 检查分解 $\{R_1(A,B), R_2(A,C,D), R_3(A,E)\}$ 是否保持依赖。
    * 对 $B \rightarrow CD$，其涉及属性为 $B, C, D$。分解中没有任何一个子关系同时包含 $B$ 和 $C, D$（只有 $A, B$ 和 $A, C, D$）。
    * 计算 $(BCD)^+$ 发现无法在子模式的局部依赖闭包中恢复 $B \rightarrow CD$，因此该分解**不保持依赖**。

---

### 4. B⁺-树扇出、高度与检索开销 (B⁺-Tree Index)
* **核心公式：**
  * 节点大小为 $P$，键大小为 $K$，指针大小为 $V$。
  * 非叶节点最大扇出（度数）$n$ 满足：
    
    $$n \cdot V + (n - 1) \cdot K \le P \implies n \le \frac{P + K}{V + K}$$

  * 最坏情况节点填充度：非叶节点至少有 $\lceil n/2 \rceil$ 个子节点；叶节点至少有 $\lceil (n - 1)/2 \rceil$ 个键值。
  * 对于 $N$ 个键，最坏高度 $h \le \lceil \log_{\lceil n/2 \rceil} (N) \rceil + 1$。
  * **I/O 代价估计**：
    * 检索单条记录（Index Scan）：
      * 索引查找：需要读取 $h$ 个索引节点块。若无缓存，则需 $h$ 次 seek 和 $h$ 次 transfer。
      * 数据块读取：主（聚集）索引下数据有序，若等值查询只需 1 次 seek + 1 次 transfer；辅助（非聚集）索引需要先查叶子节点上的指针桶，再随机 seek 读取数据记录。
* **经典例题 (21-22 选择 8)：**
  B⁺ 树索引高度为 4，查询 `select * from student where ID='2020160008'`（ID为主键）。
  使用 Index Scan 算法定位记录的估算代价为：
  * **答案**：4 block transfers + 4 seeks。
  * *解析*：因为高度为 4，从根到叶节点路径上共有 4 个节点。由于是等值查询且无缓存，顺着树向下查找共需要 4 次 seek 和 4 次 block transfer。

---

### 5. 外部归并排序开销计算 (External Merge Sort)
* **核心算法与公式：**
  * 数据块数 $N$，内存缓冲区大小 $M$ 块。
  * **Pass 0 (生成初始归并段 Run)**：
    * 读入 $M$ 块进行内部排序，写回磁盘。
    * 生成的初始 Run 数量 $N_0 = \lceil N/M \rceil$。
    * I/O 代价：$2N$ 次 block transfers；$2 N_0$ 次 seeks（读写各 $N_0$ 次）。
  * **后续 Merge 阶段**：
    * 若每次归并输入分配 1 个块，输出分配 1 个块，则归并路数（fan-in）为 $M - 1$。
    * 归并段合并所需的 Pass数：$P = \lceil \log_{M-1} (N_0) \rceil$。
    * 每次 Pass 的 I/O 代价：$2N$ 次 transfers；寻道数取决于分配的块缓冲大小。
* **特殊缓冲分配例题 (21-22 选择 9 - 必背考题)：**
  $N = 160$ 块，内存缓冲区 $M = 10$ 块。使用外部归并排序，**每个输入归并段和输出段分配 2 个缓冲块**，排好序的结果写回磁盘。求总开销。
  * **Pass 0**：
    * 每次用满 10 个缓冲块进行排序。生成 $160 / 10 = 16$ 个初始 Run，每个 Run 大小为 10 块。
    * Transfers: $2N = 320$。Seeks: 读 16 次 + 写 16 次 = 32 次。
  * **Merge 阶段扇出计算**：
    * 每个输入 Run 分配 2 块，输出段分配 2 块。
    * 归并路数 (fan-in) $d = (10 - 2) / 2 = 4$ 路。
  * **Pass 1**：
    * 16 个初始 Run 进行 4 路归并，生成 4 个新的 Run（每个大小为 40 块）。
    * Transfers: $2N = 320$。
    * Seeks: 4 个组，每组归并 4 个大小为 10 块的段。
      * 读 1 个段需要 $\lceil 10 / 2 \rceil = 5$ 次 seek $\Rightarrow$ 每组读 seek = $4 \times 5 = 20$ 次。
      * 写输出段（大小 40 块）需要 $\lceil 40 / 2 \rceil = 20$ 次 seek。
      * 每组总 seek = $20 + 20 = 40$ 次。
      * 4 个组的总 seek = $4 \times 40 = 160$ 次。
  * **Pass 2**：
    * 将 4 个大小为 40 块的 Run 归并为 1 个大小为 160 块的最终 Run。
    * Transfers: $2N = 320$。
    * Seeks: 读 4 个段，每个段 seeks = $\lceil 40 / 2 \rceil = 20$ 次 $\Rightarrow$ 读 seek = $4 \times 20 = 80$ 次；写输出 seeks = $\lceil 160 / 2 \rceil = 80$ 次。
      * 本 Pass 总 seek = $80 + 80 = 160$ 次。
  * **总开销**：
    * Transfers = $320 \times 3 = 960$。Seeks = $32 + 160 + 160 = 352$ 次。（选 C）

---

### 6. Hash Join 内存与代价计算 (Hash Join)
* **核心公式：**
  * 关系 $r$ 的块数为 $b_r$，关系 $s$ 的块数为 $b_s$。
  * **无递归分块的最小内存 $M$ 满足：**
    
    $$M > \sqrt{f \cdot b_r} \quad (\text{通常取 } M > \sqrt{b_r})$$
    
    *若不满足，则需要进行递归分块。*
  * **I/O 代价公式（无递归分块）：**
    * Block Transfers：$3(b_r + b_s)$（划分阶段读一遍、写一遍，归并阶段读一遍）。
    * Seeks：$2 \lceil b_r / b_b \rceil + 2 \lceil b_s / b_b \rceil + 2n_h$（其中 $b_b$ 是读写缓冲块数，$n_h$ 是分区数）。
* **经典例题 1 (21-22 选择 10)：**
  $b_r = 256$ 块，$b_s = 1024$ 块。每个块大小 4KB。求进行自然连接不发生递归分块的最小内存大小。
  * **计算**：$M > \sqrt{256} = 16$ 块。
  * 内存大小 = $16 \times 4\text{KB} = 64\text{KB}$。（选 A）

---

### 7. 查询大小估算 (Query Size Estimation)
* **核心估算公式：**
  * 关系 $r$ 的记录数为 $n_r$。
  * **等值选择 $\sigma_{A=V}(r)$**：
    * 若 $A$ 是候选键：估算大小 $= 1$。
    * 若 $A$ 是普通属性，且不同值个数为 $V(A, r)$：估算大小 $= n_r / V(A, r)$。
  * **非等值选择 $\sigma_{A \ge V}(r)$**：
    * 假设值分布均匀，估算大小 $= n_r \times \frac{\max(A) - V}{\max(A) - \min(A)}$。若无边界范围，默认估算为 $n_r / 2$ 或 $n_r / 3$。
  * **自然连接 $r \bowtie s$**：
    * 若 $r \cap s = \emptyset$（无公共属性）：估算大小 $= n_r \times n_s$。
    * 若 $r \cap s = \{A\}$，且 $A$ 是 $s$ 的主键：每个 $r$ 中的元组最多在 $s$ 中匹配一个，估算大小 $= n_r$。
    * 若 $A$ 在两个表都非主键：估算大小 $= \frac{n_r \times n_s}{\max(V(A,r), V(A,s))}$。
* **综合大小估算例题 (21-22 选择 12)：**
  表 `instructor` 记录数 4000，`teaches` 记录数 8000。
  `dept_name` 在 `instructor` 中的不同值有 20 个。
  `salary` 范围在 10000 到 90000。
  估算：`select * from instructor natural join teaches on ID where dept_name='CS' and salary >= 70000` 的大小。
  1. 自然连接 `instructor natural join teaches`：由于 `ID` 是 `instructor` 的主键，连接后的记录数估算为 `teaches` 的记录数，即 8000。
  2. 选择条件 `dept_name='CS'`：选择度为 $1/20$。此时数量 $= 8000 / 20 = 400$。
  3. 选择条件 `salary >= 70000`：值范围 $10000 \sim 90000$，选择度为 $(90000 - 70000) / (90000 - 10000) = 20000 / 80000 = 1/4$。
  4. 最终估计大小 $= 400 \times (1/4) = 100$。（选 C）

---

### 8. 并发控制与两阶段锁协议 (2PL)
* **核心判定条件：**
  * **冲突（Conflict）操作**：两个不同事务针对**同一数据项**的操作，只要**其中有一个是写操作**（即 $w_i(A)$ 与 $r_j(A)$，或 $w_i(A)$ 与 $w_j(A)$），就构成冲突。
  * **冲突可串行性**：若优先图（Precedence Graph，冲突关系画出的有向图）中**无环**，则调度是冲突可串行化的。
  * **两阶段锁协议 (2PL)**：
    * 增长阶段：可以获得锁，不能释放锁。
    * 收缩阶段：可以释放锁，不能获得锁。
    * **定理**：2PL 是冲突可串行化的**充分非必要条件**。
* **经典大题例题 (21-22 简答 4)：**
  请给出一个包含 3 个事务的调度，含冲突操作，证明 2PL 协议**不是**冲突可串行性的必要条件（即找出一个可串行化但不满足 2PL 的调度）。
  * **构造示例**：
    
    | 步骤 | 事务 $T_1$ | 事务 $T_2$ | 事务 $T_3$ |
    | :--- | :--- | :--- | :--- |
    | 1 | `lock-X(A)`; `r(A)`; `w(A)` | | |
    | 2 | `unlock(A)` | | |
    | 3 | | `lock-X(A)`; `r(A)`; `w(A)` | |
    | 4 | | `unlock(A)` | |
    | 5 | | | `lock-X(A)`; `r(A)`; `w(A)` |
    | 6 | | | `unlock(A)` |
    
    * **分析**：
      * 该调度由于是完全串行执行时的（$T_1 \rightarrow T_2 \rightarrow T_3$），所以显然是冲突可串行化的。
      * 但对于每个事务，在释放锁（`unlock`）之后就不能再获取任何锁。如果我们在事务内部先 unlock 然后又执行其他操作，就会违反 2PL。
      * **更严谨的交错不满足 2PL 但可串行化构造**：
        
        $$S: r_1(A) \ w_1(A) \ r_2(A) \ w_2(A) \ r_3(B) \ w_3(B) \ r_1(B) \ w_1(B)$$
        
        * 依赖关系：由于在 $A$ 上 $T_1 \rightarrow T_2$；在 $B$ 上 $T_3 \rightarrow T_1$。优先图为 $T_3 \rightarrow T_1 \rightarrow T_2$，无环，冲突可串行化。
        * 2PL 验证：$T_1$ 必须在第 2 步后释放 $A$ 上的锁以让 $T_2$ 加锁。但 $T_1$ 在第 7 步又需要获取 $B$ 上的锁。在释放锁之后再次获取锁，违背了 2PL 协议。

---

### 9. ARIES 恢复算法 (ARIES Recovery)
* **三个阶段核心逻辑：**
  * **Analysis 阶段**：从最近的 checkpoint 开始向前/向后扫描日志。
    * 脏页表 (DPT) 初始化为 checkpoint 中的表。后续发现任何修改页的 Log $L$，若该页不在 DPT 中，则加入 DPT 并令 $\text{RecLSN} = L$。
    * 活跃事务表初始化为 checkpoint 中的表。后续若有 `<Ti begin>` 则加入，`<Ti commit/abort>` 则移出。
  * **Redo 阶段**：从 DPT 中最小的 `RecLSN` 开始向后重做所有历史写操作（包括未提交和已撤销的）。
  * **Undo 阶段**：从崩溃时的 active 事务列表开始，逆序回滚所有未提交事务。
    * 撤销某操作 $L$ 时，写补偿日志 CLR，其 `UndoNextLSN` 指向 $L$ 的 `PrevLSN`。当 `UndoNextLSN` 变为 null 时，写入 `<Ti abort>` 表示该事务回滚完毕。
* **经典大题例题 (21-22 简答 5)：**
  [日志数据见第六题背景]
  * **分析阶段脏页表**：扫描 2012 (T1 commit, 移出), 2013 (T3写5002, 已经在DPT), 2014 (T4写5003, 新加入DPT, RecLSN=2014), 2015 (T3 commit, 移出)。
    * 最终脏页表：**5001 (RecLSN=2003), 5002 (RecLSN=2006), 5003 (RecLSN=2014)**。
  * **需 Undo 的事务**：未提交的 **$T_4$**（LastLSN = 2014）。
  * **恢复后数值**：
    * `5001.2`：在 LSN 2004 由已提交的 $T_2$ 改为 222；在 LSN 2009 由未提交的 $T_4$ 改为 444。Undo 撤销 $T_4$ 后回滚为 **222**。
    * `5002.2`：在 LSN 2010 由已提交的 $T_1$ 改为 555；在 LSN 2013 由已提交的 $T_3$ 改为 666。均不撤销，值为 **666**。
  * **追加的恢复日志**：
    * LSN 2016: `<T4, 5003.1, 77, UndoNextLSN=2009>` (撤销 LSN 2014)
    * LSN 2017: `<T4, 5001.2, 222, UndoNextLSN=null>` (撤销 LSN 2009)
    * LSN 2018: `<T4, abort>` (T4回滚结束)

---

### 10. 写优化索引 (LSM-Tree & Buffer Tree)
* **LSM-Tree 代价模型：**
  * L0 在内存中，大小为 $B$ 块。写满后顺序写入磁盘。
  * **写 L0 到磁盘**：1 次 seek + $B$ 次 transfers。
  * **单条记录查找**：依次查找内存 L0、磁盘 L0 ($T_1, T_2, \dots$)。若每个磁盘树高为 $H$，则需在每个磁盘树上进行 $H$ 次 seek + $H$ 次 transfers。
  * **合并 L0 树 $T_1, T_2$ 写入 L1**：
    * 顺序读取 $T_1$ 和 $T_2$ 的叶子节点（因树有序，叶子块在磁盘上连续）。
      * 读取 $T_1$ 叶子：1 次 seek + $L$ 次 transfers（$L$ 为叶子节点块数）。
      * 读取 $T_2$ 叶子：1 次 seek + $L$ 次 transfers。
    * 归并生成新树写入 L1。新树总块数为 $N_{\text{new}}$。顺序写入：1 次 seek + $N_{\text{new}}$ 次 transfers。
* **Buffer Tree 运行逻辑：**
  * 插入键值先存入 Root 缓冲区。缓冲满则向下级子节点下放（Flush）。
  * 遇到叶子节点则直接插入。叶子节点键数超过限制，则向上分裂。
* **经典大题例题 (22-23 简答 7)：**
  度 $n=4$（叶/内节点最多 3 键），缓冲大小 $B=2$。
  * **插入 38, 92**：Root 缓冲变为 `[38, 92]`，未溢出。
  * **插入 28**：Root 变为 `[38, 92, 28]` 溢出。
    * 根划分键为 80。`[38, 28]` 下放到左内节点；`[92]` 下放到右内节点。
    * 右内节点缓冲变为 `[92, 98]`，未溢出。
    * 左内节点缓冲变为 `[8, 22, 28, 38]` 溢出，继续下放。
      * 左内节点键为 30, 50。小于 30 的 `[8, 22, 28]` 下放到 Leaf 1；$30 \sim 50$ 的 `[38]` 下放到 Leaf 2。
    * Leaf 2 插入 38 后为 `[30, 38, 40]`（未溢出）。
    * Leaf 1 (`[10, 20]`) 插入 `[8, 22, 28]` 后溢出（共5个键：`8,10,20,22,28`），分裂为左叶子 `[8,10,20]` 和右叶子 `[22,28]`。
    * 将右侧最小键 `22` 向上推入左内节点。左内节点键变为 `[22,30,50]`（未溢出）。
