## 查询优化

**Chapter 16: Query Optimization**

### 查询优化概述

> 对于同一个 SQL 查询，通常存在多种逻辑上等价的关系代数表达式，以及多种不同的物理执行算法。查询优化的目标是选择其中**估计代价最低**的查询执行计划。

- **Explain 语句:**
  - `EXPLAIN <query>`: 显示数据库优化器选择的执行计划和估算的代价。
  - `EXPLAIN ANALYZE <query>`: (如 PostgreSQL) 除了显示计划和估算值外，还会**实际执行**该查询并输出运行时的真实统计数据。
- **代价估算依据:**  依赖于**数据库目录 (Catalog)** 中维护的表和属性的统计信息。

---

### 关系表达式的等价变换规则

> 如果两个关系代数表达式在任何合法的数据库实例上产生的元组集合（或多重集）完全相同，则称它们是等价的。

#### 核心等价规则 (Equivalence Rules)

1. **合取选择拆分 (Conjunctive Selection):**
   
   $$\sigma_{\theta_1 \land \theta_2}(E) \equiv \sigma_{\theta_1}(\sigma_{\theta_2}(E))$$

2. **选择交换律 (Commutativity of Selection):**
   
   $$\sigma_{\theta_1}(\sigma_{\theta_2}(E)) \equiv \sigma_{\theta_2}(\sigma_{\theta_1}(E))$$

3. **投影级联简化:**  只保留最外层的投影属性列表
   
   $$\Pi_{L_1}(\Pi_{L_2}(\dots(\Pi_{L_n}(E))\dots)) \equiv \Pi_{L_1}(E) \quad (\text{其中 } L_1 \subseteq L_2 \subseteq \dots \subseteq L_n)$$

4. **选择与笛卡尔积结合为连接:**
   
   $$\sigma_{\theta}(E_1 \times E_2) \equiv E_1 \bowtie_{\theta} E_2$$

5. **连接与自然连接的交换律:**
   
   $$E_1 \bowtie_{\theta} E_2 \equiv E_2 \bowtie_{\theta} E_1$$

6. **连接的结合律 (Associativity):**
   
   $$(E_1 \bowtie E_2) \bowtie E_3 \equiv E_1 \bowtie (E_2 \bowtie E_3)$$

7. **选择分配律 (选择下推 Selection Pushdown):**
   - 若选择条件 $\theta_0$ 只包含 $E_1$ 的属性：
     
     $$\sigma_{\theta_0}(E_1 \bowtie_{\theta} E_2) \equiv (\sigma_{\theta_0}(E_1)) \bowtie_{\theta} E_2$$
     
   - **意义:**  允许我们在连接运算前先进行选择过滤，减少连接的输入规模（**尽早执行选择**）。

8. **投影分配律 (投影下推 Projection Pushdown):**
   - 设 $L_1$ 为 $E_1$ 的属性集，$L_2$ 为 $E_2$ 的属性集，且连接条件 $\theta$ 只涉及 $L_1$ 和 $L_2$ 中的属性：
     
     $$\Pi_{L_1 \cup L_2}(E_1 \bowtie_{\theta} E_2) \equiv \Pi_{L_1}(E_1) \bowtie_{\theta} \Pi_{L_2}(E_2)$$
     
   - **意义:**  允许我们在连接前把不需要的属性过滤掉（**尽早执行投影**），减少中间关系在内存/磁盘中的开销。

---

### 代价估算与统计信息

#### 数据库目录中的元数据统计 (Catalog Statistics)

- $n_r$: 关系 $r$ 的元组总数。
- $b_r$: 包含关系 $r$ 的数据物理块总数。
- $l_r$: 关系 $r$ 单个元组的平均字节长度。
- $f_r$: 关系 $r$ 的阻断因子 (blocking factor)，即一个物理块所能容纳的元组数 ($f_r = \lfloor \text{block\_size} / l_r \rfloor$)。
- $V(A, r)$: 属性 $A$ 在关系 $r$ 中的**非重复值个数 (number of distinct values)**。

#### 结果大小估算 (Size Estimation)

##### 1. 选择操作 $\sigma_{\theta}(r)$ 的大小估算 (设满足条件的元组数为 $n$)

- **等值选择 ($\theta$ 为 $A = V$):**  假设数据均匀分布：
  
  $$n = \frac{n_r}{V(A, r)}$$

- **范围选择 ($\theta$ 为 $A \le V$):**  设属性 $A$ 的当前最小值为 $\min$，最大值为 $\max$：
  
  $$n = n_r \cdot \frac{V - \min}{\max - \min}$$

- **复杂条件选择 (基于独立性假设):**
  - **合取 ($\theta_1 \land \theta_2$):**  $s = n_r \cdot \frac{s_1}{n_r} \cdot \frac{s_2}{n_r}$
  - **析取 ($\theta_1 \lor \theta_2$):**  $s = n_r \cdot \left(1 - \left(1 - \frac{s_1}{n_r}\right) \cdot \left(1 - \frac{s_2}{n_r}\right)\right)$
  - **非 ($\neg \theta_1$):**  $s = n_r - s_1$

##### 2. 连接操作 $r \bowtie s$ 的大小估算

- **若无公共属性 ($R \cap S = \emptyset$):**  退化为笛卡尔积，大小为 $n_r \cdot n_s$。
- **若公共属性 $A$ 是 $s$ 的主键:**  大小不超过外表 $r$ 的大小，即 $\le n_r$。
- **一般等值连接 (公共属性为 $A$ 且均非主键):**
  
  $$n \approx \frac{n_r \cdot n_s}{\max(V(A, r), V(A, s))}$$

---

### 基于代价的连接顺序优化 (Cost-Based Join Optimization)

- **连接顺序组合爆炸:**  对于 $n$ 个关系的连接 $r_1 \bowtie r_2 \dots \bowtie r_n$，可能的连接树结构（不含笛卡尔积）数量高达 $\frac{(2(n-1))!}{(n-1)!}$。当 $n=7$ 时为 $665,280$ 个；$n=10$ 时则超过 $1760$ 亿。
- **动态规划解决方案 (Dynamic Programming):**
  - **算法逻辑:**  使用 `findbestplan(S)`，对于关系集合 $S$ 的任意子集，只计算一次并存储其最优连接计划与最低代价 (Memoization)。
  - **复杂度:**  将全空间搜索（Bushy trees，茂密树）的复杂度从指数级降为 **$O(3^n)$**，所需空间为 $O(2^n)$。对于 $n=10$，计算次数降为 $59,049$。
- **左深连接树 (Left-Deep Join Tree):**
  - 一类特殊的连接树：**每次 Join 的右侧输入必须是一个原始关系表**，而不能是另一个中间 Join 的计算结果。
  - **优势:**  极大地减小了优化器的搜索范围，且非常适合**流水线 (Pipelining)** 方式运行，减少中间结果落盘。

```
     Left-Deep Join Tree              Bushy Join Tree
            (Join)                         (Join)
            /    \                         /    \
        (Join)    r3                   (Join)  (Join)
        /    \                         /    \  /    \
      r1      r2                      r1    r2 r3    r4
```

---

### 启发式查询优化 (Heuristic Optimization)

> 代价优化开销较大时，系统常通过一组经验规则（启发式）先对查询树进行重写简化：

1. **尽早执行选择操作 (Push Selections Down):** 降低连接操作的输入规模。
2. **尽早执行投影操作 (Push Projections Down):** 丢弃中间结果中不需要的字段，减少内存与 I/O 负担。
3. **避免生成非必要的笛卡尔积:** 尽量通过有连接条件的算子来组合表。

---

### 嵌套子查询与去关联 (Nested Queries & Decorrelation)

- **关联变量 (Correlated Variable):**  子查询中引用了外层查询的变量。导致外层每读一行，子查询都需要重新评估一次（**关联求值 Correlated Evaluation**），非常低效。
- **去关联化 (Decorrelation):**  优化器通过关系代数重写，将嵌套的子查询转换为**连接 (Join)** 或**半连接 (Semijoin)** 的过程，使系统能用更高效的物理连接算法（如 Hash Join）来处理。

---

### 物化视图及其维护 (Materialized Views & Maintenance)

> **物化视图 (Materialized View):** 将视图的查询结果物理计算并存储在数据库中。适合被频繁查询且计算昂贵的场景。

#### 增量视图维护 (Incremental View Maintenance)

> 当基表发生改变时，不进行整表重算，而是根据变化的部分（增量/差分）来更新物化视图。设插入变化为 $i_r$，删除变化为 $d_r$。

- **连接操作 ($v = r \bowtie s$) 的增量维护:**
  - 基表 $r$ 发生插入 $i_r$: 
    
    $$v_{\text{new}} = v_{\text{old}} \cup (i_r \bowtie s)$$
    
  - 基表 $r$ 发生删除 $d_r$: 
    
    $$v_{\text{new}} = v_{\text{old}} - (d_r \bowtie s)$$

- **投影操作 ($\Pi_A(r)$) 的增量维护:**
  - **计数问题:** 基表 $r$ 删除一条记录，不能直接从 $\Pi_A(r)$ 删掉对应值，因为可能有多条基表记录投影出相同的值。
  - **解决方案:** 为物化视图中的每一项维护一个**派生计数 (Count)**。
    - 插入元组：若值已存在则计数器加 1，不存在则新建记录并将计数器设为 1。
    - 删除元组：计数器减 1。**当计数器减至 0 时**，物理删除该视图行。

- **聚集操作的增量维护:**
  - `COUNT`: 记录各 Group 的计数。发生基表删除时计数减 1，减至 0 时删除该 Group。
  - `SUM`: 除维护求和值外，**必须同时维护计数 COUNT**，以便在计数归零时彻底清除该 Group（防止因为累加得 0 与无记录混淆）。
  - `AVG`: 分开维护 `SUM` 与 `COUNT`，查询时动态相除。
  - `MIN / MAX`: 插入直接比较更新。但若被删除的记录正好是当前的最小值或最大值，则需要扫描该 Group 下的基表记录来重新找出新的最值（开销较大）。
