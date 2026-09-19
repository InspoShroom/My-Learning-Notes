# Theory of Computation

## CH1. Sets, Relations and Language

### Sets


**集合**

注意两个要点：

- 集合中的元素无序 (unordered) 的
- 空集 ($\emptyset$) (empty set) 是不包含任何元素的集合


**子集与真子集**

| 概念 | 记号 | 逻辑等价 / 形式化定义 | 说明 |
| :--- | :---: | :--- | :--- |
| 子集 (Subset) | $S \subseteq T$ | $\forall x \in S \Rightarrow x \in T$ | 常用于集合包含关系的证明 |
| 真子集 (Proper Subset) | $S \subset T$ | $(S \subseteq T) \land (S \neq T)$ | 严格被包含 |
| 集合相等 (Equal) | $S = T$ | $(S \subseteq T) \land (T \subseteq S)$ | 互为子集（外延公理：$\forall x \, (x \in S \Leftrightarrow x \in T)$） |


**集合操作 (Set Operations)**

| 操作名称 | 记号 | 形式化定义 | 说明 |
| :--- | :---: | :--- | :--- |
| 并集 (Union) | $A \cup B$ | $\{x : x \in A \lor x \in B\}$ | 属于 $A$ 或属于 $B$ |
| 交集 (Intersection) | $A \cap B$ | $\{x : x \in A \land x \in B\}$ | 若 $A \cap B = \emptyset$，则称集合 $A$ 与 $B$ 不相交 (Disjoint) |
| 补集 (Complement) | $\overline{A}$ | $\{x : x \notin A\}$ | 相对于全集 $U$ 的补集 |
| 差集 (Difference) | $B - A$ | $\{x : x \in B \land x \notin A\}$ | 属于 $B$ 且不属于 $A$ |
| 对称差 (Symmetric Difference) | $A \oplus B$ | $(A - B) \cup (B - A)$ | 等价于 $(A \cup B) - (A \cap B)$ |


**集合恒等式 (Set Identities)**

| 定律名称 | 恒等式 1 | 恒等式 2 |
| :--- | :--- | :--- |
| 幂等律 (Idempotent Law) | $A \cap A = A$ | $A \cup A = A$ |
| 交换律 (Commutative Law) | $A \cup B = B \cup A$ | $A \cap B = B \cap A$ |
| 结合律 (Associative Law) | $A \cup (B \cup C) = (A \cup B) \cup C$ | $A \cap (B \cap C) = (A \cap B) \cap C$ |
| 分配律 (Distributive Law) | $A \cup (B \cap C) = (A \cup B) \cap (A \cup C)$ | $A \cap (B \cup C) = (A \cap B) \cup (A \cap C)$ |
| 吸收律 (Absorption Law) | $A \cup (A \cap B) = A$ | $A \cap (A \cup B) = A$ |
| 德·摩根律 (De-Morgan's Law) | $A - (B \cup C) = (A - B) \cap (A - C)$ | $A - (B \cap C) = (A - B) \cup (A - C)$ |

> 计算理论视角的哲学思考：

> - 问题 $\Leftrightarrow$ 集合 或语言
> - 自动求解 $\Leftrightarrow$ 问题具有恒等变换规律 $\Leftrightarrow$ 可计算


**幂集 (Power Set)**

- 定义：集合 $A$ 的所有子集构成的集合，记作 $2^A$ (或 $\mathcal{P}(A)$)

    $$2^A = \{T \mid T \subseteq A\}$$

- 示例：若 $S = \{x, y, z\}$，则其所有子集为：

    $$\emptyset, \{x\}, \{y\}, \{z\}, \{x, y\}, \{x, z\}, \{y, z\}, \{x, y, z\}$$

    因此其幂集为：

    $$2^S = \{\emptyset, \{x\}, \{y\}, \{z\}, \{x, y\}, \{x, z\}, \{y, z\}, \{x, y, z\}\}$$

- 记号 $2^A$ 的来源与理解：
    若有限集 $|A| = n$，则其所有子集的总数为 $2^n$，即 $|2^A| = 2^{|A|}$

    每个子集等价于一个从 $A$ 到 $\{0, 1\}$ 的特征函数 (Indicator / Characteristic Function)（集合中每个元素只有“选/1”或“不选/0”两种可能，对应 $2^{|A|}$ 种映射）


**集合的划分 (Partition)**

- 定义：非空集合 $A$ 的一个划分是幂集 $2^A$ 的一个子集族 $\Pi \subseteq 2^A$，满足以下 3 个条件：
    1. $\Pi \neq \emptyset$，且其中每一个划分块都是非空子集（$\forall S \in \Pi, S \neq \emptyset$）
    2. 两两不相交 (Pairwise Disjoint)：$\forall S, T \in \Pi \ (S \neq T \Rightarrow S \cap T = \emptyset)$
    3. 覆盖全集：所有块的并集为原集合，即 $\bigcup \Pi = A$

- 划分块 (Block / Cell)：划分 $\Pi$ 中的每个子集元素称为一个 Block (或 Cell)

- 示例：集合 $\{1, 2, 3\}$ 共有 5 种不同的划分（对应贝尔数 (Bell Number) $B_3 = 5$）：
    1. $\{\{1\}, \{2\}, \{3\}\}$
    2. $\{\{1, 2\}, \{3\}\}$
    3. $\{\{1, 3\}, \{2\}\}$
    4. $\{\{2, 3\}, \{1\}\}$
    5. $\{\{1, 2, 3\}\}$


### Relations and Functions


**有序对 (Ordered Pair)**

- 定义：元素排有先后顺序的二元组 $(a, b)$ 称为有序对 (Ordered Pair)

- 相等条件：

    $$(a, b) = (c, d) \Leftrightarrow (a = c) \land (b = d)$$


**二元关系 (Binary Relation)**

- 笛卡尔积 (Cartesian Product)：

    $$A \times B = \{(a, b) \mid a \in A \land b \in B\}$$

- 二元关系 (Binary Relation)：从集合 $A$ 到集合 $B$ 的二元关系 $R$ 是笛卡尔积 $A \times B$ 的一个子集：

    $$R \subseteq A \times B$$

    *注：若 $(a, b) \in R$，亦常记作 $aRb$*


**关系操作 (Operations of Relations)**

- 逆关系 (Inverse Relation)：
    若 $R \subseteq A \times B$，则其逆关系 $R^{-1} \subseteq B \times A$ 定义为：

    $$R^{-1} = \{(b, a) \mid (a, b) \in R\}$$

- 复合关系 (Composition)：
    设 $R$ 是从 $A$ 到 $B$ 的关系（$R \subseteq A \times B$），$S$ 是从 $B$ 到 $C$ 的关系（$S \subseteq B \times C$），则二者的复合关系记作 $R \circ S$（从 $A$ 到 $C$）：

    $$R \circ S = \{(a, c) \mid \exists b \in B, \, (a, b) \in R \land (b, c) \in S\}$$

- 复合例题解析：
    设 $X = \{4, 5, 6\}, Y = \{a, b, c\}, Z = \{l, m, n\}$

    $$R_1 = \{(4, a), (4, b), (5, c), (6, a), (6, c)\}$$

    $$R_2 = \{(a, l), (a, n), (b, l), (b, m), (c, l), (c, m), (c, n)\}$$

    1. 求解 $R_1 \circ R_2$（从 $X$ 到 $Z$）：
       通过中间集合 $Y$ 进行路径串联：

        $$R_1 \circ R_2 = \{(4, l), (4, m), (4, n), (5, l), (5, m), (5, n), (6, l), (6, m), (6, n)\}$$

    2. 求解 $R_1 \circ R_1^{-1}$（从 $X$ 到 $X$）：
       $R_1^{-1} = \{(a, 4), (b, 4), (c, 5), (a, 6), (c, 6)\}$，从 $X$ 经过 $Y$ 再回到 $X$：

        $$R_1 \circ R_1^{-1} = \{(4, 4), (4, 6), (5, 5), (5, 6), (6, 4), (6, 5), (6, 6)\}$$


**定义域与值域 (Domain and Range)**

- 定义域 (Domain)：关系中所有实际参与映射的输入值的集合

    $$\text{dom}(R) = \{a \in A \mid \exists b \in B, \, (a, b) \in R\}$$

- 值域 (Range)：关系中所有实际被映射到的输出值的集合

    $$\text{range}(R) = \{b \in B \mid \exists a \in A, \, (a, b) \in R\}$$

- 值域与陪域 (Codomain) 的区分：
    1. 若关系建立在集合 $A$ 和 $B$ 上（$R \subseteq A \times B$），目标集 $B$ 称为陪域 (Codomain)
    2. 值域恒为陪域的子集：$\text{range}(R) \subseteq B$
    3. 示例：设 $A = \{1, 2, 3\}, B = \{1, 2, 3, 4, 8, 9\}$，映射规则为 $1 \to 1, 2 \to 4, 3 \to 9$，则该关系的值域为 $\{1, 4, 9\}$，而不是整个 $B$


**函数 (Functions)**

- 形式化定义：从集合 $A$ 到集合 $B$ 的一个关系 $f \subseteq A \times B$，若满足对于 $A$ 中每个元素都有且仅有 $B$ 中一个唯一元素与之对应，则称 $f$ 为函数 (Function) (记作 $f: A \to B$)：

    $$\forall a \in A, \; \exists ! \, b \in B \text{ such that } (a, b) \in f \quad (\text{记作 } f(a) = b)$$

    ($\exists!$：有且仅有一个/存在唯一)

- 单射 (One-to-one / Injective)：

    $$a \neq b \Rightarrow f(a) \neq f(b) \quad (\text{等价逆否形式: } f(a) = f(b) \Rightarrow a = b)$$

    - 特点：不同的输入必然映射到不同的输出（$B$ 中元素不能接收来自多个 $A$ 的箭头）

- 满射 (Onto / Surjective)：

    $$\forall b \in B, \; \exists a \in A \text{ such that } f(a) = b$$

    - 特点：值域等于陪域，即 $\text{range}(f) = B$（$B$ 中每个元素都至少被一个箭头指向）

- 双射 / 一一对应 (Bijective / One-to-one Correspondence)：
    同时满足单射和满射 (Injective + Surjective)

    - 特点：集合 $A$ 与集合 $B$ 的元素完美一对一对应

- 核心思考与辨析：
    1. 不是函数的两种典型情形 (Not a Function)：
        - 一对多：$A$ 中同一个输入映射到多个不同的输出（破坏了唯一性）
        - 未完全定义：$A$ 中存在元素没有定义输出（函数必须对定义域 $A$ 的全体元素均有定义）
    2. 函数能否既不是单射也不是满射？
        - 可以，即普通函数 (General Function)。例如：$f: \mathbb{R} \to \mathbb{R}, f(x) = x^2$（因 $f(1) = f(-1) = 1$ 故非单射；因负数在实数域无原像故非满射）

    *注：$f:A \rightarrow B$ 左右两边分别代表定义域和陪域*


### Special Binary Relations


**关系的表示 (Representation of Relations)**

- 有向图 (Directed Graph)：
    1. 节点 (Node)：圆圈代表集合 $A$ 中的每个元素
    2. 有向边 (Arrow / Directed Edge)：从 $a$ 指向 $b$，当且仅当 $(a, b) \in R$
    3. 两节点间至多只有一条同向边（或无边）

- 逻辑矩阵 (Logical Matrix)：
    若 $R \subseteq X \times Y$，则可用矩阵 $M$ 表示，$M$ 的行列索引分别对应 $X$ 和 $Y$ 的元素：

    $$m_{i,j} = \begin{cases} 1, & (x_i, y_j) \in R \\ 0, & (x_i, y_j) \notin R \end{cases}$$


**关系的四大基本性质 (Properties of Relations)**

设关系 $R \subseteq A \times A$：

- 自反性 (Reflexive)：

    $$\forall a \in A \Rightarrow (a, a) \in R$$

    要求：必须覆盖集合 $A$ 中的所有元素：逻辑矩阵主对角线全为 1；图上每个节点都有自环

    示例：若 $A = \{1, 2, 3\}$，关系 $\{(1,1), (1,2), (2,2)\}$ 不是自反的，缺少 $(3,3)$

- 对称性 (Symmetric)：

    $$(a, b) \in R \land a \neq b \Rightarrow (b, a) \in R \quad$$

    要求：若存在一条有向边，则必存在反向边：逻辑矩阵是对称矩阵 $M = M^T$，可由无向图表示

    示例：$\{(2,1), (1,2), (2,2)\}$ 是对称的；而 $\{(1,1), (1,2), (2,2)\}$ 不是对称的，有 $(1,2)$ 却无 $(2,1)$

- 反对称性 (Antisymmetric)：

    $$(a, b) \in R \land a \neq b \Rightarrow (b, a) \notin R \quad (\text{等价形式: } (a, b) \in R \land (b, a) \in R \Rightarrow a = b)$$

    要求：两个不同节点之间至多只能有一条单向边，不允许存在双向箭头

    示例：$\{(1,1), (1,2), (2,2)\}$ 是反对称的；而 $\{(1,2), (2,1), (2,2)\}$ 不是反对称的

- 传递性 (Transitive)：

    $$(a, b) \in R \land (b, c) \in R \Rightarrow (a, c) \in R$$

    要求：若存在两步连续路径 $a \to b \to c$，则必存在一步直达边 $a \to c$

    示例：

    - $\{(1,1), (1,2), (2,3)\}$ 不是传递的（有 $(1,2)$ 和 $(2,3)$，但缺少 $(1,3)$）
    - $\{(1,2), (1,3)\}$ 是传递的，它不存在连续的两步路径前件，真空成立 (Vacuously True)

> 对称与反对称的关系辨析：

>   1. 对称与反对称不是互斥的互补对立关系
>   2. 既对称又反对称 (Both)：空关系 $\emptyset$ 或恒等关系的子集 $R \subseteq \{(a, a) \mid a \in A\}$（不存在不同元素的边，真空满足）
>   3. 既不对称也不反对称 (Neither)：既存在一对双向边（破坏反对称），又存在一条缺少反向边的单向边（破坏对称）


**等价关系与等价类 (Equivalence Relation & Equivalence Classes)**

- 等价关系 (Equivalence Relation)：

    条件：同时满足**自反 (Reflexive)、对称 (Symmetric)、传递 (Transitive)**的二元关系
    
    特征：图由若干个互不相连的团簇 (Clusters) 构成，每个簇内部的所有节点两两相互连通

- 等价类 (Equivalence Class)：
    1. 定义：元素 $a$ 所在的等价类记作 $[a]$：

        $$[a] = \{b \in A \mid (a, b) \in R\}$$

    2. 特点：同一个簇内的所有节点彼此等价，诱导出同一个等价类：若 $(a, b) \in R$，则 $[a] = [b]$

- 等价关系与划分的对应定理 (Partition Theorem)：
    1. 定理：设 $R$ 是非空集合 $A$ 上的等价关系，则 $R$ 的所有不同等价类构成了集合 $A$ 的一个划分 (Partition)：

        $$\Pi = \{[a] \mid a \in A\}$$

    2. 反之：集合 $A$ 的任一划分也唯一诱导出一个等价关系


**偏序集 (Partial Order / Poset)**

- 偏序关系 (Partial Ordering) ($\le$)：
    1. 同时满足自反 (Reflexive)、反对称 (Antisymmetric)、传递 (Transitive) 的二元关系
    2. 集合与偏序关系二元组 $(A, \le)$ 称为偏序集 (Partially Ordered Set / Poset)

- 经典偏序示例：
    1. 实数集上的小于等于关系 $(\mathbb{R}, \le)$
    2. 幂集上的子集包含关系 $(\mathcal{P}(S), \subseteq)$
    3. 正整数集上的整除关系 $(\mathbb{Z}^+, \mid)$（即 $a \le b \Leftrightarrow a \mid b$）

- 极值元与最值元 (Extremal Elements)：
    1. 最小元 (Least Element)：$a \in A$ 满足对所有 $b \in A$ 均有 $a \le b$（必须与所有元素可比，且小于等于一切元素；若存在则唯一）
    2. 极小元 (Minimal Element)：$a \in A$ 满足若 $b \le a \Rightarrow a = b$（集合中没有比它更小的元素；可以有多个）
    3. 最大元 (Greatest Element)：$a \in A$ 满足对所有 $b \in A$ 均有 $b \le a$（必须与所有元素可比，且大于等于一切元素；若存在则唯一）
    4. 极大元 (Maximal Element)：$a \in A$ 满足若 $a \le b \Rightarrow a = b$（集合中没有比它更大的元素；可以有多个）

- 极值元辨析示例：
    1. 集合 $S = \{\{d, o\}, \{d, o, g\}, \{g, o, a, d\}, \{o, a, f\}\}$ 按子集包含关系 $\subseteq$ 排序：
        - $\{d, o\}$：极小元（没有子集包含于它）
        - $\{g, o, a, d\}$：极大元（没有集合包含它）
        - $\{d, o, g\}$：既非极小也非极大
        - $\{o, a, f\}$：既是极小元又是极大元（与其它元素不可比，既无更小也无更大）
    2. 栅栏偏序 (Fence Poset)：形如 $a_1 < b_1 > a_2 < b_2 > a_3 \dots$，其中所有的 $a_i$ 均为极小元，所有的 $b_i$ 均为极大元


**全序集 (Total Order / Linear Order)**

- 定义：若偏序集 $(A, \le)$ 中的任意两个元素都可以进行比较，即满足全域比较性 (Total / Strongly Connected)：

    $$\forall a, b \in A, \; a \le b \lor b \le a$$

    则称该关系为全序 (Total Order)（或线序 (Linear Order)），$(A, \le)$ 称为全序集

- 全序的 4 大判定条件：
    1. 自反 (Reflexive)
    2. 传递 (Transitive)
    3. 反对称 (Antisymmetric)
    4. 全比较性 (Total / Every Pair Strongly Connected)


### Finite and Infinite Sets


**等势 (Equinumerous)**

- 定义：集合 $A$ 与 $B$ 等势 (Equinumerous) (记作 $A \sim B$)，当且仅当存在一个从 $A$ 到 $B$ 的双射 (Bijection) $f: A \to B$：

    $$A \sim B \Leftrightarrow \exists \text{ bijection } f: A \to B$$

    *注：概念上只有“等势的集合”和“双射函数”，不存在所谓“等势函数”或“双射集合”*

- 等价关系属性：等势关系 $\sim$ 是集合族上的一个等价关系 (Equivalence Relation)：
    1. 自反性 (Reflexive)：恒等映射 $I_A$ 是双射 $\Rightarrow A \sim A$
    2. 对称性 (Symmetric)：双射的逆映射 $f^{-1}$ 亦为双射 $\Rightarrow A \sim B \Rightarrow B \sim A$
    3. 传递性 (Transitive)：双射的复合 $g \circ f$ 仍为双射 $\Rightarrow A \sim B \land B \sim C \Rightarrow A \sim C$


**基数 (Cardinality)**

- 定义：基数是集合所含元素数量的度量，记作 $|A|$、$\text{card}(A)$ 或 $\#A$

- 基数相等：两集合等势当且仅当具有相同基数，即 $A \sim B \Leftrightarrow |A| = |B|$

- 广义基数 (Generalized Cardinality)：用于精确区分不同层次与规模的“无限”


**有限集与无限集 (Finite and Infinite Sets)**

- 有限集与无限集定义：
    1. 有限集 (Finite Set)：元素个数有限的集合（有限集属于可数集 (Countable Set)）
    2. 无限集 (Infinite Set)：元素个数不有限的集合

- 可数无限与不可数无限：
    1. 可数无限 (Countably Infinite)：与自然数集 $\mathbb{N}$ 等势的无限集，其基数记为阿列夫零 $\aleph_0$ (Aleph-null)：

        $$|S| = |\mathbb{N}| = \aleph_0$$

    2. 不可数无限 (Uncountably Infinite)：基数严格大于自然数集的无限集：

        $$|S| > |\mathbb{N}|$$


**希尔伯特大旅馆悖论 (Hilbert’s Paradox of the Grand Hotel)**

拥有可数无限间客房的旅馆（编号 $1, 2, 3, \dots$），客满时依然可以腾出空房接待新客人：

- 接待规则：
    1. 接待有限个新客人（$x$ 位）：
       原第 $n$ 号房客人迁至 $n + x$ 号房（$n \to n + x$），空出前 $x$ 间客房
    2. 接待可数无限个新客人：
       原第 $n$ 号房客人迁至 $2n$ 号房（$n \to 2n$），空出所有的奇数号客房（$1, 3, 5, \dots$）
    3. 接待可数无限辆巴士，每辆巴士载有可数无限个客人：
       利用素数分解的唯一性（算术基本定理）：原住客迁至 $2^n$ 号房；第 $m$ 辆巴士的第 $n$ 位客人入住第 $\text{prime}(m+1)^n$ 号房
       *理论启示*：可数无限个可数无限集的并集依然是可数无限的


**可数无限集的可数性证明 ($\mathbb{N} \times \mathbb{N}$ 是可数的)**

证明 $\mathbb{N} \times \mathbb{N}$ 与 $\mathbb{N}$ 等势（$|\mathbb{N} \times \mathbb{N}| = |\mathbb{N}|$），课件给出了 3 种典型思路：

- 3 种证明思路：
    1. 解法 1：对角线蛇形枚举法 (Cantor 对角线走法)：
       沿反向斜线按 $m + n = k$ 依次编号：$(0,0), (0,1), (1,0), (0,2), (1,1), (2,0), \dots$
    2. 解法 2：构造显式双射公式 (Cantor 配对函数 Cantor Pairing Function)：

        $$f(m, n) = \frac{1}{2}[(m+n)^2 + 3m + n]$$

    3. 解法 3：构造双向单射 (Cantor-Bernstein-Schröder 定理思想)：
        - 构造单射 $f: \mathbb{N} \to \mathbb{N} \times \mathbb{N}$，例如 $f(n) = (n, 0) \Rightarrow |\mathbb{N}| \le |\mathbb{N} \times \mathbb{N}|$
        - 构造单射 $g: \mathbb{N} \times \mathbb{N} \to \mathbb{N}$，定义 $g(m, n) = 2^m 3^n$（由算术基本定理唯一分解性可知 $g$ 为单射）$\Rightarrow |\mathbb{N} \times \mathbb{N}| \le |\mathbb{N}|$
        - 综合得到 $|\mathbb{N} \times \mathbb{N}| = |\mathbb{N}|$

- 重要推论：
    有理数集 $\mathbb{Q}$ 是可数集（每个有理数对应整数对 $(p, q)$，$\mathbb{Q} \subseteq \mathbb{Z} \times \mathbb{Z}^+$，因而可数）


**实数集的不可数性与连续统假设**

- 定理：$|\mathbb{R}| > |\mathbb{N}|$（实数集是不可数无限集，将在下节用对角线法证明）

- 开区间 $(0, 1)$ 与全体实数 $\mathbb{R}$ 等势：
    1. 构造双射证明：

        $$f(x) = \frac{1}{\pi}\arctan(x) + \frac{1}{2} \quad (f: \mathbb{R} \to (0, 1))$$

    2. *直观启示*：无穷集合的“局部真子集”可以与“全集”具有完全相同的基数（等势）

- 连续统假设 (Continuum Hypothesis / CH)：
    康托尔假说：在自然数基数 $\aleph_0$ 与实数连续统基数 $2^{\aleph_0}$ 之间，不存在任何其他的无限基数：

    $$\text{不存在 } w \text{ 满足 } \aleph_0 < w < 2^{\aleph_0}$$


**康托尔定理 (Cantor’s Theorem)**

- 定理表述：对于任意集合 $A$（无论有限还是无限），其基数严格小于其幂集的基数：

    $$\text{card}(A) < \text{card}(\mathcal{P}(A)) \quad (\text{即 } |A| < |2^A|)$$

- 核心证明（反证法）：
    - 显然存在单射 $g(x) = \{x\} \Rightarrow |A| \le |2^A|$
    - 只需证明不存在任何从 $A$ 到 $2^A$ 的满射：
        1. 假设存在满射 $f: A \to 2^A$
        2. 构造著名的对角集 (Cantor 对角集合)：

            $$B = \{x \in A \mid x \notin f(x)\}$$

            显然 $B \subseteq A$，即 $B \in 2^A$
        3. 因为假设 $f$ 是满射，所以必须存在某个元素 $t \in A$ 使得 $f(t) = B$
        4. 检验 $t$ 是否属于 $B$：
            - 若 $t \in B$，根据 $B$ 的定义必有 $t \notin f(t) = B$，矛盾
            - 若 $t \notin B$，根据 $B$ 的定义必有 $t \in f(t) = B$，亦矛盾
        5. 假设不成立，因此不存在从 $A$ 到 $2^A$ 的满射，故 $|A| < |2^A|$

- 重要推论：
    1. 自然数的幂集 $2^\mathbb{N}$ 是不可数无限集
    2. 无限存在无穷层级：$|A| < |2^A| < |2^{2^A}| < \dots$


### Three Fundamental Proof Techniques


**数学归纳法 (Principle of Mathematical Induction)**

- 定义：设 $A$ 为自然数的一个子集，若满足以下两个条件，则 $A = \mathbb{N}$：
    1. 基础步 (Basis Step)：$0 \in A$
    2. 归纳步 (Induction Step)：对于任意自然数 $n$，若 $\{0, 1, 2, \dots, n\} \subseteq A$，则必有 $n + 1 \in A$

- 形式说明：
    1. 弱归纳法 (Weak Induction)：归纳步只需假设前提 $n \in A$ 即可推出 $n + 1 \in A$
    2. 强归纳法 (Strong Induction / Complete Induction)：归纳步需假设所有先前步骤 $\{0, 1, \dots, n\} \subseteq A$ 均成立，进而推出 $n + 1 \in A$


**鸽巢原理 (Pigeonhole Principle)**

- 形式化定义：
    1. 若 $A$ 与 $B$ 均为有限集，且 $|A| > |B|$，则不存在从 $A$ 到 $B$ 的单射 (Injection)
    2. *直观描述*：将 $m$ 个物体放入 $n$ 个抽屉 (Bins)，若 $m > n$，则至少有一个抽屉包含至少两个物体

- 鸽巢原理的数学归纳法严格证明：
    对陪域基数 $|B| = n$ 进行归纳：
    1. Basis Step：$|B| = 0 \Rightarrow$ 无法定义任何函数，单射显然不存在
    2. Induction Hypothesis：假设当 $|B| \le n$ 且 $|A| > |B|$ 时，任何 $f: A \to B$ 均非单射
    3. Induction Step：考虑 $|B| = n + 1$ 且 $|A| > |B|$ 的映射 $f: A \to B$。任取 $t \in A$：
        - *Case 1*：若存在 $a \in A \setminus \{t\}$ 使得 $f(a) = f(t)$，则 $f$ 显然非单射
        - *Case 2*：若 $t$ 是唯一映射到 $f(t)$ 的元素，定义限制函数 $g: A \setminus \{t\} \to B \setminus \{f(t)\}$。
          此时 $|A \setminus \{t\}| = |A| - 1 > |B| - 1 = n$。由归纳假设可知 $g$ 不是单射，即存在 $a \neq b$ 满足 $g(a) = g(b) \Rightarrow f(a) = f(b)$，故 $f$ 亦非单射

- 典型应用：球面闭半球覆盖问题：
    - 命题：球面上任意分布的 5 个点，必然存在一个闭半球 (Closed Hemisphere) 包含其中至少 4 个点
    - 证明思路：
        1. 球面上任意两点可唯一确定一个大圆 (Great Circle)，大圆将球面精确平分为两个半球
        2. 从 5 个点中任取 2 点确定一个大圆，剩余点为 3 个
        3. 由鸽巢原理，将剩下的 3 个点放入两个半球中，至少有 $\lceil 3/2 \rceil = 2$ 个点位于同一个半球内
        4. 结合位于大圆边界上的初始 2 个点，该闭半球共包含至少 $2 + 2 = 4$ 个点


**对角线论证法 (The Diagonalization Principle)**

- 一般原理与形式化定义：
    1. 设 $R$ 是集合 $A$ 上的二元关系。定义 $R$ 的对角集 (Diagonal Set) $D$ 为：

        $$D = \{a \in A \mid (a, a) \notin R\}$$

    2. 对于每个 $a \in A$，定义行集合 $R_a = \{b \in A \mid (a, b) \in R\}$
    3. 核心定理：集合 $D$ 与族 $\{R_a \mid a \in A\}$ 中的每一个 $R_a$ 均不相同（$\forall a \in A, \, D \neq R_a$）
    4. 证明：对于任意 $a \in A$：
        - 若 $a \in D \Rightarrow (a, a) \notin R \Rightarrow a \notin R_a$
        - 若 $a \notin D \Rightarrow (a, a) \in R \Rightarrow a \in R_a$
        - 元素 $a$ 在 $D$ 与 $R_a$ 中的属于关系恰好相反，因此 $D$ 绝不可能等于 $R_a$

- 应用一：Cantor 定理的对角化统一视角：
    1. 将映射 $f: A \to 2^A$ 视作二元关系矩阵（行对应元素 $a$，列对应子集 $f(a)$ 中包含的元素）
    2. 构造对角集 $B = \{x \in A \mid x \notin f(x)\}$，由对角线原理 $B$ 必然不同于任何一行 $f(a)$，故 $f$ 绝非满射

- 应用二：实数集不可数证明（$|\mathbb{R}| > |\mathbb{N}|$）：
    - 目标：证明不存在从 $\mathbb{N}$ 到 $\mathbb{R}$ 的双射（即任何可列实数列表均无法覆盖全部实数）
    - 证明思路：
        1. 反证法：假设全体实数可数，按顺序罗列为序列 $r_0, r_1, r_2, \dots$
        2. 构造一个在对角线上处处与其相异的新实数 $d = 0.d_0 d_1 d_2 \dots$：

            $$d_n = \begin{cases} 1, & \text{若 } r_n \text{ 的第 } n \text{ 位小数为 } 0 \\ 0, & \text{若 } r_n \text{ 的第 } n \text{ 位小数不为 } 0 \end{cases}$$

        3. 对于任意 $i \in \mathbb{N}$，$d$ 的第 $i$ 位小数必然与 $r_i$ 的第 $i$ 位小数不同，从而 $d \neq r_i$
        4. 得到新实数 $d$ 不在该序列中，导出矛盾，说明实数集不可数

- 应用三：$2^\mathbb{N}$ 的不可数性：
    1. 假设 $2^\mathbb{N}$ 可列，记为 $R_0, R_1, R_2, \dots$
    2. 构造对角集 $D = \{n \in \mathbb{N} \mid n \notin R_n\}$
    3. 因为 $D \subseteq \mathbb{N} \Rightarrow D \in 2^\mathbb{N}$，但对于任意 $n$ 均有 $n \in D \Leftrightarrow n \notin R_n \Rightarrow D \neq R_n$，导出矛盾

- 思考与拓展：无限二进制序列集：
    1. 全体无限长 0-1 序列构成的集合 $T = \{0, 1\}^\omega$ 与 $2^\mathbb{N}$ 等势，因此 $T$ 是不可数集
    2. 对比：全体有限长 0-1 序列构成的集合是可数集（可数个有限集的并）


### Closures


**闭包的直观思想 (Intuitive Idea of Closure)**

- 封闭性 (Closed)：
    1. 若对集合中的任意元素施行某种运算，其运算结果依然属于该集合，则称该集合在操作下是封闭的 (Closed)
    2. 示例：自然数集 $\mathbb{N}$ 在加法 $+$ 下封闭（$\forall n, m \in \mathbb{N} \Rightarrow n + m \in \mathbb{N}$）；但在减法 $-$ 下不封闭（如 $1 - 2 = -1 \notin \mathbb{N}$）

- 闭包 (Closure)：
    1. 包含原集合且在给定操作下封闭的最小集合 (Smallest Set)
    2. 示例：整数集 $\mathbb{Z}$ 是包含 $\mathbb{N}$ 且在减法 $-$ 下封闭的最小集合，因此 $\mathbb{Z}$ 是 $\mathbb{N}$ 在减法下的闭包 (Closure)


**关系的闭包 (Closures of Relations)**

设 $R \subseteq A \times A$ 为集合 $A$ 上的二元关系，关系关于某性质 $\mathcal{P}$ 的闭包是包含 $R$ 且满足 $\mathcal{P}$ 的最小关系：

- 自反闭包 (Reflexive Closure)：
    1. 包含 $R$ 的最小自反关系，记作 $r(R)$：

        $$r(R) = R \cup I_A = R \cup \{(a, a) \mid a \in A\}$$

    2. 图论含义：为有向图中的每个节点补上自环 (Self-loop)

- 对称闭包 (Symmetric Closure)：
    1. 包含 $R$ 的最小对称关系，记作 $s(R)$：

        $$s(R) = R \cup R^{-1} = R \cup \{(b, a) \mid (a, b) \in R\}$$

    2. 图论含义：为有向图中的所有单向边补上相反方向的有向边（等价于将有向图转为无向图）

- 传递闭包 (Transitive Closure) ($R^+$)：
    1. 包含 $R$ 的最小传递关系，记作 $R^+$：
        - $R \subseteq R^+$
        - $R^+$ 是传递的 (Transitive)
        - 极小性：对任意传递关系 $R'$，若 $R \subseteq R'$，则必有 $R^+ \subseteq R'$
    2. 构造公式（两点间存在长度 $\ge 1$ 的路径）：

        $$R^+ = \bigcup_{i=1}^\infty R^i = R \cup R^2 \cup R^3 \cup \dots$$

    3. 图论含义：$(a, b) \in R^+ \Leftrightarrow$ 在有向图 $R$ 中存在一条从 $a$ 到 $b$ 的非空有向路径（长度 $\ge 1$）

- 自反传递闭包 (Reflexive Transitive Closure) ($R^*$)：
    1. 包含 $R$ 且同时具有自反性与传递性的最小关系，通常记作 $R^*$：

        $$R^* = R^+ \cup I_A = \bigcup_{i=0}^\infty R^i$$

    2. 图论含义：$(a, b) \in R^* \Leftrightarrow$ 在有向图 $R$ 中存在一条从 $a$ 到 $b$ 的有向路径（允许长度为 0，即自身到达自身）

- 典型例题与思考（亲代关系 parent-of）：
    1. 定义“亲代关系 (parent-of)”：$P = \{(x, y) \mid x \text{ 是 } y \text{ 的父母}\}$
    2. 传递闭包 $P^+$：祖先关系 (Ancestor-of)（从长辈到晚辈的直系血统传递链条）
    3. 对称闭包 $P \cup P^{-1}$：亲子血缘直连关系（包含父母到子女及子女到父母）
    4. 对称传递闭包：同一血统网络中所有相连血亲的连通关系（若补充自反性则构成共享共同祖先的血缘等价关系）


### Alphabets and Languages


**字母表 (Alphabet) ($\Sigma$)**

- 定义：任何非空有限集合称为字母表 (Alphabet)，通常用大写希腊字母 $\Sigma$ 表示

- 符号 (Symbol)：字母表中的元素称为符号 (Symbol)

- 经典示例：
    1. 二进制字母表 (Binary Alphabet)：$\Sigma = \{0, 1\}$
    2. 常见字符字母表：$\Sigma = \{a, b, c\}$
    3. 逻辑/数学符号字母表：$\Sigma = \{\leftarrow, \emptyset, \nexists, \cong, \sqrt[4]{}\}$

- *思考*：$\emptyset$ 不是通常意义下的有效字母表（退化情况下生成的语言退化）


**字符串 (Strings / Words)**

- 定义：由字母表 $\Sigma$ 中符号构成的有限序列称为 $\Sigma$ 上的字符串 (String / Word)

- 空串 (Empty String) ($e$)：
    不含任何符号、长度为 0 的特殊字符串，记作 $e$ (注：部分教材亦记作 $\epsilon$ 或 $\lambda$)

- 全体字符串集合 $\Sigma^*$：
    1. 字母表 $\Sigma$ 上所有可能生成的有限长字符串构成的集合，记作 $\Sigma^*$
    2. 记号 $w \in \Sigma^*$ 表示 $w$ 是 $\Sigma$ 上的一个字符串

- 串长 (Length) ($|w|$)：字符串所包含的符号个数，特别地 $|e| = 0$

- 串的基本操作 (Operations of Strings)：
    1. 连接 (Concatenation)：两串 $x$ 与 $y$ 的拼接记作 $x \circ y$ 或简记为 $xy$
        - 单位元性质：对任意串 $w$，有 $we = ew = w$
        - 由连接派生的子概念：子串 (Substring)、前缀 (Prefix)、后缀 (Suffix)
    2. 幂乘 (String Exponentiation) ($w^i$)：
        - 归纳定义：$w^0 = e$；对任意 $i \ge 0$，$w^{i+1} = w^i \circ w$
    3. 逆转 (Reversal) ($w^R$)：
        - 归纳定义：若 $|w| = 0$，则 $w^R = e$；若 $w = ua$（其中 $u \in \Sigma^*, a \in \Sigma$），则 $w^R = a u^R$


**语言 (Language)**

- 定义：字母表 $\Sigma$ 上任意字符串的集合称为语言 (Language)，即：

    $$L \subseteq \Sigma^*$$

- 特殊语言：
    1. 空语言 (Empty Language)：$\emptyset$（不包含任何串的语言，注意 $\emptyset \neq \{e\}$）
    2. 单位语言：$\{e\}$（仅包含空串的语言，长度为 0）
    3. 字符语言：$\Sigma$（只包含长度为 1 的单词）
    4. 全语言：$\Sigma^*$（所有串构成的集合）

- 表示方式：
    1. 有限语言 (Finite Language)：直接列出全部元素，例如 $L = \{a, ab, aab\}$
    2. 无限语言 (Infinite Language)：通过性质谓词指定：

        $$L = \{w \in \Sigma^* \mid w \text{ 具有性质 } P\}$$

        *示例*：$L = \{a^n b^n \mid n \ge 1\} = \{ab, aabb, aaabbb, \dots\}$


**$\Sigma^*$ 的可数性与基数三层关系**

- 核心定理：若 $\Sigma$ 为有限字母表，则 $\Sigma^*$ 为可数无限集 (Countably Infinite)（即 $|\Sigma^*| = \aleph_0$）

- 双射构造证明（短串优先字典序 (Shortlex / Canonical Order)）：
    固定 $\Sigma = \{a_1, a_2, \dots, a_n\}$ 的字符顺序，按照以下规则依次枚举 $\Sigma^*$ 中的所有元素：
    1. 串长短的排在前面（长度为 $k$ 的串先于长度为 $k+1$ 的串枚举）
    2. 同等长度的 $n^k$ 个串按严格字典序排列

    *以 $\Sigma = \{0, 1\}$ 为例*，枚举序列为：

    $$e, \, 0, \, 1, \, 00, \, 01, \, 10, \, 11, \, 000, \, 001, \, 010, \, 011, \dots$$

    从而构造了从 $\mathbb{N}$ 到 $\Sigma^*$ 的双射，证明了 $\Sigma^*$ 的可数性

- 三大层次基数关系（核心考点）：
    1. 非空字母表上的字符串总数：可数无限 (Countably Infinite)（$|\Sigma^*| = \aleph_0$）
    2. 任一语言 $L$ 的可数性：可数 (Countable)（作为可数集合 $\Sigma^*$ 的子集，每个语言自身都是有限集或可数无限集）
    3. 非空字母表上所有可能语言的总数：不可数无限 (Uncountably Infinite)（语言集合为幂集 $2^{\Sigma^*}$，基数等于实数连续统 $|\mathbb{R}| = 2^{\aleph_0}$）


**语言的操作 (Operations of Languages)**

- 语言操作分类：
    1. 集合操作：并集 $L_1 \cup L_2$、交集 $L_1 \cap L_2$、差集 $L_1 - L_2$、补集（相对补集 $\overline{L} = \Sigma^* - L$）
    2. 语言连接 (Concatenation) ($L_1 L_2$)：

        $$L_1 L_2 = \{w_1 w_2 \mid w_1 \in L_1 \land w_2 \in L_2\}$$

        - 性质：$L \emptyset = \emptyset L = \emptyset$；$L \{e\} = \{e\} L = L$
    3. 语言幂乘 (Exponentiation) ($L^i$)：
        - 归纳定义：$L^0 = \{e\}$；$L^{i+1} = L L^i$ 对任意 $i \ge 0$
    4. Kleene 星号闭包 (Kleene Star) ($L^*$)：
        - 任意有限次连接构成的语言（包含 0 次连接）：

            $$L^* = \bigcup_{i=0}^\infty L^i = L^0 \cup L^1 \cup L^2 \cup \dots = \{w_1 \dots w_k \mid k \ge 0, \, w_i \in L\}$$

    5. 正闭包 (Positive Closure) ($L^+$)：
        - 至少 1 次连接构成的语言（排除 0 次连接）：

            $$L^+ = L L^* = \bigcup_{i=1}^\infty L^i = L^1 \cup L^2 \cup L^3 \cup \dots = \{w_1 \dots w_k \mid k \ge 1, \, w_i \in L\}$$

        - *代数含义*：$L^+$ 是 $L$ 在串连接操作下的闭包 (Closure)（包含 $L$ 且对连接封闭的最小语言）

- 核心恒等式与性质辨析：
    1. $\emptyset^* = \{e\}$（注意：$\emptyset^* \neq \emptyset$）
    2. $\emptyset^+ = \emptyset$
    3. $L^+ = L^*$ 的充要条件：$e \in L$
    4. 闭包的幂等性：$(L^*)^* = L^*$，$(L^+)^+ = L^+$
    5. 包含单调性：$L_1 \subseteq L_2 \Rightarrow L_1^* \subseteq L_2^*$
    6. 典型题分析：若 $L = \{w \in \{0, 1\}^* \mid w \text{ 包含不等数量的 0 和 1}\}$，求 $L^*$：
        - 因 $0 \in L$ 且 $1 \in L$，故 $\{0, 1\} \subseteq L \Rightarrow \{0, 1\}^* \subseteq L^*$
        - 又因 $L^* \subseteq \{0, 1\}^*$，故 $L^* = \{0, 1\}^*$


### Finite Representations of Languages


**有限表示的必要性与核心问题 (Motivation of Finite Representations)**

- 有限语言与无限语言：
    1. 有限语言可通过直接穷举其全体元素进行有限描述
    2. 但现实与理论中绝大多数有趣的语言（如编程语言、算术表达式）均为无限集 (Infinite Set)

- 计算理论的核心问题：
    1. 能否用有限的形式规范 (Finite Specifications) 来精确表示无限的语言？
    2. 有限表示本身必须是有限长的字符串，且不同语言应有不同的表示

- 引例：
    语言 $L = \{w \in \{0, 1\}^* \mid w \text{ 包含 2 个或 3 个 1，且前两个 1 不相邻}\}$，可利用单元素集、连接、并和星号闭包紧凑书写为：

    $$0^* 1 0^* 0 1 0^* (1 0^* \cup e) \quad (\text{其中 } e = \emptyset^*)$$

    从而自然引入正则表达式 (Regular Expression)


**正则表达式的形式化归纳定义 (Regular Expressions)**

设 $\Sigma$ 为字母表，引入辅助符号集 $\{ (, ), \emptyset, \cup, * \}$：

- 定义：字母表 $\Sigma$ 上的正则表达式 (Regular Expression) 是按如下规则递归构造的有限符号串集合 $\mathcal{R}$：
    1. 基础步 (Basis Step)：
        - $\emptyset$ 是正则表达式
        - 对于任意符号 $a \in \Sigma$，$a$ 是正则表达式
    2. 归纳步 (Inductive Step)：若 $\alpha$ 与 $\beta$ 是正则表达式，则：
        - 连接 (Concatenation)：$(\alpha\beta)$ 是正则表达式
        - 并 (Union)：$(\alpha \cup \beta)$ 是正则表达式
        - 星号闭包 (Kleene Star)：$\alpha^*$ 是正则表达式
    3. 极小性 (Extremal Clause)：除有限次应用上述规则生成的符号串外，没有任何其他东西是正则表达式

- 算符优先级约定：
    1. 运算优先级为：星号 $*$ > 连接 (Concatenation) > 并集 $\cup$
    2. 在无二义性时，可省略外层括号（例如用 $\alpha\beta \cup \gamma$ 代替 $((\alpha\beta) \cup \gamma)$）


**正则表达式表示的语言 $\mathcal{L}(R)$**

正则表达式是语法结构 (Syntax)，其表示的语言是语义集合 (Semantics)。通过映射函数 $\mathcal{L}: \mathcal{R} \to 2^{\Sigma^*}$ 递归定义：

- 语义定义：
    1. $\mathcal{L}(\emptyset) = \emptyset$
    2. $\mathcal{L}(a) = \{a\} \quad (\forall a \in \Sigma)$
    3. $\mathcal{L}((\alpha\beta)) = \mathcal{L}(\alpha) \circ \mathcal{L}(\beta)$（语言连接）
    4. $\mathcal{L}((\alpha \cup \beta)) = \mathcal{L}(\alpha) \cup \mathcal{L}(\beta)$（语言并集）
    5. $\mathcal{L}(\alpha^*) = (\mathcal{L}(\alpha))^*$ (Kleene 星号闭包)

- 正则语言 (Regular Language)：
    1. 凡是能够被某个正则表达式表示的语言，称为正则语言 (Regular Language)
    2. 字母表 $\Sigma$ 上的正则语言类恰好是单元素语言集合族 $\{\{a\} \mid a \in \Sigma\} \cup \{\emptyset\}$ 在并、连接与星号闭包下的闭包

- 经典解析示例：
    1. 例 1：$\mathcal{L}((a \cup b)^* a) = \{w \in \{a, b\}^* \mid w \text{ 以 } a \text{ 结尾}\}$
    2. 例 2：分析正则表达式 $(c^* (a \cup b c^*)^*)^*$ 表示的语言：
        - 观察发现：每个 $a$ 后面只能跟下一个 $a$ 或跟 $b c^*$ 或作为末尾，绝不可能直接紧跟 $c$
        - 结论：$\mathcal{L} = \{w \in \{a, b, c\}^* \mid w \text{ 不包含子串 } ac\}$


**正则语言的理论特征与局限性 (Inadequacy of Regular Languages)**

- 能否有限表示一切语言？（基数矛盾论证）：
    1. 结论：不能
    2. 证明：
        - 所有正则表达式构成的集合 $\mathcal{R}$ 是有限字母表上的字符串集合，由前面定理可知其为可数无限集（$|\mathcal{R}| = \aleph_0$）
        - 因而所有正则语言的总数至多是可数的
        - 但 $\Sigma$ 上所有可能语言的总数是不可数无限集（基数为 $2^{\aleph_0} = |\mathbb{R}|$）
        - 因此，绝大多数语言（不可数个）是无法用正则表达式等有限规范来表示的！

- 表示的非唯一性：
    任意一个正则语言都存在无穷多个等价的正则表达式（如 $a^* = (a^*)^* = a^* \cup \emptyset = \dots$）

- 正则语言的表达局限性：
    1. 正则表达式无法记忆无限长或任意深度的计数配对关系
    2. 典型反例：$L = \{0^n 1^n \mid n \ge 0\}$ 不是正则语言（无法由任何正则表达式表示）


**语言规范的两大基本机制：识别器与生成器**

- 语言识别器 (Language Recognition Devices)：
    1. 机制：被动接受一个待测字符串 $w$，判定其是否属于语言 $L$（判定“$w \in L$?”，回答 Yes 或 No）
    2. 运作范式（以识别不含连续 3 个 1 的语言为例）：
        - 从左至右逐字符扫描输入串；
        - 维护一个计数器：遇 0 清零，遇 1 递增；
        - 一旦计数器达到 3，立即停机输出 No（拒绝）；若扫描结束计数器从未达 3，停机输出 Yes（接受）
    3. 计算理论对应：自动机模型（有限自动机 DFA/NFA、下推自动机 PDA、图灵机 Turing Machine）

- 语言生成器 (Language Generators)：
    1. 机制：主动提供一套规则，用于直接系统性地构造/派生出该语言中的合法样本
    2. 运作范式（以正则表达式 $(e \cup b \cup bb)(a \cup ab \cup abb)^*$ 为例）：
        - 步骤 1：先写出空串 $e$、或 $b$、或 $bb$
        - 步骤 2：接着写出 $a$、或 $ab$、或 $abb$，可重复任意多次（含 0 次）
        - 所有且仅有通过该过程产生的串构成语言 $L$
    3. 计算理论对应：形式文法模型（正则文法、上下文无关文法 CFG）


### Exercises


**习题 1.7.4：语言恒等式证明 (Language Identities)**

1. (a) 证明 $\{e\}^* = \{e\}$：
    - 根据星号闭包定义：$\{e\}^* = \bigcup_{i=0}^\infty \{e\}^i = \{e\}^0 \cup \{e\}^1 \cup \dots$
    - 由于对任意 $i \ge 0$ 均有 $\{e\}^i = \{e\}$，故全并集为 $\{e\}$

2. (b) 证明对任意字母表 $\Sigma$ 及任意语言 $L \subseteq \Sigma^*$，有 $(L^*)^* = L^*$：
    - 包含方向 $\subseteq$：$(L^*)^*$ 中的任意元素 $w$ 是 $L^*$ 中有限个串的连接，而 $L^*$ 中的每个串又是 $L$ 中有限个串的连接；由连接的结合律可知 $w$ 本质上是 $L$ 中有限个串的连接，因此 $w \in L^*$
    - 包含方向 $\supseteq$：显然 $L^* \subseteq (L^*)^*$（对应星号展开中的 1 次连接）
    - 综上，$(L^*)^* = L^*$（星号闭包的幂等性）

3. (c) 若 $a, b$ 为不同符号，证明 $\{a, b\}^* = \{a\}^* (\{b\}\{a\}^*)^*$：
    - 即证明正则表达式恒等式 $(a \cup b)^* = a^*(ba^*)^*$
    - 任意由 $a, b$ 构成的串均可唯一划分为：开头可能存在的若干个 $a$（由前面的 $a^*$ 生成），随后跟随零个或若干个“以单个 $b$ 起始紧跟若干个 $a$”的块（由 $(ba^*)^*$ 生成）

4. (d) 若 $e \in L_1 \subseteq \Sigma^*$ 且 $e \in L_2 \subseteq \Sigma^*$，证明 $(L_1 L_2)^* = (L_1 \cup L_2)^*$：
    - 因为 $e \in L_2$，故 $L_1 = L_1 \{e\} \subseteq L_1 L_2$；同理 $e \in L_1 \Rightarrow L_2 = \{e\} L_2 \subseteq L_1 L_2$
    - 由此可得 $L_1 \cup L_2 \subseteq L_1 L_2 \subseteq (L_1 \cup L_2)(L_1 \cup L_2) = (L_1 \cup L_2)^2$
    - 对各部分取星号闭包：$(L_1 \cup L_2)^* \subseteq (L_1 L_2)^* \subseteq ((L_1 \cup L_2)^2)^* = (L_1 \cup L_2)^*$，故二者相等

5. (e) 证明对任意语言 $L$，有 $\emptyset L = L \emptyset = \emptyset$：
    - 根据语言连接定义：$\emptyset L = \{w_1 w_2 \mid w_1 \in \emptyset \land w_2 \in L\}$
    - 由于空集 $\emptyset$ 不包含任何元素，前件条件永不成立，因此连接结果必为空集 $\emptyset$


**习题 1.7.6：$L^+ = L^* - \{e\}$ 的充要条件**

- 结论：$L^+ = L^* - \{e\}$ 当且仅当 $e \notin L$

- 证明过程：
    1. 充分性（若 $e \notin L \Rightarrow L^+ = L^* - \{e\}$）：
        - 由定义 $L^* = L^+ \cup \{e\}$，故只需证明 $e \notin L^+$
        - 反证法：若 $e \in L^+$，则存在 $k \ge 1$ 个串 $w_1, \dots, w_k \in L$ 满足 $w_1 \dots w_k = e$。因各串长度非负，必有 $|w_1| = \dots = |w_k| = 0$，即每个 $w_i = e \in L$，与前提 $e \notin L$ 矛盾！因此 $e \notin L^+$ 成立
    2. 必要性（若 $L^+ = L^* - \{e\} \Rightarrow e \notin L$）：
        - 反证法：若 $e \in L$，则 $e \in L^1 \subseteq L^+$，这意味着 $e \in L^+$
        - 但右侧集合 $L^* - \{e\}$ 显式排除了 $e$，二者不可能相等，矛盾！故必有 $e \notin L$


**习题 1.8.3：构造正则表达式 (Regular Expressions Construction)**

设字母表 $\Sigma = \{a, b\}$：

1. (a) 至多包含 3 个 $a$ 的所有字符串：
    - 允许出现的 $a$ 的个数为 0、1、2 或 3，其余位置可填任意数量的 $b$：

        $$b^* \cup b^* a b^* \cup b^* a b^* a b^* \cup b^* a b^* a b^* a b^*$$

    - *紧凑等价形式*：$b^* (a \cup e) b^* (a \cup e) b^* (a \cup e) b^*$

2. (b) 包含的 $a$ 的个数能被 3 整除的所有字符串：
    - 注意：包含 0 个 $a$ 亦属于被 3 整除
    - 基本重复单元为“包含 3 个 $a$ 的模式”，外部与内部均可插入任意 $b$：

        $$b^* (a b^* a b^* a b^*)^*$$

3. (c) 恰好出现一次子串 $aaa$ 的所有字符串：
    - 要求：不仅必须包含子串 $aaa$，且该子串不能与前后多余的 $a$ 拼接形成重叠（如 $aaaa$），也不能在其他位置再次出现 $aaa$
    - 正则表达式规范：

        $$((a \cup aa \cup b)^* b)^* \, aaa \, (b (b^* (a \cup aa \cup b^*))^*)^*$$


**习题 1.8.5：判断题与解析 (True or False Explanations)**

1. (a) $baa \in a^* b^* a^* b^*$
    - 答案：True
    - 解析：取第一个 $a^*$ 为 $e$（0 次）、$b^*$ 为 $b$、第二个 $a^*$ 为 $aa$、第二个 $b^*$ 为 $e$，即 $e \cdot b \cdot aa \cdot e = baa$，属于该语言

2. (b) $b^* a^* \cap a^* b^* = a^* \cup b^*$
    - 答案：True
    - 解析：
        - $a^* b^*$ 仅包含“所有 $a$ 都在 $b$ 前面”的串（形如 $a^i b^j$）
        - $b^* a^*$ 仅包含“所有 $b$ 都在 $a$ 前面”的串（形如 $b^m a^n$）
        - 任何同时包含至少一个 $a$ 与一个 $b$ 的串无法同时满足两种顺序；因此交集中的串只能是纯 $a$ 串（$a^*$）或纯 $b$ 串（$b^*$），故交集为 $a^* \cup b^*$

3. (c) $a^* b^* \cap b^* c^* = \emptyset$
    - 答案：False
    - 解析：当两边都取 $a, c$ 为 0 次时，两集合均包含纯 $b$ 构成的串：$b^* \subseteq a^* b^*$ 且 $b^* \subseteq b^* c^*$，特别地空串 $e \in a^* b^* \cap b^* c^*$。因此交集非空（实际交集即为 $b^*$）

4. (d) $abcd \in (a(cd)^*)^*$
    - 答案：False
    - 解析：正则表达式 $(a(cd)^*)^*$ 所能产生的所有字符串中完全不包含字符 $b$（该表达式的底层字母表仅为 $\{a, c, d\}$），因此字符串 $abcd$ 绝不可能由该表达式生成
