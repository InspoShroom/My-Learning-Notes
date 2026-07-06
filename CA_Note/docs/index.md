# 计算机体系结构 (CompArch)

---

## 目录

* **[第一章: 引言](Introduction.md)**

    计算机体系结构定义与分类、设计方向与并行性级别（DLP/TLP/RLP）、Dennard Scaling 终结对多核演进的倒逼。

* **[第二章: 计算机设计基础-基础篇](Fundamentals_Basics.md)**
  
    经典指令集架构（ISA）分类、操作数寻址方式、RISC-V 32位经典五阶段流水线与数据冲突。

* **[第三章: 趋势与性能评测](Trends_Performance.md)**
  
    摩尔定律与性能发展趋势、性能评估铁律与阿姆达尔定律、Little's Law 与排队模型计算。

* **[第四章: 存储层次结构基础](Memory_Basics.md)**
  
    SRAM/DRAM/HBM 芯片技术与可靠性（ECC/Chipkill）、Cache 3C 模型、6大基础缓存优化与 VIPT 无别名约束条件、TLB 与虚实地址翻译。

* **[第五章: 存储层次结构高级篇](Memory_Advances.md)**
  
    10大高级缓存优化技术分类大纲、虚拟机监控器（VMM/Hypervisor）特权硬件拦截、ARM 与 Intel 存储实例比对。

* **[第六章: 指令级并行与静态调度](ILP_Static.md)**
  
    浮点多周期流水线（延迟与重复间隔）参数、WAW 与结构冲突检测电路、MIPS R4000 八阶段流水、循环展开与静态调度、迹调度。

* **[第七章: 指令级并行与动态调度](ILP_Dynamic.md)**
  
    动态分支预测器演进、Scoreboard 记分牌与 Tomasulo 动态调度算法、寄存器重命名机制、重排序缓冲区（ROB）精确中断投机。

* **[第八章: 硬件级并行发掘](ILP_Exploitation.md)**
  
    多发射（超标量与 VLIW）设计冲突、双发射有无投机状态的时空时延对比、BTB 与 RAS 预测、细/粗粒度及同时多线程（SMT）机制。

* **[第九章: 数据级并行与矢量/GPU架构](DLP_Architecture.md)**
  
    RV64V 矢量寄存器动态宽度与 MVL 配置、向量车队 Chime 耗时计算、Stride 步长与多 Bank 冲突 LCM 判定算例、多媒体 SIMD 三大删减与屋顶图模型、GPU SIMT 线程 Warp 二级调度与分支同步栈。

* **[第十章: 数据级并行发掘](DLP_Exploitation.md)**
  
    循环携带相关性与递推环路判定、仿射索引与最大公约数（GCD）测试冲突方程检测、名字相关标量展开消除与多处理器并行归约化重构。

* **[第十一章: 线程级并行与缓存一致性](TLP_Coherence.md)**
  
    SMP/UMA 与 DSM/NUMA 对比、多核阿姆达尔计算、远程内存通信延迟 CPI 变慢折算、缓存一致性三大属性、Snooping 监听协议（MSI/MESI/MOESI/MESIF 状态转移与过滤总线流量机理）、真伪共享不命中判定步骤 trace、分布式目录协议读写 Miss 消息控制流。

* **[第十二章: 线程级并行与内存一致性](TLP_Consistency.md)**
  
    硬件原子指令对（RISC-V `lr/sc` 保留寄存器实现）、自旋锁缓存一致性优化（读自旋与 `lr/sc` 过滤写流量）、内存一致性模型对比（SC/TSO/PSO/RC）与 Acquire/Release 重排边界约束、硬件投机 ROB 延迟提交与投机恢复。

* **[第十三章: 线程级并行发掘](TLP_Exploitation.md)**
  
    商业多核架构（SPARC64, Power8, Xeon E7）、阿姆达尔定律三道综合应用算例。

* **[第十四章: 课程期末复习](Course_Review.md)**
  
    全书核心计算公式汇总（性能、Cache、DLP、TLP）、核心算法横向比对、Acquire/Release 限制边界图解。
