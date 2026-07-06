# 计算机体系结构课程期末复习脑图与考点汇总

本章基于课程期末复习大纲（lec14-review.pptx）进行整理，提供直观的知识点思维导图框架，并在后续小节中列举了每个微观考点的大意与核心计算公式，方便考前复习。

---

## 课程知识点思维导图

```mermaid
mindmap
  root((计算机体系结构))
    Fundamentals(1. 设计基础)
      指标
        Dennard Scaling
        Moore's Law
        Flynn 分类SISD/SIMD/MISD/MIMD
      性能
        Amdahl's Law
      ISA
        操作数: Stack/Accumulator/GPR
        访存: Register-Memory/Load-Store
        RV 寻址: Register/Immediate/Displacement
    Memory(2. 存储层次)
      性能
        AMAT 公式
        3C 异常: Compulsory/Capacity/Conflict
      Cache 优化
        基本优化: 6种(包括多级L1/L2)
        高级优化: 10种(Way预测/Nonblocking/HBM等)
      虚拟内存
        VIPT 相联度与页限制
    ILP(3. 指令级并行)
      流水线
        Latency 与 Initiation Interval
        Hazards: 结构/数据(RAW/WAR/WAW)/控制
      异常
        精实时异常与 Precise Exception
      静态调度
        循环展开
        静态分支预测: 延迟分支槽填充
      动态调度
        Scoreboard 记分牌(集中控制/3表)
        Tomasulo (保留站/重命名/CDB)
        投机 Speculation (ROB/顺序提交)
      多发射
        理想 IPC 与多路限制
    DLP(4. 数据级并行)
      向量架构
        RV64V (vv/vs/sv)
        动态寄存器类型与 MVL
        Strip Mining & setvl
        车队 Convoy 与 Chime 计算
        Memory Banks 与 Stride 步长冲突
        Gather-Scatter 稀疏访存
      多媒体 SIMD
        删减特征
        屋顶图 Roofline 算术强度
      GPU
        SIMT 与 CUDA 1D 索引计算
        Warp Divergence 分支发散
        Branch Sync Stack 同步栈
        显存分层: Local/Shared/Global
    TLP(5. 多核与一致性)
      架构
        UMA 与 NUMA
      一致性 Coherence
        MSI / MESI / MOESI 协议
        Snooping 监听与 Directory 目录
      同步 Synchronization
        Atomic Exchange & Spin Locks
      一致性模型 Consistency
        顺序一致性 SC
        松弛一致性 Relaxed
```

---

## 第一部分：设计基础与性能度量（Lectures 02-03）

* **Dennard 缩放定律（Dennard Scaling）**：指出随着晶体管尺寸减小，给定硅片区域的功率密度保持恒定。该定律在 2004 年左右失效，主要是因为电压和电流无法继续无限制降低以确保电路可靠性。
* **摩尔定律（Moore's Law）**：预测每个芯片上的晶体管数量大约每两年翻一番。该定律在 2015 年左右基本失效。
* **多核处理器转型**：由于单核能效无法继续提升，处理器转向采用多个高效核心替代单个低效大核心，从发掘指令级并行转为发掘数据级和线程级并行。
* **并行性分类**：应用并行性分为数据级并行（DLP）与任务级并行（TLP）；硬件发掘并行性的手段有指令级并行（ILP）、向量/GPU 架构、线程级并行（TLP）、请求级并行（RLP）。
* **阿姆达尔定律（Amdahl's Law）**：用于衡量部件改进对整体加速的效果。公式为：
  $$\text{Speedup} = \frac{1}{(1 - f) + \frac{f}{s}}$$
  *(其中 $f$ 为改进部分的执行时间比例，$s$ 为该部件的加速比)*
  性能提升上限公式为：
  $$\text{Limit} = \frac{1}{1 - f}$$
* **ISA 操作数存储分类**：根据 CPU 内部存储类型分为三类：
  * 堆栈架构（Stack）：操作数隐式位于栈顶。
  * 累加器架构（Accumulator）：一个操作数隐式位于累加器，另一个显式来自内存。
  * 通用寄存器架构（GPR）：所有操作数均为显式指定，最为主流。
* **GPR 架构分类**：分为寄存器-内存架构（任意指令均可访问内存，如 x86）与载入-存储架构（仅 load/store 指令可访存，如 RISC-V/MIPS）。
* **寻址模式**：指定操作数所在的地址（寄存器、常量或内存）。RISC-V 仅支持寄存器寻址、立即数寻址与偏移量寻址。
* **弗林分类法（Flynn's Taxonomy）**：根据指令流和数据流的组合分为：
  * SISD：单指令单数据，即传统的单核标量机。
  * SIMD：单指令多数据，如向量机、多媒体指令、GPU。
  * MISD：多指令单数据，无商业实现。
  * MIMD：多指令多数据，如多处理器多核系统。

---

## 第二部分：存储层次结构（Lectures 04-05）

* **Cache 映射与放置策略**：直接映射（映射到唯一 Set 唯一位置）、全相联（可放置在任意位置）、组相联（映射到唯一 Set，可放置在 Set 内任意位置）。
* **块识别**：通过物理地址划分（Tag + Index + Offset）查找块。全相联 Cache 没有 Index 字段，直接并行比对所有 Tag。
* **写策略（写命中）**：
    * 写穿（Write-through）：数据同时写入 Cache 和下级内存，仅使用 Valid 位。
    * 写回（Write-back）：仅写入 Cache 块并标记 Dirty 位，直到该块被替换时才写回下级内存，使用 Valid 位与 Dirty 位。
* **写策略（写不命中）**：
    * 写分配（Write allocate）：先将数据从内存调入 Cache，再进行写操作。
    * 无写分配（No-write allocate）：直接在下级内存中修改，不调入 Cache。
* **平均内存访问时间（AMAT）**：
  $$\text{AMAT} = \text{Hit Time} + \text{Miss Rate} \times \text{Miss Penalty}$$
* **不命中根源（3Cs）**：冷启动不命中（首次访问）、容量不命中（Cache 太小）、冲突不命中（组内碰撞替换）。
* **Cache 六大基本优化**：
    * 增大块大小（利用空间局部性降低冷不命中，但增加 Miss Penalty）。
    * 增大 Cache 容量（降低容量不命中，但增加 Hit Time 与能耗）。
    * 提高相联度（降低冲突不命中，但增加 Hit Time）。
    * 多级缓存（在快 CPU 与慢主存之间插入 L2/L3 降低 Miss Penalty）。
    * 读不命中优先于写（通过写缓冲区暂存写操作，使读不命中优先处理）。
    * 地址转换并行化（利用虚拟索引物理标记 VIPT 绕过地址转换延迟）。
* **多级缓存性能指标**：
  * 本地不命中率（Local Miss Rate）：当前 Cache 的 Miss 数量除以进入该级 Cache 的总访问数。
  * 全局不命中率（Global Miss Rate）：该级 Cache 的 Miss 数量除以 CPU 发出的总访问数。L2 全局不命中率 = $\text{Miss Rate}_{\text{L1}} \times \text{Miss Rate}_{\text{L2, Local}}$。
  * 多级 Cache 平均访存时间公式：
    $$\text{AMAT} = \text{Hit Time}_{\text{L1}} + \text{Miss Rate}_{\text{L1}} \times (\text{Hit Time}_{\text{L2}} + \text{Miss Rate}_{\text{L2, Local}} \times \text{Miss Penalty}_{\text{L2}})$$
  * 每指令平均访存挂起周期数：
    $$\text{Memory Stalls/Instruction} = \text{Misses/Instruction}_{\text{L1}} \times \text{Hit Time}_{\text{L2}} + \text{Misses/Instruction}_{\text{L2}} \times \text{Miss Penalty}_{\text{L2}}$$
* **Cache 十大高级优化**：
  * 小而简单的 L1 Cache（降低 Hit Time 与功耗）。
  * 路预测（提前预测组相联中的路以降低 Hit Time）。
  * 流水化 Cache 访问（提升 Cache 带宽）。
  * 多 Bank Cache（支持多个不冲突的并发访存，提升带宽）。
  * 非阻塞 Cache（在发生 Miss 时支持后续指令继续 Hit，即 Hit-under-Miss）。
  * 关键字优先与提前重启（只获取急需的数据字即放行 CPU，降低 Miss Penalty）。
  * 合并写缓冲区（合并写入相邻地址，提升写带宽）。
  * 编译器优化（通过循环交换、分块 Blocking 提高数据局部性，降低 Miss Rate）。
  * 硬件/编译器预prefetching（提前将数据读入 Cache，降低 Miss Rate）。
  * 高带宽内存（HBM）（采用 3D 堆叠封装提升总带宽）。

---

## 第三部分：指令级并行（ILP）（Lectures 06-08）

* **流水线延迟指标**：Latency（延迟，指令在流水线中所花周期数）与 Initiation/Repeat Interval（发射间隔，流水线接收新指令所需的间隔周期）。
* **数据冒险分类**：写后读（RAW，真相关）、读后写（WAR，反相关）、写后写（WAW，输出相关）。
* **控制冒险**：分支指令未判定前，后继指令受控制相关制约。
* **精确异常（Precise Exception）**：发生异常时，异常指令之前的所有指令均已完成提交，之后的所有指令均未执行（或已被完全冲刷撤销），寄存器状态完好。
* **静态调度技术**：通过编译器重排指令（循环展开消除循环开销、填充延迟分支槽以消除分支停顿）。
* **静态分支预测**：根据编译期规律预测分支（如 Predicted-Taken 或延迟分支槽）。延迟分支槽可从 Before、Target、Fall-through 填充。
* **动态分支预测**：
    * 1位分支预测器：记录上一次跳转方向。对单次异常跳转过度敏感，交替循环下准确率为 0%。
    * 2位分支预测器：采用 2 位饱和计数器，连续两次预测错误才改变预测状态，容错率高。
* **动态调度之记分牌算法（Scoreboarding）**：集中式硬件控制，不支持寄存器重命名。
    * 四阶段：发射（检查结构与 WAW 冲突）、读操作数（等待 RAW 消除）、执行、写结果（等待并解决 WAR 冲突）。
    * 三张表：指令状态表、功能单元状态表（Busy, Op, Fi, Fj, Fk, Qj, Qk, Rj, Rk）、寄存器结果状态表。
* **动态调度之 Tomasulo 算法**：分布式控制，利用**寄存器重命名**消除 WAR/WAW 名字冲突，通过公共数据总线（CDB）广播前递数据。
    * 三阶段：发射（分配 RS 并进行重命名）、执行（在 RS 中监听 CDB）、写结果（在 CDB 上广播，写入寄存器和 RS，释放 RS）。
    * 保留站字段：Busy（忙）、Op（操作）、Vj/Vk（就绪数值）、Qj/Qk（产生数据的 RS 编号）、A（访存地址）。
* **硬件投机与重排序缓冲区（ROB）**：支持**乱序执行、顺序提交**，从而完美保障精确异常。
    * ROB 字段：Instruction Type（类型）、Destination（目标寄存器/内存地址）、Value（临时计算值）、Ready（就绪标志）。
    * 四阶段：发射（分配 RS 与 ROB 项，重命名指向 ROB）、执行、写回（写入 ROB 对应 Value，立即释放保留站）、提交（按序将 ROB 的 Value 写入体系结构寄存器或主存，处理异常与分支失败）。
* **多发射（Multiple Issue）**：单周期发射多条指令（如超标量或 VLIW），理想 CPI < 1，最大并行度受限于数据相关与结构带宽。

---

## 第四部分：数据级并行（DLP）（Lectures 09-10）

* **向量执行车队模型**：
    * 车队（Convoy）：一组不含结构冲突的向量指令。由于链接（Chaining）机制，同一个车队内允许存在 RAW 相关。
    * 鸣响（Chime）：执行一个车队所需的时间。对于长度 $n$ 的向量，执行 $m$ 个车队耗时约 $m \times n$ 周期。
* **分条挖掘（Strip Mining）**：当循环长度超过最大向量长度（MVL）时，编译器利用 `setvl` 指令将大循环分割成大小 $\le \text{MVL}$ 的子块循环运行。
* **条件控制**：向量处理器利用谓词/条件掩码寄存器（Mask）控制元素的条件执行，避免分支跳转（IF-conversion）。
* **内存多 Bank 设计**：为了避免内存忙周期引起的冲突并提升访存吞吐率，内存划分为多个独立 Bank。
* **步长（Stride）冲突判定**：判定由于步长访存导致 Bank 忙周期挂起的公式：
  $$\frac{\text{LCM}(\text{Stride}, \text{Bank 数量})}{\text{Stride}} < \text{Bank 忙时间}$$
* **间接访存**：收集（Gather, `vldx`）根据索引向量从离散内存中把数据打包读入向量寄存器；分散（Scatter, `vstx`）将连续向量结果按索引向量散布写回离散内存。
* **多媒体 SIMD 架构**：短且固定宽度的向量，去除了向量长度寄存器、步长访存/收集分散指令与掩码寄存器以节省硬件成本。
* **屋顶图模型（Roofline Model）**：将算术强度（AI = 浮点操作数 / 访存字节数）作为横坐标，将可达性能作为纵坐标，刻画 Memory-bound（斜坡）与 Compute-bound（平顶）的界限。
* **GPU 编程模型（SIMT）**：单指令多线程。
    * 线程层次：Grid $\to$ Thread Block $\to$ Thread。
    * 1D 线程索引公式：
    $$\text{index} = \text{blockIdx.x} \times \text{blockDim.x} + \text{threadIdx.x}$$
    * 二级硬件调度：线程块调度器分发 Thread Block 到 SM，SIMD 线程调度器调度 Warp（32线程）在物理 SIMD Lanes 上发射指令。
* **Warp 分支发散与同步栈**：若 Warp 内线程走向不同分支（THEN/ELSE），硬件必须屏蔽部分 Lane 并串行执行两路路径。硬件内部使用分支同步栈记录分歧掩码（Token, Target PC, Target Active Mask）在 Diverge 时压栈并在 Converge 时弹栈。
* **GPU 存储**：Local Memory（线程私有，显存上）、Shared Memory（片上 SRAM，Block 内共享，极快）、Global Memory（大容量显存，所有线程与 CPU 可见，慢）。

---

## 第五部分：多核与一致性（Lectures 11-13）

* **共享内存多处理器分类**：集中式共享内存（UMA，均匀访存）与分布式共享内存（NUMA，非均匀访存）。
* **缓存一致性问题（Cache Coherence）**：多个处理器本地 Cache 中存有同一主存块的不同副本，当有核改写数据时，其他核的数据失效或变脏。
* **一致性（Coherence）三大定义属性**：
  1. 写传播（Write Propagation）：某一核心的写入操作最终必须能被其他核心读到。
  2. 写序列化（Write Serialization）：所有核心对同一个内存位置的写入操作，看到的顺序必须完全一致。
  3. 读操作能返回最近一次写入的值。
* **一致性协议实现**：
  * 监听协议（Snooping）：所有 Cache 共享广播总线，监听总线上的读写请求（适用于小规模）。
  * 目录协议（Directory）：用一个集中/分布式的目录记录每个内存块的所有权和共享状态（适用于大规模扩展）。
* **写失效协议（Write Invalidate）**：在改写数据前，发出 Invalid 广播使总线上所有其他 Cache 的相应副本失效。
* **Cache 状态协议转换**：
  * **MSI 协议**：Modified（已修改，脏且独占）、Shared（共享，清洁）、Invalid（失效）。
  * **MESI 协议**：引入 Exclusive（独占清洁）状态，单核独占读取的数据在改写时无需广播 Invalidate。
  * **MOESI 协议**：引入 Owned（拥有）状态，允许脏块在 Cache 间直接共享而无需写回主存。
  * **MESIF 协议**：引入 Forward（转发）状态，指定唯一 Shared 状态节点响应 Read 读请求。
* **共享失效分类**：
  * 真共享不命中（True Sharing Miss）：核心 A 修改变量，核心 B 随后读取该被修改变量产生不命中。
  * 伪共享不命中（False Sharing Miss）：核心 A 和 B 分别读写同一个 Cache 块内的不同独立变量，写操作导致整个块失效，引起另一核心产生不必要的不命中。
* **硬件同步原语**：
  * 原子交换（Atomic Exchange / Test-and-Set）：硬件保证读-写操作一步完成，用于锁获取。
  * 链接载入/条件存储（LL/SC）：通过 `lr` 与 `sc` 指令实现无锁原子操作。
  * 自旋锁（Spin Lock）：循环查询直到锁释放。在 Cache 上自旋（Local Spinning）可降低总线负载。
* **内存一致性模型（Consistency）**：定义了对**不同内存地址**进行读写操作的物理可见顺序。
  * 顺序一致性（Sequential Consistency, SC）：所有处理器看到的读写顺序与程序的逻辑顺序（Program Order）完全一致，且全局交织。
  * 松弛一致性模型（Relaxed Consistency）：允许对非冲突的读写进行乱序重排以提升硬件性能（如允许 W->R 重排），在需要强顺序时必须显式插入内存屏障（Fence/Barrier）指令。
