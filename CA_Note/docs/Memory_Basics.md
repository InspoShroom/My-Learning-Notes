# 第四章 存储层次结构基础

本章介绍了存储层次结构设计的基础知识，对比了 SRAM 与 DRAM 的物理实现，剖析了主存与非易失存储的发展和可靠性设计，并重点梳理了 Cache 的六大基础优化策略与虚拟内存/TLB的虚实地址映射机制。

---

## 主存技术与芯片架构

### 1. SRAM 与 DRAM 的对比
* **静态随机存取内存（Static RAM, SRAM）**：用于 Cache。每位数据由 **6 个晶体管**构成（利用锁存器原理）。不需要刷新，只要通电数据就不会丢失。存取速度快，访问时间（Access Time）与周期时间（Cycle Time）非常接近。
* **动态随机存取内存（Dynamic RAM, DRAM）**：用于主存。每位数据仅由 **1 个晶体管和 1 个电容**构成。读取数据时会破坏电容电荷，因此必须定期进行**刷新（Refresh）**操作，且读取后需重写。这导致其周期时间大于访问时间。DRAM 芯片通常组织在双列直插式内存模块（Dual Inline Memory Module, DIMM）上。

### 2. DRAM 的行/列读取机制
DRAM 芯片内部被划分为多个独立工作的 **Bank**，每个 Bank 呈行列网格状组织：

* **行激活**：行地址选通（Row Access Strobe, RAS）配合激活（Activate）命令，将整行数据搬运到**行缓冲器（Row Buffer）**中。
* **行缓冲命中（Row Buffer Hit）**：如果要访问的列数据已在行缓冲器中，直接通过列地址选通（Column Access Strobe, CAS）选出，延迟极低（利用了空间局部性）。
* **行缓冲冲突（Row Buffer Conflict）**：如果要访问的地址不在行缓冲器中，必须先执行预充电（Pre-charge）命令关闭当前行，然后再激活读取新行，会导致显著的延迟。

### 3. DRAM 技术的演进与优化
* **同步 DRAM（SDRAM）**：引入时钟信号与内存控制器同步，支持块传输。
* **双倍数据速率（Double Data Rate, DDR）**：在时钟信号的上升沿和下降沿同时传输数据，使总带宽翻倍。
* **多 Bank 交错（Multiple Banks）**：将芯片拆分为 2 到 8 个独立 Bank，支持重叠交错访存，提高并发带宽。
* **显存（Graphics DRAM, GDDR）**：针对 GPU 设计，拥有更宽的数据总线接口和更高的引脚时钟频率。
* **高带宽内存（High Bandwidth Memory, HBM）**：利用 3D 堆叠（Stacked）封装技术，将多颗 DRAM 芯片与 CPU 封装在同一中介层上，极大地缩短了互连线延迟，提供了惊人的带宽。

??? example "直接映射 Cache 地址冲突判定算例"
    在直接映射（Direct Mapped）Cache 中，判定两个物理地址是否发生冲突（映射到同一个 Cache 行但 Tag 不同），需要通过地址位划分来分析。
    
    **已知参数**：物理地址空间，Cache 总容量为 16 KB，块大小（Block Size）为 256 字节。
    **问题**：以下哪些地址会与物理地址 `0x12345678` 发生 Cache 行冲突？
    * 地址 A: `0x12345677`
    * 地址 B: `0x11335577`
    * 地址 C: `0x11115678`
    * 地址 D: `0x12341666`
    
    **计算推导**：
    1. 块内偏移量位数（Block Offset） = $\log_2(256\text{ 字节}) = 8$ 位（即物理地址最后 2 位十六进制数）。
    2. Cache 包含的总行数 = $16 \text{ KB} / 256 \text{ 字节} = 64$ 行 $\implies$ 索引位数（Index） = $\log_2(64) = 6$ 位。
    3. 将物理地址 `0x12345678` 转换为二进制：
       * 高位 Tag | 中位 Index (6位) | 低位 Offset (8位)
       * 地址 `0x12345678` 的低 16 位为 `0101 0110 0111 1000` (即二进制 `0x5678`)。
       * 低 8 位 Offset = `0111 1000` (`0x78`)。
       * 往高数的 6 位 Index = `0101 10` (二进制，其数值对应 `0x16`)。
    4. 对比四个候选地址：
       * **地址 A (`0x12345677`)**：低位 Offset 为 `0x77`，Index 同样为 `010110`，高位 Tag 也相同。说明它们映射在**同一个数据块**内，不发生冲突（只是同块访问命中）。
       * **地址 B (`0x11335577`)**：二进制低 16 位为 `0101 0101 0111 0111`，Index 部分为 `010101` (`0x15`)。映射到**不同的 Cache 组/行**，不发生冲突。
       * **地址 C (`0x11115678`)**：Index 同样为 `010110`，但高位 Tag 不同（`0x1111` vs `0x1234`）。映射到**同一 Cache 行但 Tag 不同**，**会发生冲突不命中（Conflict Miss）**。
       * **地址 D (`0x12341666`)**：二进制低 16 位为 `0001 0110 0110 0110`，其 Index 为 `010110`。Index 相同但 Tag 不同，**会发生冲突不命中**。

---

## 非易失存储与可靠性

### 1. 闪存（Flash Memory）
* **特征**：一类电可擦除可编程只读存储器（EEPROM），非易失性（Nonvolatile）。
* **读写限制**：在写入（覆写）数据之前，必须先将整个数据块（Block）进行**擦除（Erase）**。
* **寿命限制**：每个块的擦除写循环次数有限。因此控制器必须采用**磨损均衡（Wear Leveling）**技术，将写入请求均匀分摊到所有物理块上，防止单点提前损坏。
* **相变内存（Phase-Change Memory, PCM）**：新型非易失存储，写入前无需擦除，读写性能比闪存高数倍，适合用作新型固态硬盘（SSD）。

### 2. 内存可靠性设计
为了对抗由于外界辐射等引起的软错误（Soft Errors/Transient Faults）和器件损坏引起的硬错误（Hard Errors）：

* **奇偶校验（Parity）**：仅需 1 位开销，可检测单比特错误，无法纠错。
* **纠错码（Error-Correcting Code, ECC）**：通常以 64 位数据加 8 位校验位，实现单纠错双检错（SEC-DED）。
* **Chipkill 技术**：类似于磁盘 RAID 机制，将 ECC 信息 and 数据分散存放在不同的内存芯片中。即使整颗内存芯片彻底损毁，系统依然能自动恢复数据，避免服务器死机。
    * **无损故障率对比（以 3 年内 10000 核心服务器系统为例）**：
      * 仅奇偶校验：约 90,000 次不可恢复失败（每 17 分钟一次崩溃）。
      * 仅普通 ECC：约 3,500 次不可恢复失败（每 7.5 小时一次崩溃）。
      * Chipkill 技术：仅约 1 次不可恢复失败（每 2 个月一次崩溃），可靠性提升数万倍。

---

## Cache 性能与不命中分析

### 3C模型：Cache 缺失的原因

* **强制性缺失（Compulsory Miss）**：又叫做**冷启动缺失（Cold Miss）**。当程序第一次访问某个内存块时，这个数据一定不存在于cache中，因为cache刚开始是空的，或者此前没有访问过该数据。这个Miss是无法避免的，除非进行预取。

* **容量缺失（Capacity Miss）**：由于cache的总容量太小，无法容纳程序运行所需的全部数据而导致的Miss。这种缺失与映射策略无关，不论是全相联模式还是直接映射模式，都无法阻止Miss的发生。


* **冲突缺失（Conflict Miss）**：也叫做**碰撞缺失（Collision Miss）**。caceh是足够大的，但由于cache的映射策略，导致多个内存块被分配到了同一个cache line / cache set中，导致相互覆盖，发生Miss

### 性能折中规律与 2:1 规则

* **二分之一 Cache 规则（2:1 Cache Rule of Thumb）**：大小为 $N$ 的直接映射 Cache，其缺失率与大小为 $N/2$ 的两路组相联 Cache 大致相同。

* 设计权衡：提高相联度可减少冲突缺失，但由于比较器扇出增大，会增加hit time和功耗。

---

## 六大基础 Cache 优化策略
这六大优化方式，本质都是围绕着平均访存时间公式展开的：

**$AMAT=命中时间 (Hit Time)+不命中率 (Miss Rate)×不命中开销 (Miss Penalty)$**

### 1. 增大块大小（Larger Block Size）
* 原理：增大缓存中的 block 大小，一次可以拉取更多的相邻数据，利用了空间局部性，从而**减少了后续的compulsory miss**。
* 代价：会增加 Miss Penalty。在 cache 总容量不变时，块的数量变少导致容易相互覆盖，增加conflict miss。

### 2. 增大 Cache 容量（Bigger Caches）
* 原理：直接增大cache的总大小，从而**显著减少capacity miss**。
* 代价：会增加命中时间，也导致功耗和成本增加。

### 3. 提高相联度（Higher Associativity）
* 原理：从直接映射转向组相联或者全相联，可以**显著减少conflict miss**。
* 代价：每次查找要比较多个way和tag，需要更多的比较器电路，以及增加命中时间。

### 4. 多级 Cache 设计（Multilevel Caches）
L1 Cache 匹配 CPU 主频速度，而稍慢但容量大的 L2 Cache 作为中间的缓冲，**降低访存缺失开销**。一些相关的计算：

* **局部缺失率（Local Miss Rate）**：该级 Cache 缺失次数除以访问该级 Cache 的总次数。
* **全局缺失率（Global Miss Rate）**：该级 Cache 缺失次数除以 CPU 产生的所有访存请求数。对于 L2，其全局缺失率为：
  $\text{Global Miss Rate}_{\text{L2}} = \text{Miss Rate}_{\text{L1}} \times \text{Miss Rate}_{\text{L2_local}}$
* 多级包含（Multilevel Inclusion）：L1 的数据必定存在于 L2 中。简化了多核缓存一致性检查（只需监听 L2）。
* 多级互斥（Multilevel Exclusion）：L1 的数据绝不存在于 L2 中。L1 不命中时，会将 L1 和 L2 的数据块进行置换，增加了二级缓存的实际有效容量。

!!! tip "计算AMAT时的局部缺失率和全局缺失率"
    ​首先, 只有多级缓存结构(2级及以上)才有'全局缺失率'. 其实一级也有, 只不过它的局部缺失率和全局缺失率一致, 所以这里不做区分.

    对于局部缺失率, 这里以L2缓存为例, 那么它的局部缺失率就是**$MissRate_{L2,local} = \frac {L2缺失次数}{L2访问次数/L1缺失次数}$​**  , 而全局缺失率为 **$MissRate{L2,global} = \frac {L2缺失次数} {CPU发出的总访问次数}$​** . 两者之间还是有一定的差别.

    又因为 **$L1_{缺失次数}=CPU访问总次数 \times MissRate_{L1}$​​**, 所以通过代换可以得到: 
    
    **$MissRate_{L2,global} = MissRate_{L1} \times MissRate_{L2,local}$​**

    最终对于两个角度的AMAT计算公式:

    $局部缺失率: AMAT = H1 + MR1 \times (H2+MR_{L2,local} \times MP2)$​

    $全局缺失率: AMAT = H1 + MR1 \times H2 + MR_{L2,global} \times MP2$

??? example "两级缓存不命中率与延迟计算示例"
    **已知条件**：
    在 1000 次主存访问参考中，L1 缓存不命中 40 次，L2 缓存不命中 20 次。L2 缓存命中时间为 10 周期，L2 缺失至主存的惩罚为 200 周期，L1 缓存命中时间为 1 周期。平均每条指令包含 1.5 次访存参考。
    
    **计算求解**：
    1. **各项不命中率**：
       * L1 不命中率（本地/全局一致） = $40 / 1000 = 4\%$。
       * L2 本地不命中率（Local Miss Rate） = L2 缺失次数 / L2 访问次数 = $20 / 40 = 50\%$。
       * L2 全局不命中率（Global Miss Rate） = L2 缺失次数 / 总访存参考数 = $20 / 1000 = 2\%$。
    2. **平均访存时间（AMAT）**：
       * $\text{AMAT} = 1 + 0.04 \times (10 + 0.50 \times 200) = 1 + 0.04 \times 110 = 5.4 \text{ 周期}$。
       * 或用全局公式：$\text{AMAT} = 1 + 0.04 \times 10 + 0.02 \times 200 = 1 + 0.4 + 4 = 5.4 \text{ 周期}$。
    3. **每指令平均访存挂起周期数（Memory Stalls per Instruction）**：
       * $\text{Stalls/Instruction} = 1.5 \times (\text{AMAT} - 1) = 1.5 \times 4.4 = 6.6 \text{ 周期}$。
       * 或利用 misses/instruction 展开计算：
         $$\text{Stalls/Instruction} = \left( 1.5 \times \frac{40}{1000} \right) \times 10 + \left( 1.5 \times \frac{20}{1000} \right) \times 200 = 0.6 + 6.0 = 6.6 \text{ 周期}$$




### 5. 写缓冲读优先（Prioritize Read Misses over Writes）
发生写操作时，数据先写入写缓冲区。发生Read Miss时，无需等待写缓冲区清空，而是在确认读地址与写缓冲区中的地址无冲突后，直接插队优先访问主存，以**显著减少读操作的不命中开销**。

### 6. 虚索引实标签（Virtually Indexed, Physically Tagged, VIPT）
当CPU想要读一个数据时，它使用的是虚拟地址，需要先进行翻译，然后进行寻址，这就是 **PIPT cache（Physical Indexed, Physically Tagged）** 的工作原理。这整个过程是串行的，所以速度受限。而 **VIPT cache** 将这两个操作并行处理，来**加速命中**。

同理还可以列出 VIVT cache 和 PIVT cache，前者速度最快，管理最复杂，但是存在严重的别名冲突问题，所以现在CPU极少使用；后者则知识理论存在，但毫无优势，实际不被采用。

* **工作原理**：在将 VA（Vierrtual Address）通过 TLB 转换为 PA（Physical Address）的同时，直接利用虚拟地址末尾的页内偏移量（Page Offset, 比如10bit用来确定index，2bit用来确定byte-offset）寻找 L1 Cache 中对应的 index，然后将其中各个 way 的 tag 和结果都读出到寄存器中。当 TLB 转换出物理地址后，再将该物理地址的 Tag 与 Cache 选中行的物理 Tag 进行并行比较匹配，来找到正确的数据。
* **别名**：因为虚实地址在翻译时 page offset 保持不变，所以两个不同的 VA 可能指向同一个 PA。这在操作系统中是很常见的，通常被称为分享内存。
* **缺点**
    * **别名冲突**：如果 cache 设计不当，导致这些 VA 映射到不同的 set-index 时，就会造成大麻烦。

    ??? example "别名冲突的例子"
        假设 VA1 和 VA2 都指向 0x5000，且0x5000 中本来存放了数据99。

        现在 CPU 想写入数据100，假如它使用了 VA1，并对应到了 cache 的第2组，在将数据读到 cache 后，它将里面的值改为了100。注意此时这个100还没有被写回。
        
        当 CPU 紧接着要读取 0x5000 中的数据时，如果此时使用的是 VA2，而这个虚拟地址映射到了第6组，同时发生了 miss。那么它从内存中读取到 cache 的数据还是旧值99。
        
        现在，对于同一个物理地址，在 cache 中就存在了两份不同的数据，这样程序运行时读出的数据就会不稳定，导致崩溃或者计算错误。

!!! danger "VIPT Cache 别名冲突判定限制"
    在 VIPT 中，无别名冲突的物理限制公式为：

    **$\text{Index} + \text{Offset} \le \text{Page Offset}$**

    可以这样理解：我们的目的同一个 PA 对应地所有 VA，算出来的 cache index 必须相同，而这一部分的计算就依赖于 page offset。也就是说：

    $index + block\_offset = 寻址所需要的总位数$

    因为 page offset 是固定不变的，它是根据页的大小来确定的。对于 4KB 大小的页，它的 index 就需要 10 bit，block offset 需要 2 bit。但是在 cache 中进行寻址时，如果 cache 过大，它的 index 需求就会增加，那么通过 PA 确定时，它的 index 部分就会被迫使用第12位或者更高位，别名冲突就有可能发生。
    
    如果 $寻址总位数 ≤ page\_offset \space 对应的总位数$
    
    这就说明：不论虚拟地址高位怎么变，只要映射到同一个 PA，page offset 就一定相同，所以算出的 index 也就一定相同，数据只会被放入同一个 cache 中，避免了别名冲突。

    上面的公式等价于：**单路大小（Set Size）≤ 系统页大小（Page Size）**。

    如果直接映射 Cache（相联度为 1）的容量大于页大小，**必定会产生别名冲突**！为了消除冲突，必须通过**增加相联度**（如设计为 4 路组相联，使每路大小 $\le$ 页大小）来压缩单路容量。


---

## 虚拟内存与TLB机制

### 1. 存储分层设计的 4 大问题(4Q)
* **Q1：块的放置** 采用**全相联（Fully Associative）**策略。因为磁盘访问（发生缺页 Page Fault）的惩罚高达数百万周期，必须使用最灵活的放置策略来尽可能降低不命中率。
* **Q2：块的查找** 通过常驻主存的**页表（Page Table）**将虚拟页号（Virtual Page Number, VPN）翻译为物理页框号（Physical Page Number, PPN）。若 Valid 位无效则触发缺页异常，由操作系统从磁盘调入页。
* **Q3：块的替换** 采用**最近最少使用（LRU）**或近似算法，通过操作系统定期清零并统计使用位（Use/Reference Bit）实现。
* **Q4：写入策略** 必须采用**写回（Write-back）**策略，利用脏位（Dirty Bit）标记已修改的页，仅在页被换出时写回磁盘。

### 2. TLB的设计
为了避免每次数据访问都查询页表造成双倍访存延迟，CPU 引入了专门缓存翻译项的**快表/页表缓存/旁路转换缓冲（Translation Lookaside Buffer, TLB）**：

关于 TLB 的介绍可以参考：[知乎专栏：深入理解 TLB](https://zhuanlan.zhihu.com/p/528949613)

* 内容：Tag 存放 VPN 的部分位，Data 存放 PPN、保护属性、Valid 位、Dirty 位和 Use 位。
* 多进程支持：在上下文切换（Context Switch）时，需要清空 TLB，或者在 TLB 中引入进程上下文标识符（Process-Context Identifier, PCID）以区分不同进程的映射。

### 3. 页大小折中
* **支持大页的优势**：减小页表大小（节省主存开销）、减少 TLB 不命中、磁盘传输大块数据更高效。
* **支持小页的优势**：减少因内存未对齐和进程段尾部未填满导致的**内部碎片（Internal Fragmentation）**，节约物理主存。
* **折中方案**：现代处理器通常支持**多种页大小（Multiple Page Sizes）**并存。

---

## 虚实地址翻译示例

### 1. 参数
* VA width：64 bits
* PA width：40 bits
* Page Size：16 KiB ($2^{14}$ B)
* L1 Cache：16 KiB，Block Size = 64B，direct Mapping
* TLB：256 Entries，2-way Associative

### 2. 字段位数划分
* **页内偏移量与页号划分**：
    * 页面大小 16 KiB $\implies$ Page Offset为 **14 位**（VA 和 PA 的低 14 位相同）。
    * 虚拟页号（Virtual Page Number, VPN）宽度 = $64 - 14 =$ **50 位**。
    * PPN 宽度 = $40 - 14 =$ **26 位**。

* **L1 Cache 地址划分**：
    * 块大小 64B $\implies$ 块内偏移（Block Offset）为 **6 位**。
    * L1 总容量 16 KiB，直接映射，块数 = $16\text{ KiB} / 64\text{B} = 256$。
    * 索引位（Index）宽度 = $\log_2(256) =$ **8 位**。
    * L1 物理标签位（Tag）宽度 = 物理地址宽度 - Index - Block Offset = $40 - 8 - 6 =$ **26 位**。
    * *VIPT 别名验证*：L1 Cache 的 Index + Block Offset = $8 + 6 = 14$ 位，刚好等于 Page Offset 的 14 位。由于 Index 索引只使用了 Page Offset 范围内的虚拟地址位，故 L1 完全符合 VIPT 运行条件且**无任何别名冲突风险**。

* **TLB 地址划分**：
    * 总条目 256 个，两路组相联 $\implies$ 组数（Sets） = $256 / 2 = 128$。
    * TLB 索引位（TLB Index）宽度 = $\log_2(128) =$ **7 位**。
    * TLB 标签位（TLB Tag）宽度 = VPN 宽度 - TLB Index = $50 - 7 =$ **43 位**。
