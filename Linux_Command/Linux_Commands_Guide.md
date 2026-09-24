# Linux 常用核心指令全景实战手册

> 本手册专为 Linux 新手及操作系统课程实验（OS Lab）定制编写。
> 涵盖日常目录导航、文件操作、检索过滤、权限管理、进程监控及内核实验高频指令。每条指令均配有标准格式与真实场景 Example。

---

## 目录

- [零、核心基础概念速记](#零核心基础概念速记)
- [一、工作区移动与路径导航](#一工作区移动与路径导航)
- [二、文件与目录的创建、复制、移动与删除](#二文件与目录的创建复制移动与删除)
- [三、文件查看与简易编辑](#三文件查看与简易编辑)
- [四、查找与文本检索（代码工程核心）](#四查找与文本检索代码工程核心)
- [五、权限与用户管理](#五权限与用户管理)
- [六、归档压缩与解压（实验提交必备）](#六归档压缩与解压实验提交必备)
- [七、进程监控与系统资源管理](#七进程监控与系统资源管理)
- [八、操作系统实验（OS Lab）专项高频命令](#八操作系统实验os-lab专项高频命令)

---

## 零、核心基础概念速记

在 Linux 命令行中，以下特殊字符出现频率极高：

| 符号 | 代表含义 | 示例 |
| :--- | :--- | :--- |
| `~` | 当前登录用户的**家目录**（Home Directory） | `cd ~`（跳转到 `/home/insposhroom`） |
| `.` | **当前所在目录** | `./run.sh`（运行当前目录下的脚本） |
| `..` | **上一级父目录** | `cd ..`（返回上一级） |
| `/` | **根目录**（最顶层）或路径分隔符 | `/home/insposhroom/os_lab` |
| `-` | 上一次所在的旧工作目录 | `cd -`（在两个目录间来回切换） |

> **绝对路径 vs 相对路径**：
> - **绝对路径**：从根目录 `/` 开始写起，任何时候都唯一，如 `/home/insposhroom/os_lab`。
>     - **相对路径**：从“当前所在位置”出发写起，如 `os_lab/src` 或 `../linux`。

---

## 一、工作区移动与路径导航

### 1. `pwd` (Print Working Directory)
- **功能**：打印当前终端所在的工作区绝对路径。
- **格式**：
  ```bash
  pwd
  ```
- **Example**：
  ```bash
  insposhroom@DESKTOP:~$ pwd
  /home/insposhroom
  ```

---

### 2. `cd` (Change Directory)
- **功能**：切换当前工作区目录。
- **格式**：
  ```bash
  cd [目标路径]
  ```
- **常用参数与示例**：
  ```bash
  # 示例 1：进入特定子目录
  cd os_lab
  
  # 示例 2：直接回到当前用户的家目录（~）
  cd ~
  # 或者直接敲 cd 回车，效果完全相同
  cd
  
  # 示例 3：返回上一级父目录
  cd ..
  
  # 示例 4：向上返回两级目录
  cd ../..
  
  # 示例 5：快速切回上一次所在的目录（后悔药）
  cd -
  ```

---

### 3. `ls` (List)
- **功能**：列出目录下的文件和子文件夹。
- **格式**：
  ```bash
  ls [选项] [目录路径]
  ```
- **常用参数说明**：
  - `-l`：使用长格式详细列出（展示权限、属主、大小、修改时间）。
  - `-a`：列出**全部**文件，包括以 `.` 开头的隐藏文件。
  - `-h`：配合 `-l` 使用，以人类易读的方式展示文件大小（如 4K, 25M, 1.2G）。
  - `-t`：按修改时间排序（最近修改的文件排在前面）。
- **Example**：
  ```bash
  # 示例 1：最常用的经典组合，详细查看当前目录所有内容（含隐藏文件）
  ls -lah
  
  # 示例 2：查看指定目录下的内容，而不是当前目录
  ls -lh /home/insposhroom/os_lab
  ```

---

## 二、文件与目录的创建、复制、移动与删除

### 1. `mkdir` (Make Directory)
- **功能**：创建新的文件夹。
- **格式**：
  ```bash
  mkdir [选项] <文件夹名称>
  ```
- **常用参数**：
  - `-p`：递归创建多级父目录（如果上层目录不存在，自动一并创建，不会报错）。
- **Example**：
  ```bash
  # 示例 1：在当前目录下创建一个名为 lab0 的文件夹
  mkdir lab0
  
  # 示例 2：一键创建深层级联子目录
  mkdir -p os_lab/src/arch/riscv
  ```

---

### 2. `touch`
- **功能**：创建一个空白文件，或刷新已有文件的最后修改时间。
- **格式**：
  ```bash
  touch <文件名>
  ```
- **Example**：
  ```bash
  # 示例 1：在当前目录下创建一个空的 C 源码文件
  touch main.c
  
  # 示例 2：一次性创建多个空白文件
  touch test1.c test2.c config.h
  ```

---

### 3. `cp` (Copy)
- **功能**：复制文件或整个文件夹。
- **格式**：
  ```bash
  cp [选项] <源路径> <目标路径>
  ```
- **常用参数**：
  - `-r`：递归复制整个目录及其所有子文件（**复制文件夹时必须加此参数**）。
  - `-p`：保留文件的原始属性（修改时间、权限等）。
- **Example**：
  ```bash
  # 示例 1：在【当前目录】下复制一份副本并重命名（最常见的原地备份）
  cp main.c main_backup.c
  # 等价于: cp main.c ./main_backup.c
  
  # 示例 2：复制到【另一个目录】，文件名保持不变
  cp main.c backup/
  
  # 示例 3：复制到【另一个目录】的同时【修改名字】
  cp main.c backup/main_backup.c
  # 或者复制到上一级目录并改名：
  cp main.c ../main_backup.c
  
  # 示例 3：递归复制整个项目文件夹
  cp -r os_lab os_lab_backup
  ```

---

### 4. `mv` (Move)
- **功能**：移动文件/文件夹；也可以用于**重命名**文件/文件夹。
- **格式**：
  ```bash
  mv [选项] <源路径> <目标路径>
  ```
- **Example**：
  ```bash
  # 示例 1：重命名文件（把 old_kernel.img 改名为 kernel.img）
  mv old_kernel.img kernel.img
  
  # 示例 2：重命名文件夹
  mv test_dir project_dir
  
  # 示例 3：将文件移动到上级目录
  mv Image ../
  ```

---

### 5. `rm` (Remove)
- **功能**：删除文件或目录。
> ⚠️ **警告**：Linux 命令行没有“回收站”，一旦删除不可逆，请务必核对路径！
- **格式**：	
  ```bash
  rm [选项] <目标路径>
  ```
- **常用参数**：
  - `-r`：递归删除目录及其下所有内容。
  - `-f`：强制删除（不再弹出确认提示，忽略不存在的文件）。
  - `-i`：删除前逐个询问确认（新手推荐安全选项）。
- **Example**：
  ```bash
  # 示例 1：删除单个普通文件
  rm test.o
  
  # 示例 2：强制删除整个临时文件夹及其所有内容
  rm -rf build/
  
  # 示例 3：带交互提示的安全删除（会问你 y/n）
  rm -i main.c
  ```

---

## 三、文件查看与简易编辑

### 1. `cat` (Concatenate)
- **功能**：在终端直接打印出文件的全部内容（适合短小文件）。
- **格式**：
  ```bash
  cat [选项] <文件名>
  ```
- **常用参数**：
  - `-n`：显示行号。
- **Example**：
  ```bash
  # 示例 1：查看 Makefile 并带行号
  cat -n Makefile
  ```

---

### 2. `less`
- **功能**：分页交互式查看长文本（内核代码、大日志推荐）。
- **快捷键**：
  - `空格键` 或 `Page Down`：向下翻一页
  - `b` 或 `Page Up`：向上翻一页
  - `/关键词`：向下搜索（按 `n` 下一个，`N` 上一个）
  - `q`：退出阅读并返回终端
- **Example**：
  ```bash
  less /proc/cpuinfo
  ```

---

### 3. `head` 与 `tail`
- **功能**：分别查看文件开头或结尾的前几行。
- **常用参数**：
  - `-n <数字>`：指定行数（默认 10 行）。
  - `-f`：(`tail` 专用) 实时跟踪文件新增内容（常用于监控运行日志）。
- **Example**：
  ```bash
  # 示例 1：查看内核配置 .config 的前 20 行
  head -n 20 .config
  
  # 示例 2：查看编译日志 build.log 的最后 50 行
  tail -n 50 build.log
  
  # 示例 3：持续实时监控输出
  tail -f debug.log
  ```

---

### 4. `nano`
- **功能**：终端内最直观易上手的轻量级文本编辑器（新手友好）。
- **快捷键**：
  - `Ctrl + O`：保存文件
  - `Ctrl + X`：退出编辑器
  - `Ctrl + W`：搜索内容
- **Example**：
  ```bash
  nano main.c
  ```

---

## 四、查找与文本检索（代码工程核心）

### 1. `find`
- **功能**：在目录树中根据文件名、类型、修改时间搜索文件。
- **格式**：
  ```bash
  find <搜索路径> [匹配条件]
  ```
- **Example**：
  ```bash
  # 示例 1：在当前目录及子目录中搜索名为 rootfs.img 的文件
  find . -name "rootfs.img"
  
  # 示例 2：忽略大小写搜索所有以 .lds 结尾的链接脚本
  find . -iname "*.lds"
  
  # 示例 3：只搜索文件夹（-type d），名字叫 configs
  find . -type d -name "configs"
  ```

---

### 2. `grep` (Global Regular Expression Print)
- **功能**：在文件或输入流中搜索匹配指定文本/正则表达式的行。
- **格式**：
  ```bash
  grep [选项] "搜索文本" <文件或目录>
  ```
- **常用参数**：
  - `-r` 或 `-R`：递归搜索子目录下所有文件。
  - `-n`：显示匹配行号。
  - `-i`：忽略大小写。
- **Example**：
  ```bash
  # 示例 1：在当前目录所有 .c 代码中递归查找调用 start_kernel 的位置及行号
  grep -rn "start_kernel" *.c
  
  # 示例 2：在整个内核源码目录中查找特定宏定义
  grep -rn "CONFIG_RISCV" arch/riscv/
  ```

---

### 3. `which`
- **功能**：查看某个可执行命令在系统中的绝对物理路径。
- **Example**：
  ```bash
  # 检查编译器和模拟器是否正确安装在 PATH 环境变量中
  which riscv64-linux-gnu-gcc
  # 输出通常为: /usr/bin/riscv64-linux-gnu-gcc
  
  which qemu-system-riscv64
  ```

---

## 五、权限与用户管理

### 1. `sudo` (SuperUser DO)
- **功能**：以系统超级管理员（root）权限执行命令。
- **Example**：
  ```bash
  # 更新软件包列表需要管理员权限
  sudo apt update
  
  # 安装软件需要管理员权限
  sudo apt install gcc
  ```

---

### 2. `chmod` (Change Mode)
- **功能**：更改文件或目录的访问权限（可读 r、可写 w、可执行 x）。
- **Example**：
  ```bash
  # 示例 1：为脚本增加“可执行”权限（极常用）
  chmod +x run_qemu.sh
  
  # 示例 2：设置为标准权限（属主可读写执行，其他人只读执行）
  chmod 755 run_qemu.sh
  ```

---

### 3. `chown` (Change Owner)
- **功能**：更改文件的属主（所有者）与所属用户组。
- **Example**：
  ```bash
  # 将某文件夹的属主重新归还给 insposhroom 用户
  sudo chown -R insposhroom:insposhroom /home/insposhroom/os_lab
  ```

---

## 六、归档压缩与解压（实验提交必备）

### 1. `zip` 与 `unzip`
> 💡 **助教在 FAQ 中明确要求**：实验提交必须是跨平台兼容性最好的 `.zip` 格式，禁止提交 `.rar`！
- **Example**：
  ```bash
  # 示例 1：将当前目录的代码打包为 zip（-r 代表递归打包整个目录）
  zip -r OS-323xxx-张三-Lab0.zip src/ report.pdf
  
  # 示例 2：解压一个 zip 压缩包到当前目录
  unzip OS-323xxx-张三-Lab0.zip
  
  # 示例 3：解压到指定目录
  unzip OS-323xxx-张三-Lab0.zip -d target_folder/
  ```

---

### 2. `tar`
- **功能**：Linux 原生打包工具（通常与 gzip 配合为 `.tar.gz`）。
- **常用参数组合**：
  - `-czvf`：创建压缩包（c: 创建, z: gzip压缩, v: 打印进度, f: 指定文件名）
  - `-xzvf`：解压压缩包（x: 解包提取）
- **Example**：
  ```bash
  # 示例 1：解压 Linux 官方内核源码包（如 linux-6.11.tar.xz 用 xvf 自动识别）
  tar -xvf linux-6.11.tar.xz
  
  # 示例 2：将 my_code 打包压缩为 my_code.tar.gz
  tar -czvf my_code.tar.gz my_code/
  ```

---

## 七、进程监控与系统资源管理

### 1. `ps` (Process Status)
- **功能**：查看当前运行的进程快照。
- **Example**：
  ```bash
  # 搭配 grep 查找某个正在运行的 QEMU 进程
  ps aux | grep qemu
  ```

---

### 2. `kill`
- **功能**：通过进程 ID（PID）终止程序。
- **Example**：
  ```bash
  # 优雅停止进程 PID 1234
  kill 1234
  
  # 强制彻底杀死失控卡死或者后台驻留的进程（-9）
  kill -9 1234
  ```

---

### 3. `df` 与 `free`
- **功能**：查看磁盘与内存占用。
- **常用参数**：
  - `-h`：以人类易读的单位展示（G、M、K）。
- **Example**：
  ```bash
  # 查看当前各个磁盘分区的剩余容量
  df -h
  
  # 查看当前系统的物理内存使用与剩余
  free -h
  ```

---

### 4. 查看系统版本与内核信息
- **常用命令**：
  - `lsb_release -a`：查看 Linux 发行版名称、版本号与代号（如 Ubuntu 24.04 noble）
  - `cat /etc/os-release`：查看标准系统版本信息文件
  - `uname -r`：查看当前正在运行的 Linux 内核版本
  - `uname -a`：查看完整系统架构、主机名及内核版本
- **Example**：
  ```bash
  # 示例 1：最常用，清晰查看当前 Ubuntu 发行版本
  lsb_release -a

  # 示例 2：查看内核版本与 CPU 架构（如 x86_64 / aarch64 / riscv64）
  uname -m
  uname -r
  ```

---

## 八、操作系统实验（OS Lab）专项高频命令

### 1. `make` 系列命令
Linux 内核与驱动构建的核心，它的动作由目录下的 `Makefile` 定义：

| 实验高频命令 | 具体作用说明 |
| :--- | :--- |
| `make defconfig` | 使用当前平台默认配置生成 `.config` 文件 |
| `make ARCH=riscv defconfig` | **指定架构为 RISC-V**，生成 RISC-V 平台的默认配置 |
| `make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- -j$(nproc)` | **启动交叉编译**，`$(nproc)` 自动利用全核多线程并行加速编译 |
| `make clean` | 清除上一次编译生成的 object 目标文件（`.o`），保留配置文件 |
| `make mrproper` | **彻底清理**所有编译产物和 `.config` 配置文件（恢复为最干净的源码状态） |

---

### 2. 二进制与内核分析工具
- **`file`**：查看二进制文件的架构属性
  ```bash
  file vmlinux
  # 预期输出中应包含: ELF 64-bit LSB executable, UCB RISC-V
  ```
- **`riscv64-linux-gnu-objdump`**：反汇编 RISC-V 目标文件
  ```bash
  # 反汇编 main.o 并查看对应的汇编指令（-d）
  riscv64-linux-gnu-objdump -d main.o
  ```

---

### 3. QEMU 启动核心参数备忘

```bash
qemu-system-riscv64 \
    -nographic \                               # 纯命令行控制台输出，无需图形桌面窗口
    -machine virt \                            # 模拟 RISC-V virt 虚拟机主板
    -kernel path/to/arch/riscv/boot/Image \     # 指定内核二进制镜像
    -device virtio-blk-device,drive=hd0 \      # 挂载虚拟磁盘设备
    -append "root=/dev/vda ro console=ttyS0" \ # 内核启动命令行传参
    -bios default \                            # 使用默认 OpenSBI 作为引导加载程序
    -drive file=rootfs.img,format=raw,id=hd0 \ # 指定根文件系统镜像
    -S \                                       # 启动时冻结 CPU 执行，等待 GDB 信号
    -s                                         # 开启 GDB 服务端，监听端口 tcp::1234
```

> **如何退出卡住的 QEMU 命令行？**  
> 在 `-nographic` 模式下，依次按下组合键：**`Ctrl + A`**，松开后再按 **`X`** 即可立即强制退出 QEMU。

---

*手册生成位置：`E:\mkdocs\Linux_Command\Linux_Commands_Guide.md`*
