# 计算机体系结构期末考试半开卷 Cheat Sheet

本 Cheat Sheet 专为期末半开卷考试（双面 A4 纸）设计。内容完全基于历年真题（`22-23`、`24-25 春夏`、`24-25 秋冬`）的实际高频考点与解题大题模板进行二次提炼与校验。

---

## 第一部分：定量设计基础与性能度量（分值占比：16%）

### 1. 历史物理规律与架构转型
* **Dennard 缩放定律（Dennard Scaling）**：2004 年左右失效。漏电流随特征尺寸缩小而急剧增大，芯片电压和电流无法继续成正比下降，热功耗密度达到极限（Power Wall）。
* **摩尔定律（Moore's Law）**：集成电路上可容纳的晶体管数目约每两年便会增加一倍（2015 左右失效）。
* **并行模式划分（Flynn's Taxonomy）**：

| 分类名称 | 物理实质 | 对应架构 / 章节发掘重点 |
| :--- | :--- | :--- |
| **SISD** | 单指令单数据流 | 传统单核标量 CPU，主要发掘指令级并行（ILP） |
| **SIMD** | 单指令多数据流 | 向量处理器、GPU、多媒体扩展，发掘数据级并行（DLP） |
| **MISD** | 多指令单数据流 | 理论存在，商业无实现 |
| **MIMD** | 多指令多数据流 | 多核心多线程系统，主要发掘线程级并行（TLP）/ 任务并行 |

### 2. 性能度量与 CPU 时间公式
* **CPU 时间核心公式**：
  $$\text{CPU Time} = \text{Instruction Count} \times \text{CPI} \times \text{Clock Cycle Time} = \frac{\text{Instruction Count} \times \text{CPI}}{\text{Frequency}}$$
* **时钟频率与 CPI 变动性能比值（真题高频选择题）**：
  $$\text{Speedup} = \frac{\text{CPU Time}_{\text{old}}}{\text{CPU Time}_{\text{new}}} = \frac{\text{CPI}_{\text{old}} \times F_{\text{new}}}{\text{CPI}_{\text{new}} \times F_{\text{old}}}$$
  *真题算例：1.8GHz 变 2.2GHz，CPI 从 1.2 变 1.5。$\text{Speedup} = \frac{1.2 \times 2.2}{1.5 \times 1.8} = \frac{2.64}{2.70} \approx 0.9778 \implies$ 性能变化为 $-2.22\%$（下降）。*

### 3. 阿姆达尔定律（Amdahl's Law）多核分配计算（真题大题）
* **多核心分配公式**：若并行比例为 $f$（串行占比 $1-f$）。在并行区内，有部分比例 $f_A$ 运行在 $P_A$ 个核上，部分比例 $f_B$ 运行在 $P_B$ 个核上：
  $$\text{Speedup}_{\text{overall}} = \frac{1}{(1 - f) + \frac{f_A}{P_A} + \frac{f_B}{P_B}}$$
* **真题演算（24-25 春夏）**：可并行部分占 95%（$f=0.95$，串行占 5%）。分配给 100 个核心与 50 个核心。已知 100 核心能承载绝大部分计算。求运行在 50 核心上的比例 $x$（占总程序比例）应为多少，才能使整体加速比达到 80？
  * 解：若 $x$ 为占总程序比例，则运行在 100 核心的比例为 $0.95 - x$。
    $$\text{Speedup} = \frac{1}{0.05 + \frac{0.95 - x}{100} + \frac{x}{50}} = 80 \implies 0.05 + 0.0095 - 0.01x + 0.02x = 0.0125$$
    $$0.0595 + 0.01x = 0.0125 \implies 0.01x = -0.047 \implies x < 0 \text{ （无物理实数解）}$$
    *考场应对提示：若题目给定的 Speedup 目标（如 80）超过了阿姆达尔极限 $\frac{1}{1-f}$（若 $f=0.95$，最高加速比仅为 20；要达到 80，串行比例 $1-f$ 必须小于 $1.25\%$，即 $f > 98.75\%$），请务必在答卷上指出该极限，并检查题目中的串行比例数字是否是 $1\%$ 或更小。*

### 4. ISA 分类与操作数寻址
* **代码序列对照表（计算 $C = A + B$，真题常考选择题）**：

| 堆栈架构 (Stack) | 累加器架构 (Accumulator) | 寄存器-内存架构 (Reg-Mem) | 载入-存储架构 (Load-Store) |
| :--- | :--- | :--- | :--- |
| `Push A` | `Load A` | `Load R1, A` | `Load R1, A` |
| `Push B` | `Add B` | `Add R3, R1, B` | `Load R2, B` |
| `Add` | `Store C` | `Store R3, C` | `Add R3, R1, R2` |
| `Pop C` | | | `Store R3, C` |

* **三种基本寻址模式**：寄存器寻址（`add x1, x2, x3`）、立即数寻址（`addi x1, x2, 100`）、偏移量寻址（`lw x1, 100(x2)`）。

---

## 第二部分：存储层次结构（分值占比：28%）

### 1. Cache 地址位与容量大题计算（真题大题）
* **地址线划分公式**：
  $$\text{Address Width} = \text{Tag} + \text{Index} + \text{Offset}$$
  * $\text{Offset (块偏移)} = \log_2(\text{Block Size})$
  * $\text{Index (组索引)} = \log_2(\text{Sets})$
  * $\text{Sets (组数)} = \frac{\text{Cache Capacity}}{\text{Block Size} \times \text{Associativity}}$
  * **VIPT（虚拟索引物理标记）无别名约束条件**：
    $$\text{Index} + \text{Offset} \le \text{Page Offset 位数} \implies \frac{\text{Cache Capacity}}{\text{Associativity}} \le \text{Page Size}$$
* **真题演练一（24-25 秋冬大题）**：地址按字节寻址。Cache 容量为 8KB，共 1024 个 Set，采用 4 路组相联。
  * **块大小（Cache Line Size）计算**：
    $$\text{Block Size} = \frac{\text{Capacity}}{\text{Sets} \times \text{Associativity}} = \frac{8 \times 1024 \text{ 字节}}{1024 \times 4} = 2 \text{ 字节}$$
  * **局部性判定**：因为块大小（2字节）小于普通单精度数据字宽（4字节），单次访存无法一次性载入完整的数据字，因此**无法提供良好的空间局部性（Spatial Locality）**。
* **真题演练二（22-23 选择题）**：虚拟地址 46 位，物理地址 36 位，页大小 8KB（$\implies$ 偏移 13 位），Cache 容量 16KB，求不同配置下的 Tag 位数：
  * **配置 A：直接映射**，块大小 64B（$\implies$ Offset=6位）。Sets = $16\text{KB}/64\text{B} = 256 \implies$ Index=8位。Tag = $36 - 8 - 6 = 22$ 位。
  * **配置 B：8路物理寻址**，块大小 64B。Sets = $16\text{KB}/(8 \times 64\text{B}) = 32 \implies$ Index=5位。Tag = $36 - 5 - 6 = 25$ 位。
  * **配置 C：VIPT 2路组相联**，块大小 64B。Sets = $16\text{KB}/(2 \times 64\text{B}) = 128 \implies$ Index=7位。Tag = $36 - 7 - 6 = 23$ 位。

### 2. ZJU 经典必考两级缓存计算题（“5.4 与 6.6”题型）
* **真题情境**：1000 次访存参考中，L1 发生 40 次 Miss，L2 发生 20 次 Miss。L2 命中时间 10 周期，L2 到主存 Miss 惩罚 200 周期，L1 命中时间 1 周期。每条指令平均进行 1.5 次访存参考。
  1. **平均内存访问时间（AMAT）计算**：
     * L1 Miss Rate = $40 / 1000 = 4\%$。L2 本地 Miss Rate = $20 / 40 = 50\%$。
     * $\text{AMAT} = \text{Hit}_{\text{L1}} + \text{Miss}_{\text{L1}} \times (\text{Hit}_{\text{L2}} + \text{Local Miss}_{\text{L2}} \times \text{Penalty}_{\text{L2}}) = 1 + 0.04 \times (10 + 0.50 \times 200) = 1 + 0.04 \times 110 = 5.4$ 周期。

     5.4周期

  2. **每指令平均访存挂起周期数（Stalls/Instruction）**：
     * 挂起周期/访存 = $\text{AMAT} - 1 = 4.4$ 周期。
     * 每指令挂起周期 = 访存次数/指令 $\times$ 挂起周期/访存 = $1.5 \times 4.4 = 6.6$ 周期。

### 3. Cache 优化手段汇总对照表

| 优化技术名称 | 降低不命中率 (MR) | 降低不命中开销 (MP) | 减少命中时间 (HT) | 增加 Cache 带宽 (BW) |
| :--- | :---: | :---: | :---: | :---: |
| 1. 增大块大小 (Block Size) | $\checkmark$ (空间局部性) | $\times$ (增加传输时间) | | |
| 2. 增大 Cache 容量 | $\checkmark$ (减少容量不命中) | | $\times$ (延迟变长) | |
| 3. 提高相联度 (Associativity) | $\checkmark$ (减少冲突不命中) | | $\times$ (逻辑变复杂) | |
| 4. 多级缓存 (Multilevel Cache) | | $\checkmark$ (L2 拦截) | | |
| 5. 非阻塞缓存 (Nonblocking) | | $\checkmark$ (隐藏 Miss 延迟) | | $\checkmark$ |
| 6. 小而简单的 L1 Cache | | | $\checkmark$ | |
| 7. 流水化 Cache 访问 | | | | $\checkmark$ |
| 8. 编译优化 (分块/交换) | $\checkmark$ | | | |

### 4. 访存冲突抖动与写回延迟（大题必考模板）
* **真题情境**：循环 `c[i] = a[i] * b[i] + b[i]`（地址 0, 2048, 4096，元素 4 字节）。Cache 容量 2048 字节直接映射，块大小 64 字节（$\implies$ 16个元素/块）。Miss 罚 100 周期，写回 100 周期。
  * **冲突抖动分析**：由于 $a, b, c$ 起始地址模 Cache 容量均为 0，它们在 Cache 中映射为**同一行**。每次迭代依次访问 $a[i]$ (Miss 换入 $a$ 覆盖脏的 $c \implies$ 写回+调入)、$b[i]$ (Miss 换入 $b$ 覆盖 $a$)、写 $c[i]$ (Miss 调入 $c$ 覆盖 $b$)。全部不命中。
  * **大题计算公式（512次迭代）**：
    $$\text{Stall per iteration} = \frac{512 \times 100\text{(a 读Miss)} + 512 \times 100\text{(b 读Miss)} + 512 \times 100\text{(c 写Miss)} + 511 \times 100\text{(c 替换写回)}}{512} \approx 400 \text{ 周期}$$

---

## 第三部分：指令级并行与动态调度（分值占比：28%）

### 1. 分支预测器与延迟惩罚
* **空间计算**：$(m, n)$ 关联预测器有 $N$ 个项：$\text{Total Bits} = 2^m \times n \times N$。*(2,2预测器+4K项占 32Kbits)*
* **2-bit 饱和计数器循环 Miss Rate 追踪（真题常考）**：
  对 $T, T, NT$ 循环，稳定状态下：$3k+1$ 次（状态 10，预测 T 实际 T，正确）；$3k+2$ 次（状态 11，预测 T 实际 T，正确）；$3k$ 次（状态 11，预测 T 实际 NT，错误）。**Miss Rate = 33.3%**。
* **分支延迟惩罚（Branch Penalty）物理实质**：
  若分支条件和目标地址在 **EXE 阶段结束时**才确定：
    * 预测不跳转，实际不跳转 $\implies$ 惩罚为 0 周期。
    * 预测不跳转，实际跳转 $\implies$ 惩罚为 2 周期（需要清空前 2 级载入的指令）。
    * **预测跳转，且实际跳转 $\implies$ 惩罚为 2 周期**。（因为目标地址要到 EXE 结束才算出来，期间无法从目标地址取指，仍需挂起 2 周期）。

### 2. 记分牌与 Tomasulo 挂起时机对比（选择题常考）
* **Scoreboard**：**Issue 阶段挂起防 WAW**；**Read Operands 阶段挂起等 RAW**；**Write Result 阶段挂起防 WAR**。
* **Tomasulo**：利用**寄存器重命名（RS 编号）**在硬件上直接消除了 WAR 和 WAW 冲突，因此这两阶段不挂起。仅在 **Execution 阶段等待 RAW**（监听 CDB 广播）。

### 3. 带投机（Speculation）的 Tomasulo 与 ROB 四阶段规则
* **Issue（发射）**：RS 有空余 **且** ROB 有空余。分配 ROB 编号（$ROB\_ID$）。
* **Execute（执行）**：监听 CDB 或从寄存器/ROB 读值。
* **Write Result（写结果）**：执行完毕，将值和 $ROB\_ID$ 广播至 CDB。写入 ROB，**释放保留站（RS）**。
* **Commit（顺序提交）**：在 ROB 队列头部按程序顺序提交，将结果写入寄存器，释放 ROB 槽位。

### 4. 动态调度流水线填表大题（10分大题必考解题模板）
* **指令流**：I1 (div x2, x3, x4), I2 (mul x1, x5, x6), I3 (add x3, x7, x8), I4 (mul x1, x1, x3), I5 (sub x4, x1, x5), I6 (sub x1, x4, x2)。Add 1 拍，Mul 10 拍，Div 40 拍。
* **记分牌（Scoreboard）填表周期对照表**：
    * I1：Issue: 1, Read: 2, Exec: 3-42, Write: 43.
    * I2：Issue: 2. Read: 3 (x5, x6 均 ready). Exec: 4-13. Write: 14.
    * I3：Issue: 3. Read: 4. Exec: 5. Write: 6.
    * I4：因与 I2 目的寄存器均为 x1（**WAW 冲突**），必须等 I2 在 14 拍 Write 后才能 Issue！
        * Issue: 14. Read: 15 (x1 在 14 拍写回，x3 在 6 拍写回). Exec: 16-25. Write: 26.
    * I5：Issue: 15. Read: 27 (等待 I4 在 26 拍 Write). Exec: 28. Write: 29.
    * I6：因 sub 部件被 I5 占用（**结构冲突**），等 I5 在 29 拍 Write 释放。且 I6 读 x2 依赖 I1（43拍写回）。
        * Issue: 30. Read: 44 (x2 在 43 拍 Write，下一拍才能读). Exec: 45. Write: 46.
* **带投机 Tomasulo (ROB) 填表周期对照表**（RS 广播后释放）：
    * I1：Issue: 1, Exec: 2-41, Write: 42, Commit: 43.
    * I2：Issue: 2. Exec: 3-12. Write: 13. Commit: 44 (顺序提交).
    * I3：Issue: 3. Exec: 4. Write: 5. Commit: 45.
    * I4：因 mul 保留站被占，等 I2 在 13 拍 Write 后释放。
        * Issue: 14. Exec: 15-24 (操作数均就绪). Write: 25. Commit: 46.
    * I5：Issue: 15. Exec: 26 (等待 I4 的 x1 在 25 拍 Write 并前递). Write: 27. Commit: 47.
    * I6：因 sub 保留站被 I5 占用，等 I5 在 27 拍 Write 后释放。
        * Issue: 28. Exec: 43 (等待 I1 的 x2 在 42 拍 Write 并前递). Write: 44. Commit: 48.

### 5. 循环数据依赖判定与寄存器重命名（24-25 秋冬大题）
* **真题情境**：分析以下循环体的依赖关系，并利用寄存器重命名重写以消除 WAW/WAR 冲突：
  ```c
  for (i=0; i<99; i=i+1) {
      A[i] = A[i] * B[i];     /* S1 */
      B[i] = A[i] + c;        /* S2 */
      A[i] = C[i] * c;        /* S3 */
      C[i] = D[i] + A[i];     /* S4 */
  }
  ```
  * **依赖分析**：
    * **RAW（真相关）**：S2 读 `A[i]`（依赖 S1 写入）；S4 读 `A[i]`（依赖 S3 写入）。
    * **WAR（反相关）**：S2 写 `B[i]`（S1 读 `B[i]` 先执行）；S3 写 `A[i]`（S2 读 `A[i]` 先执行）；S4 写 `C[i]`（S3 读 `C[i]` 先执行）。
    * **WAW（输出相关）**：S1 与 S3 均写入 `A[i]`。
  * **寄存器重命名消除方案**（引入临时变量 `t1`, `t2` 消除名字相关）：
    ```c
    for (i=0; i<99; i=i+1) {
        t1 = A[i] * B[i];     /* S1: 消除针对 A[i] 的 WAW */
        B[i] = t1 + c;        /* S2 */
        t2 = C[i] * c;        /* S3 */
        C[i] = D[i] + t2;     /* S4 */
        A[i] = t2;            /* 最终写回 A[i] */
    }
    ```

---

## 第四部分：数据级并行（DLP）与向量/GPU 架构（分值占比：10%）

### 1. 向量指令护航组（Convoy）划分大题（真题核心）
* **划分规则**：
  * 若两条指令使用相同的流水化功能部件，或者系统只有一个内存端口且两条都是访存指令 $\to$ 必须划分到不同护航组。
  * **若系统支持链接（Chaining）**，存在 RAW 相关的指令**可以放入同一个护航组**并发流水线执行。
* **真题划分算例（单内存端口）**：
  ```assembly
  vld v1, x1        ; 载入 -> Convoy 1
  vadd v3, v1, v2   ; 加法 -> Convoy 1 (真相关 v1 链接)
  vld v4, x2        ; 载入 -> Convoy 2 (内存端口结构冲突)
  vmul v5, v4, v3   ; 乘法 -> Convoy 2 (真相关 v4 链接)
  vsd v5, x3        ; 存储 -> Convoy 3 (内存端口结构冲突)
  ```
  * 结论：共划分为 **3 个护航组**。

### 2. 向量执行时钟周期计算公式
* **单护航组执行周期**：$\text{Time}_{\text{convoy}} = T_{\text{startup}} + N - 1$。
* **无链接（No Chaining）总周期**：各指令完全串行（每条指令是一个独立护航组）：
  $$\text{Total Time} = \sum (\text{Startup Latency}_i + N - 1)$$
  *算例（N=64，载入/存储启动延迟 6 拍，加法 9 拍，乘法 12 拍）：*
    * 无链接总周期 = $(6 + 64 - 1)\text{ (vld)} + (9 + 64 - 1)\text{ (vadd)} + (6 + 64 - 1)\text{ (vld)} + (12 + 64 - 1)\text{ (vmul)} + (6 + 64 - 1)\text{ (vsd)} = 354$ 周期。
* **有链接（Chaining，链接延迟 1 拍）总周期**：
    * Convoy 1（`vld` 链接到 `vadd`）：延迟为 $6 + 9 = 15$ 拍。$\text{Time}_1 = 15 + 64 - 1 = 78$ 周期。
    * Convoy 2（`vld` 链接到 `vmul`）：延迟为 $6 + 12 = 18$ 拍。$\text{Time}_2 = 18 + 64 - 1 = 81$ 周期。
    * Convoy 3（`vsd`）：延迟为 6 拍。$\text{Time}_3 = 6 + 64 - 1 = 69$ 周期。
    * **有链接总周期** = $78 + 81 + 69 = 228$ 周期。

### 3. 512-bit 向量指令执行时钟周期计算（真题常考选择题）
* **真题情境（22-23）**：数组 `a`, `b`, `c` 分别有 524 个 8 字节宽的整数元素。Scalar 加法需要 1 拍，512 位宽的向量加法指令需要 4 拍。求使用 512 位向量加法指令完成加法运算所需的时钟周期数。
    * **解题步骤**：
        * 向量加法寄存器单条指令处理元素个数 = $512\text{ bits} / (8\text{ bytes} \times 8\text{ bits}) = 8$ 个。
        * 需要执行的向量加法指令数 = $\lceil 524 / 8 \rceil = 66$ 条。
        * 总时钟周期 = $66 \text{ 条} \times 4 \text{ 拍/条} = 264$ 周期。

### 4. 互连网络核心分类与考点（选择题高频）
* **单级互连网络函数定义**（$n = \log_2 N$）：
    * **Cube 函数**：第 $i$ 维取反：$Cube_i(P_{n-1} \dots P_i \dots P_0) = P_{n-1} \dots \overline{P_i} \dots P_0$。最大传输步数 = $n$。
    * **PM2I 函数**：加减 $2^i \pmod N$ 映射。
    * **Shuffle（混洗）函数**：二进制位循环左移一位：$\text{Shuffle}(P_{n-1} P_{n-2} \dots P_0) = P_{n-2} \dots P_0 P_{n-1}$。
    * **Exchange（交换）函数**：二进制最低位取反（即 $Cube_0$）。
    * **混洗交换网络最远步数** = $2n - 1$。
* **Omega 多级网络与多级 Cube 网络的差异点**：
    * **信号流向不同**：Omega 为高位到低位（$n-1 \to 0$）；Cube 为低位到高位（$0 \to n-1$）。
    * **开关状态不同**：Omega 采用四功能控制开关（包含上/下广播）；Cube 仅使用双功能（直通/交叉）开关。
    * **广播能力不同**：Omega 具有一对多广播能力；Cube 无。

### 5. GPU SIMT 架构名词对照与分支分歧
* **SIMT（单指令多线程）物理层级映射对照表**：

| GPU 线程硬件层级 | CPU / 向量架构等价物 | 物理作用 |
| :--- | :--- | :--- |
| **Grid（网格）** | 外部循环 / 任务块 | 包含该 GPU 核运行的全部线程 |
| **Thread Block（线程块）** | 向量循环段 / 向量块 | 映射至多核处理器（SM）上，块内共享 Shared Memory |
| **Warp（线程束，32线程）** | 向量寄存器长度（如 VL=32） | 硬件调度的基本单位，32 个线程必须同步执行同一条指令 |
| **Thread（线程）** | 向量中的单个元素通道 | 独立的程序计数器（PC）虚拟逻辑通道 |

* **分支分歧（Branch Divergence）**：Warp 内 32 个线程执行到条件分支指令（如 `if-else`），部分线程走 `if` 路径，部分走 `else` 路径。GPU 硬件通过**分支分歧同步栈**，将不满足条件的分支线程 Mask 屏蔽置零，串行地执行两条路径，**导致该段代码执行效率减半**。

---

## 第五部分：线程级并行（TLP）与多核一致性（分值占比：18%）

### 1. 共享内存系统架构分类与概念（选择题高频）
* **UMA（均匀内存访问）**：物理内存被所有核心均匀共享，各处理器访问任意物理地址的延迟和带宽均等。又称对称多处理器（SMP）。
* **NUMA（非均匀内存访问）**：物理内存分布式部署在各个节点，访问本地节点内存速度快，访问远程节点内存慢。
* **COMA（仅缓存内存访问）**：不设静态主存，各节点的数据存储空间均作为 Cache 使用，数据块在访问时通过目录协议动态迁移。
* **一致性（Coherence）与连贯性（Consistency）区别**：
    * **Coherence（一致性）**：规定对**同一个内存单元（Single location）**的读写行为（确保读能返回最新写的数据）。
    * **Consistency（连贯性）**：规定对**不同内存单元**的读写操作对其他核心可见的相对顺序（如顺序一致性 SC，松弛模型等）。
    * **一致性不命中（Coherency Miss）**：由于总线监听或失效机制导致本地 Cache 块失效而产生的不命中。**单核 CPU 中不存在 Coherency Miss，仅有 3C (Compulsory, Capacity, Conflict)**。
* **写失效（Write Invalidate）与写更新（Write Update/Broadcast）**：
    * 写失效：写数据时，将其他 cache 中的副本置为 Invalid。**占用总线带宽小，流量低，应用最广**。
    * 写更新：写数据时，将新数据广播更新到其他所有的 cache。读延迟小，但极其消耗总线带宽。

### 2. MESI 协议状态转移表（大题必考）
* **状态定义**：
    * **M (Modified, 已修改)**：块已变脏，且本 Cache 独占。
    * **E (Exclusive, 独占)**：块与内存数据一致，且本 Cache 独占。
    * **S (Shared, 共享)**：块与内存数据一致，其他 Cache 可能也持有副本。
    * **I (Invalid, 失效)**：本 Cache 中无该数据块。

* **MESI 协议状态转移矩阵**：

| 当前状态 | 本地读 (PrRd) | 本地写 (PrWr) | 监听读 (BusRd) | 监听写 (BusRdX / Invalidate) |
| :--- | :--- | :--- | :--- | :--- |
| **I (失效)** | $\to$ **S** (有他人持有)<br>$\to$ **E** (无人持有) | $\to$ **M** (发 BusRdX/写失效) | 保持 **I** | 保持 **I** |
| **S (共享)** | 保持 **S** | $\to$ **M** (发 Invalidate) | 保持 **S** | $\to$ **I** (数据失效) |
| **E (独占)** | 保持 **E** | $\to$ **M** (无总线动作) | $\to$ **S** (写回内存) | $\to$ **I** (数据失效) |
| **M (脏)** | 保持 **M** | 保持 **M** | $\to$ **S** (脏块写回内存) | $\to$ **I** (脏块写回并失效) |

* **历年转移大题追踪（I 状态起步）**：
    1. `P0 read a` $\to$ P0: **E** (无人持有)。
    2. `P1 read a` $\to$ P0: **S**, P1: **S** (有人持有，转 Shared)。
    3. `P2 read a` $\to$ P0: **S**, P1: **S**, P2: **S**。
    4. `P3 write a` $\to$ P3 发 Invalidate 信号 $\to$ P0/P1/P2 全部转 **I**，P3 转 **M**。
    5. `P0 read a` $\to$ P3 监听到读，将脏块写回内存并转 **S**，P0 从总线获取数据并转 **S**。目前：P0: **S**, P3: **S**。

### 3. 目录协议（Directory Protocol）消息传递流大题（10分大题必考图）
* **物理节点角色**：
    * 本地节点（Local Node）：发出读写请求的节点。
    * 主节点（Home Node）：该物理内存块及目录（Directory）所在的节点。
    * 拥有者节点（Owner Node）：当前独占（E/M状态）持有该数据块的 Cache 节点。
* **四大核心消息传递时序模板**：
  1. **读不命中（Read Miss），目标块在主节点呈 Shared / Uncached 状态**：
     * Local $\xrightarrow{\text{ReadMiss}}$ Home
     * Home 读取内存，修改目录为 $\text{Shared}$，Sharer 集合加入 $\{\text{Local}\}$
     * Home $\xrightarrow{\text{DataReply}}$ Local （返回数据值）
     * Local 收到数据，Cache 状态转为 **S**
  2. **读不命中（Read Miss），目标块在 Owner 节点呈 Exclusive / Modified 状态**：
     * Local $\xrightarrow{\text{ReadMiss}}$ Home
     * Home 检查目录发现块被 Owner 独占 $\to$ Home $\xrightarrow{\text{Fetch}}$ Owner
     * Owner 收到 Fetch，将数据写回主存，Cache 状态由 **E/M $\to$ S**
     * Home 接收写回数据更新主存，修改目录为 $\text{Shared}$，Sharer 集合置为 $\{\text{Local, Owner}\}$
     * Home $\xrightarrow{\text{DataReply}}$ Local （返回数据值）
     * Local 接收数据，Cache 状态转为 **S**
  3. **写不命中（Write Miss），目标块在主节点呈 Shared 状态**：
     * Local $\xrightarrow{\text{WriteMiss}}$ Home
     * Home 发现目录中有 Sharers 集合 $\{S_1, S_2 \dots\}$ $\to$ Home $\xrightarrow{\text{Invalidate}}$ 所有 Sharers
     * 各 Sharer 收到 Invalidate，将其 Cache 块置为 **I**，并向 Home（或 Local）发送 $\text{InvalidateAck}$
     * Home 收到全部 ACK，修改目录为 $\text{Exclusive}$，Owner 置为 $\{\text{Local}\}$
     * Home $\xrightarrow{\text{DataReply}}$ Local （返回数据值）
     * Local 收到数据，Cache 状态转为 **M**
  4. **写不命中（Write Miss），目标块在 Owner 节点呈 Exclusive / Modified 状态**：
     * Local $\xrightarrow{\text{WriteMiss}}$ Home
     * Home $\xrightarrow{\text{FetchInvalidate}}$ Owner
     * Owner 收到后，将数据发送给 Home（或直接前递给 Local），并将本地 Cache 块置为 **I**
     * Home 收到数据更新主存，修改目录为 $\text{Exclusive}$，Owner 置为 $\{\text{Local}\}$
     * Home $\xrightarrow{\text{DataReply}}$ Local （返回数据值）
     * Local 收到数据，Cache 状态转为 **M**

### 4. 锁原语 LL / SC 锁控制机制（选择题常考）
* **LL（链接载入 - Load Linked）**：读取目标内存字，并在硬件中为该地址注册一个预订标记（Reservation）。
* **SC（条件存储 - Store Conditional）**：写目标内存字。**仅当自 LL 以来没有任何其他核心修改过该地址时，SC 写入才能成功（返回 1），否则写入失败（返回 0）**。
* **相比原子交换（Atomic Exchange）的优势**：
  * 原子交换（如 `EXCH`）即使锁不可用，也会执行总线写操作，引发大量的写失效流量（Bus Traffic），造成网络拥堵。
  * `LL/SC` 允许核心在锁不可用时，通过 `LL` 指令在本地 Cache 中进行只读自旋（Spin-on-read），**只有在锁被释放（本地 Cache 被失效）后，才会发起一次 SC 写操作**，极大地节省了总线带宽。

---

## 考试冷门与特定知识点点名提示 (Exam Alert)

根据历年卷中的细碎选择题和隐藏陷阱，在此特别点名：

1. **精确异常 (Precise Exception)**：指令执行过程中如果发生异常，流水线必须能暂停，使得该异常指令之前的指令全部完成，之后的指令能够撤销并重新开始。指令发生异常时的物理 PC 写入 `mepc`（注意：不是写入 `mtvec`，`mtvec` 存的是异常服务程序的入口首地址）。
2. **读后读相关 (RAR)**：RAR（Read After Read）**不是**数据冒险（Data Hazard）。数据冒险仅包括 RAW、WAR 和 WAW 三类。
3. **Cache 相联度与功耗关系**：在容量相同的情况下，**提高相联度会增加功耗**（因为在查找时需要并行启动更多的 Tag 比较器和 Data Array，虽然它降低了冲突不命中）。
4. **多发射技术分类 (VLIW vs Superscalar)**：
   * **超标量 (Superscalar)** 是硬件密集型技术，由硬件在运行期进行冒险检测与指令分发。
   * **超长指令字 (VLIW)** 是编译器密集型技术，完全依赖软件在编译期排好并行指令包并处理依赖。
5. **循环展开 (Loop Unrolling)**：最适用于**各次迭代完全独立 (Independent Iterations)** 的循环。如果循环内存在严重的标量累加（如 `sum = sum + a[i]`）等强相关，单独展开无法达到理想的性能提升（需要配合标量展开与并行归约）。
6. **松弛内存模型 (Relaxed Consistency Model)**：针对 MIMD 中的缓存连贯性，如果模型松弛了“写 $\to$ 读” (W $\to$ R) 与 “写 $\to$ 写” (W $\to$ W) 的顺序控制，则为**弱排序模型 (Weak Order)** 或特定松弛架构，在没有加锁或同步屏障 (Fence) 的情况下，无法保证多核观测到的写入顺序一致。
