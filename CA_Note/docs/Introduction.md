# 第一章 计算机体系结构

本章梳理了计算机系统的抽象层次，明确了计算机体系结构与计算机微结构的区别，并对全书后续讨论的流水线、存储层次、指令级并行（ILP）、数据级并行（DLP）以及线程级并行（TLP）等核心主题进行了概要性预览。

---

## 计算机系统抽象层

计算机系统的设计是一系列抽象层（Levels of Abstraction）的叠加。每一层都向上一层隐藏了底层的实现细节，使得复杂的软硬件系统开发成为可能：

1. **应用问题（Problem）**：用户需要解决的实际计算任务。
2. **算法（Algorithm）**：解决问题的数学逻辑与步骤。
3. **程序（Program）**：使用高级编程语言编写的源代码。
4. **运行时系统（Runtime System）**：包括虚拟机（Virtual Machine, VM）、操作系统（Operating System, OS）以及内存管理（Memory Management, MM），负责程序的加载、运行与资源调度。
5. **指令集体系结构（Instruction Set Architecture, ISA）**：软硬件的交界面，即软件可见的硬件规范。
6. **微结构（Microarchitecture）**：ISA（Instruction Set Architecture，指令集体系结构） 的具体硬件实现，对软件开发人员透明。
7. **逻辑设计（Logic Design）**：寄存器传输级（RTL）设计与门级网表。
8. **电路设计（Circuits Design）**：晶体管、电阻、电容等基本元器件的物理连接。
9. **物理与电子学（Electrons）**：半导体物理性质与电子流运动。

---

## 体系结构与微结构的区别

在计算机科学中，计算机体系结构（Computer Architecture）通常有狭义与广义之分。其最核心的定义在于区分 **ISA** 与**微结构**：

### 1. 指令集体系结构 (ISA)
* **定义**：软件和硬件之间的显式契约（Contract），也是编写汇编代码或编译器生成机器码所必须理解的处理器部分。
* **软件可见性**：对软件完全可见。
* **包含内容**：指令集（包括指令格式、操作码、寻址方式）、通用寄存器数量与宽度、内存编址与对齐方式、中断与异常处理机制等。

### 2. 微结构 (Microarchitecture)
* **定义**：ISA在特定芯片上的具体物理实现。
* **软件可见性**：对软件开发人员透明（不可见）。相同的 ISA 可以由完全不同的微结构来实现。
* **包含内容**：流水线级数与调度策略、Cache 的大小/路数与组织方式、分支预测器（Branch Predictor）的设计、执行部件（ALU）的数量等。

---

## 定量分析方法

现代计算机体系结构的设计已经摆脱了纯粹的凭直觉与经验，转为采用**定量分析方法（Quantitative Approach）**：

* **性能驱动（Performance-Driven）**：以实际应用负载下的执行时间、功耗与成本作为评估指标，通过仿真和实测数据来指导架构优化。
* **知其然，更要知其所以然（Know not only how, but also why and why not）**：在系统设计中，不存在绝对完美的方案。每引入一个特性，都需要在性能、功耗、面积（Area）与软硬件复杂度之间进行折中（Trade-off）。

---

## 体系结构核心主题预览

### Pipelining & Hazards
流水线与冒险/冲突

流水线是指在完成前一条指令之前，重叠执行后一条指令的技术。经典的 5 阶段 RISC 流水线将指令执行分为：

* 取指（Instruction Fetch, IF）：从指令内存中获取下一条指令。
* 译码/读寄存器（Instruction Decode, ID）：读取寄存器堆，并对立即数进行符号扩展。
* 执行（Execution, EX）：计算内存地址或进行算术逻辑运算。
* 访存（Memory Access, MEM）：读取或写入数据存储器，或更新跳转后的 PC。
* 写回（Write Back, WB）：将结果写回寄存器堆。

流水线会因为各种**冲突（Hazards）**而导致暂停（Stalls）：

* **结构冲突（Structural Hazard）**：当多条指令同时使用相同的硬件资源时，会发生结构冲突。
    * *例如*：如果微结构中只有一个统一的内存端口，那么当一条指令处于MEM阶段读取数据时，另一条新指令就无法同时在IF阶段从内存获取指令，从而发生冲突：

| 指令 | 周期 1 | 周期 2 | 周期 3 | 周期 4 | 周期 5 | 周期 6 | 周期 7 |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 指令 i (Load) | IF | ID | EX | **MEM** | WB | | |
| 指令 (i+1) | IF | ID | EX | MEM | WB | |
| 指令 (i+2) | | | IF | ID | EX | MEM | WB |
| 指令 (i+3) | | | | **(Stall/暂停)** | IF | ID | EX |

* **数据冲突（Data Hazard）**：一条指令依赖于前面尚未执行完毕的指令的数据结果。
    * *解决方法*：旁路传播/前推技术（Forwarding/Bypassing）、前半周期写后半周期读（Double Bump）、以及插入暂停周期（Stall）。
    !!! warning "考试避坑：顺序单发射流水线中的 WAR / WAW 冲突"
        在经典的 **5 阶段顺序单发射流水线** 中，指令是严格“按序发射、按序执行、按序写回”的。因此，**绝不可能发生 WAR（读后写）或 WAW（写后写）冲突**！
        WAR 和 WAW 冲突只有在引入了**乱序执行（Out-of-Order Execution）**（如 Scoreboard 或 Tomasulo 算法）或者**多发射（Multi-issue）**技术后才会产生。如果考卷中遇到“顺序单发射流水线如何解决 WAR 冲突”，请直接回答“该流水线不发生此冲突，无需解决”。
* **控制冲突（Control Hazard / Branch Hazard）**：流水线在执行分支或跳转指令时，由于无法立即确定下一条指令的地址而产生的停顿。
    * *解决方法*：分支预测（Branch Prediction，包括静态和动态预测）、分支延迟槽（Branch Delay Slot）、以及将分支决策和地址计算硬件提前到ID阶段以减少延迟开销。

### Memory Hierarchy
存储层次结构

为了弥补处理器与内存之间的“性能鸿沟”，现代计算机采用多级 Cache 与主存组成的层次结构。

* **Cache 性能核心公式**：
  $\text{Memory stall cycles} = \text{Accesses} \times \text{Miss rate} \times \text{Miss penalty}$
  其中：
    * 内存挂起周期（Memory stall cycles）：处理器因等待访存而暂停的周期数。
    * 不命中率（Miss rate）：未在 Cache 中命中的访存次数占总访存次数的比例。
    * 不命中开销（Miss penalty）：发生 Miss 时，从下一级存储调入数据所需的额外等待周期数。
* **多级 Cache 设计（Multilevel Cache）**：
    * 第一级 Cache（L1 Cache）：容量较小，其时钟周期必须完全匹配快速的处理器主频。
    * 第二级 Cache（L2 Cache）：容量较大，用于捕获更多访存请求，降低访问主存的高昂不命中开销（Miss penalty）。

### Virtual Memory
虚拟内存

虚拟内存利用物理内存与辅助存储（如硬盘/SSD）之间的映射，为进程提供了一个连续的虚拟地址空间。

* 核心价值：
    * 简化管理：进程看到的地址空间是连续的，但物理内存分配可以离散。
    * 共享与保护：在多进程之间安全地共享物理内存，并提供精细的读写权限控制与进程隔离（Process Isolation）。
    * 空间扩容：允许进程使用比实际物理内存更大的地址空间。
* 基本模式：分页虚拟内存（Paged VM，固定块大小）与分段虚拟内存（Segmented VM，可变块大小）。
* 快表（Translation Lookaside Buffer, TLB）：
  用于加速虚拟页号到物理页框号转换的专用硬件 Cache。以 Opteron 数据 TLB 为例，其转换流程为：
  ```mermaid
  graph TD
      A[输入虚拟地址] --> B[同时向所有 Tag 发送虚拟页号]
      B --> C{检查访问类型与保护信息}
      C -- 权限违规 --> D[触发保护异常]
      C -- 权限通过 --> E[匹配的 Tag 送出物理页框号]
      E --> F[拼接页内偏移量 Offset]
      F --> G[生成最终物理地址]
  ```

### Parallelism Paradigms
并行性技术

为了继续提升处理器性能，体系结构在多个维度上发掘并行性：

#### A. 指令级并行（Instruction-Level Parallelism, ILP）
* *静态调度（Static Scheduling）*：依赖编译器在编译期重排指令（如流水线调度、循环展开 Loop Unrolling）以消除冲突带来的 Stall。
    * *流水线调度示例*：对于以下 RISC-V 循环体：
      ```assembly
      Loop: fld f0, 0(x1)
            fadd.d f4, f0, f2     ; 依赖 f0，如果不做调度需暂停 1 周期
            fsd f4, 0(x1)         ; 依赖 f4，如果不做调度需暂停 2 周期
            addi x1, x1, -8
            bne x1, x2, Loop
      ```
      如果编译器将无关的指令 `addi` 插入到 `fld` 和 `fadd.d` 之间，并调整 `fsd` 的偏移量，则可消除 Stalls，将单次循环耗时从 8 周期降低到 7 周期：
      ```assembly
      Loop: fld f0, 0(x1)
            addi x1, x1, -8       ; 提前执行，填充 fld 的延迟槽
            fadd.d f4, f0, f2
            fsd f4, 8(x1)         ; 调整偏移量为 8(x1)
            bne x1, x2, Loop
      ```
* *动态调度（Dynamic Scheduling）*：允许硬件在运行期根据数据相关性乱序执行（Out-of-Order, OoO）和乱序结束。
    * 将指令译码（ID）阶段拆分为发射（Issue）（顺序解码并检查结构冲突）和读操作数（Read Operands）（等待数据相关性解除后读取操作数）。
    * 典型算法为 Tomasulo 算法，并在此基础上发展出利用重排序缓冲区（Reorder Buffer, ROB）实现**乱序执行、顺序提交**（Out-of-Order execution & In-order commit）的硬件投机（Hardware Speculation）技术，以便在分支预测失败时撤销投机状态。

#### B. 数据级并行（Data-Level Parallelism, DLP）
* 向量架构（Vector Architecture, 如 RV64V）：将分散的元素加载到大型顺序向量寄存器中，仅用单条指令即可处理成百上千个独立数据的操作。通过多Lane（Multiple Lanes）在单周期并行处理多个元素。
* 多媒体 SIMD（Multimedia SIMD）：适用于短、固定长度（如 256 位）的并行操作。通常省去了向量长度寄存器、跨步（Strided）或收集/分散（Gather/Scatter）访存指令。
* 图形处理器（GPU）：支持高并发的多线程 SIMD，开发难点在于协调 CPU 与 GPU 之间的数据传输与计算调度。

#### C. 线程级并行（Thread-Level Parallelism, TLP）
多核处理器下存在两种典型的物理结构：

* **集中式共享内存（Centralized Shared-Memory）**：所有核心通过对称总线共享单一集中内存。所有处理器访问内存的延迟相同，称为**均匀访存模型（Uniform Memory Access, UMA）**，通常扩展性受限于 32 个核心以内。
* **分布式共享内存（Distributed Shared-Memory）**：内存物理上分布在各个节点上，增加总带宽并降低本地访存延迟。不同处理器访问不同内存位置的延迟不同，称为**非均匀访存模型（Nonuniform Memory Access, NUMA）**。
* **Cache 一致性问题（Cache Coherence）**：
  * **一致性（Coherence）**：定义了一次读操作能返回什么值（即确保任何读操作都能读到该数据项最新写入的值）。
  * **相容性/一致性模型（Consistency）**：定义了一个新写入的值在何时能被其他读操作看到。

---