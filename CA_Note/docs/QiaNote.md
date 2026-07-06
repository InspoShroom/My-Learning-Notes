# 数据级并行（DLP）与线程级并行（TLP）- HobbitQia 笔记翻译

本笔记翻译自 HobbitQia 的计算机体系结构课程笔记本中关于数据级并行（Data-Level Parallelism, DLP）与线程级并行（Thread-Level Parallelism, TLP）的章节。重要专业术语已在后方括号内标注英文。

---

## 费林分类法 (Flynn's Taxonomy)
* **SISD**（单指令流单数据流 - Single Instruction Single Data）：经典的单处理器（Uniprocessor）架构，如传统的冯·诺依曼架构（von Neumann Architecture），通过流水线、超标量、投机执行等手段发掘指令级并行（ILP）。
* **SIMD**（单指令流多数据流 - Single Instruction Multiple Data）：同一条指令由多个处理单元使用不同的数据流并发执行。典型实现包括向量处理器（Vector Processor）、阵列处理器（Array Processor）以及多媒体指令集。开发的是数据级并行（DLP）。
* **MIMD**（多指令流多数据流 - Multiple Instruction Multiple Data）：每个处理器自主获取自己的指令并操作自己的数据，开发的是线程级/任务级并行（TLP）。
  * 共享内存系统（Shared Memory System）：所有处理器共享相同的物理或逻辑地址空间。包括 UMA、NUMA、COMA。
  * 消息传递系统（Message Passing System）：每个处理器拥有私有物理内存，通过网络发送消息进行通信。如大规模并行处理器（MPP）、集群（Cluster）、工作站集群（COW）、网格（Grid）。
* **MISD**（多指令流单数据流 - Multiple Instruction Single Data）：多个指令流操作同一个数据流，无商业机型实现。

---

## 1. SIMD: 向量处理器 (Vector Processor)
向量处理器是能有效发掘数据级并行（DLP）的核心架构之一，在科学计算和多媒体处理中应用广泛。它比多线程 MIMD 系统更具能效（Energy Efficient），并且允许程序员以熟悉的顺序思维（Sequentially）进行编程。

### 1.1 处理模式与结构分类
* **向量处理器（Vector Processor）**：具有向量数据表示形式以及专门的向量指令集的流水线处理器。
* **标量处理器（Scalar Processor）**：不具备向量寄存器和向量指令的普通流水线处理器。
* **三种向量计算处理方式**：
  1. **横向处理方式（Horizontal Processing Method）**：按行逐个元素计算。例如，计算 $d_i = a_i \times (b_i + c_i)$ 时，必须等元素 $i$ 的加法和乘法完全做完，才能开始元素 $i+1$。容易引入真相关（RAW）冲突，且在流水线中切换功能部件开销极大，不予采用。
  2. **纵向处理方式（Vertical Processing Method）**：按列垂直流水处理。先将整个向量的所有元素在流水线里执行完加法，得到中间向量，再把中间向量送去执行乘法。**这是向量处理器最常用的方式**。
  3. **横纵处理方式 / 分组处理方式（Group Processing Method）**：如果向量太长超出了向量寄存器容量，则需要进行分组（设组大小为 $n$）。组内部进行纵向处理，各组之间进行横向串行。
* **物理结构分类**：
  * 内存-内存结构（Memory-Memory Structure）：源操作数和目的操作数都直接从内存读写。
  * 寄存器-寄存器结构（Register-Register Structure）：引入向量寄存器进行中间结果的高速缓冲。

### 1.2 向量冲突与链接技术（以 Cray-1 为例）
* **Cray-1 向量设计**：拥有 8 个向量寄存器 $V_0 \sim V_7$（每个保存 64 个元素），以及 12 个并行工作的单功能流水线部件。
* **向量指令冲突（Hazards）**：
  * **寄存器冲突（Vi Conflict）**：两条并行的向量指令读写同一个向量寄存器。如：
    * 写后读（RAW）相关：`V0 <- V1 + V2` 与 `V3 <- V0 * V4` 冲突。
    * 读后读（RAR）相关：`V0 <- V1 + V2` 与 `V3 <- V4 * V0` 冲突。
    * 解决：后继指令必须等待前序指令产生结果。但不需要等整条指令全算完，只要第一个元素写回寄存器，即可通过**链接（Chaining）**技术送入下一流水线。
  * **功能部件冲突（Functional Conflict）**：两条指令争抢同一个单功能硬件（结构冲突，Structural Conflict）。如 `V3 <- V1 * V2` 和 `V5 <- V4 * V6` 同时争抢唯一的乘法器。必须完全等前一条指令的最后一个元素计算完毕释放部件后，后继指令才能启动。

### 1.3 链接技术周期计算大题实例
* **条件设定**：
  * 向量长度为 $N \le 64$。向量加法需要 6 拍，乘法 7 拍，内存载入 6 拍。
  * 寄存器到功能部件需 1 拍，写回寄存器 1 拍，内存到载入部件 1 拍。
  * 计算式为 $D = A \times (B + C)$。$B, C$ 已载入 $V0, V1$。
  * 汇编指令为：
    1. `V3 <- memory` (载入 A)
    2. `V2 <- V0 + V1` (向量加)
    3. `V4 <- V2 * V3` (向量乘，依赖加法结果 V2 与载入结果 V3)
* **三种方式的执行周期计算**：
  1. **串行执行方式（Serial）**：
     * 载入指令首元素耗时 $1+6+1 = 8$ 拍，总共 $8 + N - 1$ 拍。
     * 加法指令首元素耗时 $1+6+1 = 8$ 拍，总共 $8 + N - 1$ 拍。
     * 乘法指令首元素耗时 $1+7+1 = 9$ 拍，总共 $9 + N - 1$ 拍。
     * 总周期 = $(8+N-1) + (8+N-1) + (9+N-1) = 3N + 22$ 周期。
  2. **并行与串行结合方式（Parallel then Serial）**：
     * 载入与加法并行（取最大值）：$\max(8+N-1, 8+N-1) = 8+N-1$ 周期。
     * 乘法在两者完全结束后启动，耗时 $9+N-1$。
     * 总周期 = $(8+N-1) + (9+N-1) = 2N + 15$ 周期。
  3. **链接执行方式（Chaining / Link）**：
     * 载入和加法在第 0 拍同时并行启动。首元素在第 8 拍到达 V3 和 V2。
     * 在第 8 拍，直接链接启动乘法：首元素经过 1 拍送入乘法部件，7 拍计算，1 拍写回 $V4$，首元素延迟共 9 拍。
     * 其余元素流水化流出。
     * 总周期 = $\max(8, 8) + 9 + N - 1 = N + 16$ 周期。

### 1.4 RV64V 向量处理器设计
* 包含 32 个 64 位的向量寄存器。
* 向量寄存器堆连接 16 个读端口与 8 个写端口。
* 支持完全流水线化的功能单元与冲突检测，支持双精度 `DAXPY` 运算。

---

## 2. SIMD: 阵列处理器 (Array Processor)
* 包含 $N$ 个相同的处理单元（Processing Elements, PE），PE 之间通过互联网络（Interconnection Network, ICN）连接。
* **分布式存储（Distributed Memory）**：每个 PE 都有独立的本地存储器（PEM）。
* **集中式存储（Centralized Shared Memory）**：所有 PE 共享主存储器。

### 2.1 互联网络 (Interconnection Networks)
* **核心组成**：网络接口（NIC - Interface）、物理链路（Link，负责串/并传输、单/双工、同步/异步控制）、交换节点（Switch Node，多路选路由与缓冲）。
* **网络拓扑类型**：
  * 静态拓扑（Static Topology）：连接通路在物理上是固定不变的。
  * 动态拓扑（Dynamic Topology）：利用开关元件（Switches）动态控制线路接通与断开。

---

## 3. 单级与多级互联网络

### 3.1 单级互联网络（Single-Stage Interconnection Network）
只有一级连接拓扑，实现处理单元间的一次直接或受限的传输。
* **立方体网络（Cube）**：
  * 二进制地址表示为 $P_{n-1} \dots P_1 P_0$。第 $i$ 维立方体函数 $Cube_i$ 对地址的第 $i$ 位取反：
    $$Cube_i(P_{n-1} \dots P_i \dots P_0) = P_{n-1} \dots \overline{P_i} \dots P_0$$
  * 任意两节点间最远传输距离为 $\log_2(N)$ 步。
* **PM2I（Plus-Minus $2^i$）**：
  * 加减 $2^i$ 映射函数：
    $$\text{PM2}_{+i}(j) = (j + 2^i) \bmod N, \quad \text{PM2}_{-i}(j) = (j - 2^i) \bmod N$$
  * 共有 $2\log_2(N) - 1$ 个不同函数。例如 $N=8$ 时，任意两点间最大步数为 2。
* **混洗交换网络（Shuffle-Exchange Network）**：
  * **混洗（Shuffle）**：二进制位循环左移一位：
    $$\text{shuffle}(P_{n-1} P_{n-2} \dots P_1 P_0) = P_{n-2} \dots P_1 P_0 P_{n-1}$$
    *缺陷：全 0 和全 1 的节点无法通过混洗与其他节点发生连接。*
  * **交换（Exchange）**：通过立方体最低位取反函数 $Cube_0$ 来翻转最低位。
  * 距离：任意两点间最远距离为 $2n - 1$（$n$ 次交换与 $n-1$ 次混洗）。
* **其他静态网络**：线性阵列（Linear Array，单点故障隐患高）、环形阵列（Circular Array）、树形阵列（Tree）、星形阵列（Star，极度依赖中心）、网格（Grid，2D torus 等，GPU 常用）、超立方体（Hypercube）。

### 3.2 多级互连网络（MIN）
* **开关单元状态**：两入两出的 2x2 开关支持四种控制状态：直通（Straight）、交换（Exchange）、上广播（Upper Broadcast）、下广播（Lower Broadcast）。
* **多级立方体网络（Multi-stage Cube Network）**：只使用直通和交换双功能开关，通过目标排列映射反推各级开关状态。
* **Omega 网络（多级混洗交换网络）**：
  * 结构：每一级前段采用单级 Shuffle 拓扑连接，后段接入四功能开关单元。
  * **与 Cube 网络对比**：
    * 相似性：如果 Omega 仅使用直通和交换，则等价于多级 Cube 网络的逆网络。
    * 差异性：
      1. 信号级流向相反：Omega 为 $n-1 \to 0$；Cube 为 $0 \to n-1$。
      2. Omega 采用四功能开关单元；Cube 采用双功能。
      3. Omega 支持单点向多点的广播（Broadcast），而 Cube 不行。

---

## 4. GPU 架构与 CUDA 并行
* **异构执行模型**：CPU 为主机（Host），GPU 为设备（Device）。
* **单指令多线程（SIMT - Single Instruction Multiple Thread）**：由 GPU 硬件自动进行线程分配与调度管理。
* **线程层次**：每个元素对应一个线程（Thread），线程组成线程块（Thread Block），线程块组成网格（Grid）。
* **存储结构**：
  * 全局内存（Global Memory）：所有网格线程共享。
  * 共享/本地内存（Shared/Local Memory）：同一个线程块（Thread Block）内所有线程共享的片上高速 SRAM。
  * 寄存器/私有内存（Private Memory）：单个线程专属。

---

## 5. 循环级并行 (Loop-Level Parallelism, LLP)
* 主要是分析和消除迭代之间的循环携带依赖（Loop-Carried Dependence）以实现并行。
* **存在依赖且无法并行实例**：
  ```c
  for (i = 0; i < 100; i = i + 1) {
      A[i+1] = A[i] + C[i];   /* S1 */
      B[i+1] = B[i] + A[i+1]; /* S2 */
  }
  ```
  S1 依赖前一轮计算出的 A 数组，无法并行。
* **无闭环依赖可重写并行实例**：
  ```c
  for (i = 0; i < 100; i = i + 1) {
      A[i] = A[i] + B[i];     /* S1 */
      B[i+1] = C[i] + D[i];   /* S2 */
  }
  ```
  由于 S1 依赖 B 数组，但 S2 不反向依赖 S1 产生的 A 数组（无闭环相关），可以通过语句重排和剥离首尾计算来改写，重写后的循环消除了跨迭代依赖：
  ```c
  A[0] = A[0] + B[0];
  for (i = 0; i < 99; i = i + 1) {
      B[i+1] = C[i] + D[i];     /* S2 */
      A[i+1] = A[i+1] + B[i+1]; /* S1 */
  }
  B[100] = C[99] + D[99];
  ```

---

## 6. MIMD 与线程级并行 (TLP)
* **共享内存系统（Shared Memory System）**：
  * **UMA（Uniform Memory Access - 均匀内存访问）**：物理内存被所有核心均匀共享，各处理器访问任意地址的时间均等（对称多处理器 SMP / 紧耦合系统）。
  * **NUMA（Non-Uniform Memory Access - 非均匀内存访问）**：内存分布在各节点，本地访问速度快，跨节点访问慢。
  * **COMA（Cache-Only Memory Access - 仅缓存内存访问）**：不设静态存储，所有的缓存组装成单一地址空间，数据通过目录迁移。
* **缓存一致性与连贯性（Cache Coherence & Consistency）**：
  * 一致性（Coherence）：确保读操作能返回最新的写数据。
  * 连贯性（Consistency）：规定写入的数据何时对其他核心可见。
