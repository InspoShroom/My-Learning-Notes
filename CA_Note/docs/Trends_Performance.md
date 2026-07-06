# 第三章 趋势与性能评测

本章深入探讨了定量计算机设计中更深层次的技术演进趋势、功耗与能效计算模型、集成电路良率与成本的关系、系统可靠性与磁盘冗余阵列（RAID），以及计算机性能评测公式与定量设计准则。

---

## 技术与性能趋势

### 1. 五大硬件技术发展特征
* 集成电路逻辑（IC Logic）：集成度曾以摩尔定律发展，在 2015 年后由于漏电流和物理尺寸逼近原子极限而显著放缓。
* 半导体主存（DRAM）：容量大约每 3 年翻 4 倍，但近年来增速同样放缓。
* 半导体闪存（Flash）：作为个人移动设备（PMD）的非易失（Nonvolatile）存储，容量大约每 2 年翻一倍，每位成本比 DRAM 便宜约 8 到 10 倍。
* 磁盘（Magnetic Disk）：存储密度增长近年来已低于 5%，但其单位成本比闪存便宜约 8 到 10 倍，比 DRAM 便宜达 200 到 300 倍，是服务器与数据中心的核心支撑。
* 网络技术（Network）：发展强劲，但提升带宽（Bandwidth）明显比改善延迟（Latency）容易。

### 2. 带宽优先于延迟 (Bandwidth over Latency)
在各种性能提升技术中，**带宽/吞吐量（Bandwidth/Throughput）**的增长速度远快于**延迟/响应时间（Latency/Response Time）**的改善：

* 在微处理器和网络领域，带宽增长了 32000 到 40000 倍，而延迟仅改善了 50 到 90 倍。
* 在内存和磁盘领域（更侧重容量而非速度），带宽增长了 400 到 2400 倍，而延迟仅改善了 8 到 9 倍。

### 3. 特征尺寸与线延迟
随着晶体管**特征尺寸（Feature Size）**的缩小，晶体管性能呈线性提升且导线变短，但由于导线横截面积变小导致电阻电容延迟（RC delay）恶化，因此线延迟已成为限制系统性能的瓶颈。

---

## 功耗与能效

功耗指瞬时能量开销（决定配电与散热极限），能效关注完成某项任务所消耗的总能量（决定电池寿命与运行电费）。

### 1. 动态功耗与能量模型
晶体管在开关切换状态（0 到 1，或 1 到 0）时，会产生**动态功耗（Dynamic Power）**。

* **单次开关能量公式**：
  $E_{\text{dynamic}} \propto C \cdot V^2$
* **动态功耗公式**：
  $P_{\text{dynamic}} \propto C \cdot V^2 \cdot f$
  其中 $C$ 为负载电容，$V$ 为工作电压，$f$ 为开关频率。
* **降频并不降低总能量**：在恒定电压下，单纯降低时钟频率会降低瞬时功耗，但由于执行任务时间等比例延长，总能量消耗并不会减少。
* **调压调频（Dynamic Voltage-Frequency Scaling, DVFS）**：如果同时将电压与频率降低 15%，瞬时功耗将下降近 40%，且由于能量与电压平方成正比，总能量消耗也将显著降低。

### 2. 能效优化策略
1. **空闲关闭（Do nothing well）**：关闭非活跃模块的时钟或断电（门控时钟/电源门控）。
2. **Race-to-halt（跑完即停）**：使用主频极高且较耗能的处理器快速完成任务，然后迅速进入休眠状态，以使系统其他部分（如外设、内存）能尽早进入超低功耗模式，从而降低整机系统总能量。
3. **瞬时超频（Turbo Mode）**：允许芯片在短时间内超频运行，在温度触及上限前快速处理完高负载任务。

---

## 集成电路成本模型

随着芯片特征尺寸缩小到 5 纳米及以下，制造复杂度急剧上升。

### 1. 芯片成本与良率公式
晶圆上的芯片制造成本受良率支配：

$\text{Cost of die} = \frac{\text{Cost of wafer}}{\text{Dies per wafer} \times \text{Die yield}}$

其中，每个晶圆上的芯片数（Dies per wafer）估算公式为：

$\text{Dies per wafer} = \frac{\pi \times (\text{Wafer diameter} / 2)^2}{\text{Die area}} - \frac{\pi \times \text{Wafer diameter}}{\sqrt{2 \times \text{Die area}}}$

芯片良率（Die Yield，基于 Bose-Einstein 模型）估算公式为：

$\text{Die yield} = \text{Wafer yield} \times \left(1 + \frac{\text{Defects per unit area} \times \text{Die area}}{N}\right)^{-N}$

* $N$ 是工艺复杂度因子（通常取 11.5 到 14.5）。
* **良率改善策略**：在集成电路上设计**冗余单元（Redundancy）**。例如在 SRAM 或 DRAM 中设计多余的存储单元，若测试发现缺陷，可通过熔断机制替代损坏单元，大幅提升良率。

### 2. CAPEX 与 OPEX
传统的计算机设计主要关注资本支出（Capital Expenses, CAPEX，如购买芯片和服务器的硬件成本）。而在仓储级计算机（WSC）时代，包含数十万台服务器，运行期间的运营支出（Operational Expenses, OPEX，如电费、散热冷却开销）比制造购买成本更为显著。

---

## 可靠性与可信赖性

### 1. 故障、错误与失效的演进关系
系统在发生最终故障表现前，遵循以下因果演进链条：

$\text{故障 (Fault)} \longrightarrow \text{错误 (Error)} \longrightarrow \text{失效 (Failure)}$

* **故障（Fault）**：系统在物理层或设计层存在的缺陷。例如：程序中写错了加法公式（$60 + 35 = 90$），此时该缺陷是**潜伏错误（Latent Error）**。
* **错误（Error）**：故障被激活，导致系统内部状态处于不正确状态。例如：程序运行时调用了该加法函数。
* **失效（Failure）**：错误的系统内部状态传递到外部，导致系统提供的服务偏离了约定的规范。例如：系统把计算出的错误成绩（90分而非95分）正式提交了。
  * *注*：如果错误在造成偏离规范前被软件逻辑捕获（例如 `if (add(60,35) >= 86)` 而未影响输出结果），则称为非失效状态。

### 2. 可靠性测量指标
* **平均失效前时间（Mean Time to Failure, MTTF）**：系统从初始无故障运行至下一次发生故障的平均连续工作时间。
* **平均修复时间（Mean Time to Repair, MTTR）**：发生失效后修复并使系统恢复正常服务的平均时间。
* **平均失效间隔（Mean Time Between Failures, MTBF）**：
  $\text{MTBF} = \text{MTTF} + \text{MTTR}$
* **可用性（Availability）**：系统在特定时刻正常提供服务的概率：
  $\text{Availability} = \frac{\text{MTTF}}{\text{MTTF} + \text{MTTR}} = \frac{\text{MTTF}}{\text{MTBF}}$
* **FIT（Failures in Time）**：衡量每 10 亿小时内的失效次数的指标。
  $\text{MTTF} = 1,000,000 \text{ 小时} \implies \text{Failure rate} = 10^{-6} \text{ 次/小时} \implies 1000 \text{ FIT}$

### 3. 磁盘冗余阵列 (RAID) 级别对比
依靠物理硬件冗余（如镜像或校验）来防止单个物理故障导致失效：

| RAID 级别 | 冗余设计 | 空间开销与成本 | 容错能力 | 特征与局限 |
| :--- | :--- | :--- | :--- | :--- |
| **RAID 0** | 无冗余，条带化（Striping） | 0% | 0 块盘 | 读写速度快，但任意一块盘损坏则全部数据丢失 |
| **RAID 1** | 镜像（Mirroring） | 100% | 1 块盘 | 空间开销极大，一次逻辑写入需执行两次物理写入 |
| **RAID 2** | 位级拆分，海明码校验 | 依赖海明码位数 | 单盘纠错 | 硬件过于复杂，现代已不采用 |
| **RAID 3** | 字节级拆分，单奇偶校验盘（Parity Disk） | 1 块盘的容量 | 1 块盘 | 数据恢复采用奇偶校验位“减去”完好盘数据。瓶颈在单校验盘的频繁读写 |
| **RAID 4** | 块/扇区级独立读写，单奇偶校验盘 | 1 块盘的容量 | 1 块盘 | 允许独立读，但单校验盘写入时会产生严重并发瓶颈 |
| **RAID 5** | 块级独立读写，分布式奇偶校验（Distributed Parity） | 1 块盘的容量 | 1 块盘 | 将校验信息打散在所有盘中，消除了 RAID 4 单奇偶校验盘的写瓶颈 |
| **RAID 6** | 双重奇偶校验，行对角校验（Row-Diagonal Parity） | 2 块盘的容量 | 2 块盘 | 使用两组不同的校验算子，可容忍任意两块磁盘同时物理损坏 |

---

## 性能评测与定量设计原则

### 1. 性能测量
* **响应时间（Response Time）/ 延迟（Latency）**：用户看到任务完成所需的墙钟时间（Elapsed Time/Wall-clock Time），包括访存、I/O 以及操作系统开销。
* **吞吐量（Throughput）**：单位时间内系统完成的总工作量。
* **几何平均值（Geometric Mean）**：
  $$\text{Geometric Mean} = \sqrt[n]{\prod_{i=1}^n \text{SPECRatio}_i}$$
  在评测标准基准测试套件（如 SPEC CPU2017）时，各程序耗时归一化为参考机的比率后，必须使用几何平均值进行综合对比，以保证评估结果不受所选参考机的影响。

### 2. 局部性原理 (Principle of Locality)
计算机设计最基础的定量物理事实：程序大约 **90%** 的执行时间花费在仅 **10%** 的代码中。

* **时间局部性（Temporal Locality）**：最近访问过的数据/指令，在不久的将来大概率会再次访问（例如循环变量 `sum`、反复执行的循环体指令）。
* **空间局部性（Spatial Locality）**：物理地址相邻近的数据/指令，在时间上也倾向于连续被访问（例如顺序执行的指令流、连续读写的数组元素 `a[i]`）。

### 3. CPU 时间公式
评估处理器性能的黄金计算公式：
$$\text{CPU Time} = \text{Instruction Count (IC)} \times \text{CPI} \times \text{Clock Cycle Time}$$
这三个关键影响因子受到系统不同软硬件层次的制约：

* **时钟周期时间（Clock Cycle Time）**：受电路工艺和硬件微组织（Micro-organization）限制。
* **每指令时钟周期数（CPI）**：受微结构设计和指令集（ISA）设计限制。
* **指令数（Instruction Count）**：受指令集（ISA）设计和编译器（Compiler）优化技术限制。
