# dlog — DJI D-Log 视频色彩转换工具

将大疆无人机拍摄的 D-Log / D-Log M 灰色视频一键转换为 Rec.709 标准色彩。

基于 **ffmpeg + 3D LUT**，macOS 硬件加速编码，支持批量处理。

---

## 快速开始

```bash
# 安装
cd /path/to/dji
make install-user

# 使用 — 就这么简单
cd /path/to/your/videos
dlog
```

无需任何参数，`dlog` 会自动找到当前目录下所有 `_D.MP4` 文件（即 D-Log 拍摄的视频），用默认的 vivid 鲜艳模式转换。

---

## 安装

### 前置依赖

- **ffmpeg** — 视频处理引擎
  ```bash
  brew install ffmpeg
  ```

- **DJI 官方 LUT 文件** — 色彩转换查找表
  - 下载地址: [dji.com/lut](https://www.dji.com/lut)
  - 根据你的机型下载对应的 `.cube` 文件
  - 将下载的 `.cube` 文件放到项目根目录下

### 安装方式

**用户级安装**（推荐，无需 sudo）：

```bash
make install-user
```

安装位置：
- 可执行文件: `~/.local/bin/dlog`
- LUT 文件: `~/.local/share/dlog/`

如果 `~/.local/bin` 不在 PATH 中，需要添加：

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

**系统级安装**：

```bash
sudo make install
```

安装位置：
- 可执行文件: `/usr/local/bin/dlog`
- LUT 文件: `/usr/local/share/dlog/`

### 卸载

```bash
make uninstall-user    # 用户级
sudo make uninstall    # 系统级
```

---

## 使用方法

### 基本用法

```bash
# 最简单 — 自动转换当前目录所有 _D 视频
dlog

# 转换指定文件
dlog DJI_0001_D.MP4

# 转换多个文件
dlog DJI_0001_D.MP4 DJI_0002_D.MP4

# 转换目录下所有视频
dlog ./footage/
```

### LUT 预设切换

工具内置三种 LUT 预设，通过 `-l` 参数快速切换：

| 预设 | 说明 | 命令 |
|------|------|------|
| `vivid` | 鲜艳模式，色彩饱和对比高 **（默认）** | `dlog` 或 `dlog -l vivid` |
| `std` | 标准模式，色彩自然准确 | `dlog -l std` |
| `dlogm` | D-Log M 专用转换 | `dlog -l dlogm` |

```bash
# 鲜艳模式（默认）
dlog *.MP4

# 标准自然色彩
dlog -l std *.MP4

# D-Log M 转换
dlog -l dlogm *.MP4

# 查看已安装的 LUT 文件
dlog --list
```

### 自定义 LUT

如果有自己的 LUT 文件，可以直接用 `--lut` 指定：

```bash
dlog --lut /path/to/custom_lut.cube *.MP4
```

### 编码选择

```bash
# H.265 — 默认，文件小，画质好，macOS 硬件加速
dlog *.MP4

# H.264 — 兼容性最好，macOS 硬件加速
dlog -c h264 *.MP4

# ProRes 422 HQ — 专业剪辑格式，文件很大
dlog -c prores *.MP4
```

### 质量控制

```bash
# 默认质量 (CRF 22)
dlog *.MP4

# 高质量 (CRF 18，文件更大)
dlog -q 18 *.MP4

# 指定固定码率
dlog -b 30M *.MP4
```

### 输出控制

```bash
# 输出到指定目录
dlog -o ./output *.MP4

# 自定义输出后缀 (默认 _rec709)
dlog -s _graded *.MP4
# 输入: DJI_0001_D.MP4 → 输出: DJI_0001_D_graded.MP4
```

### 批量处理

```bash
# 预览（不实际转换）
dlog -n *.MP4

# 覆盖已有文件
dlog -y *.MP4

# 2 路并行转换
dlog -j 2 *.MP4

# 显示详细 ffmpeg 输出
dlog -v *.MP4
```

---

## 命令参考

```
dlog v1.2.0

用法:
  dlog                            转换当前目录所有 _D 视频 (默认 vivid)
  dlog <文件...>                  转换指定文件
  dlog -l std <文件...>           用标准 LUT 转换
  dlog -l dlogm <文件...>        用 D-Log M LUT 转换

选项:
  -l, --look <预设>          LUT 预设 (vivid/std/dlogm, 默认: vivid)
  --lut <文件.cube>          使用自定义 LUT 文件
  --list                     列出可用的 LUT 文件
  -c, --codec <编码>         h264/h265/prores (默认: h265)
  -q, --quality <数字>       质量 (默认: 22, 越小越好)
  -b, --bitrate <码率>       固定码率, 如 30M
  -o, --output-dir <目录>    输出目录
  -s, --suffix <后缀>        输出后缀 (默认: _rec709)
  -j, --parallel <数>        并行数 (默认: 1)
  -y, --overwrite            覆盖已有文件
  -n, --dry-run              仅预览
  -v, --verbose              详细输出
  -V, --version              版本
  -h, --help                 帮助
```

---

## 输出文件

默认输出在源文件同目录下，文件名加 `_rec709` 后缀：

```
输入:  /path/to/DJI_0001_D.MP4
输出:  /path/to/DJI_0001_D_rec709.MP4
```

ProRes 编码时输出为 `.mov` 格式。

---

## LUT 预设配置

LUT 预设通过脚本顶部的 `LUT_MAP` 映射表配置，格式为 `简称|文件名`：

```bash
LUT_MAP="
vivid|DJI Mavic 4 Pro D-Log to Rec.709 vivid V1.cube
std|DJI Mavic 4 Pro D-Log to Rec.709 V1.cube
dlogm|DJI Mavic 4 Pro D-Log M to Rec.709 V1.cube
"
```

### 新增 LUT 预设

1. 从 [dji.com/lut](https://www.dji.com/lut) 下载 `.cube` 文件
2. 将文件放到项目根目录
3. 编辑 `dlog` 脚本，在 `LUT_MAP` 中添加一行：
   ```
   新预设名|新文件名.cube
   ```
4. 重新安装：`make install-user`

### 更换机型

如果更换了无人机型号，只需：

1. 下载新机型的 LUT 文件
2. 替换 `LUT_MAP` 中对应的文件名
3. 重新安装

---

## 背景知识

### 什么是 D-Log？

D-Log 是大疆的对数（Log）色彩模式，类似于 Sony 的 S-Log、Canon 的 C-Log。它是一种低对比度、低饱和度的拍摄模式，通过压缩高光和阴影来保留更多动态范围，专为后期调色设计。

### D-Log vs D-Log M

| | D-Log | D-Log M |
|---|-------|---------|
| 动态范围 | ~14 档 | ~12-13 档 |
| 用途 | 专业调色 | 日常拍摄后期 |
| 灰度 | 更灰 | 稍微灰一些 |
| 适用场景 | 复杂光线/高反差 | 一般场景 |

两者的传递函数不同，**LUT 不能混用**。

### 为什么看起来灰蒙蒙的？

这是正常的。D-Log 素材就像数码"底片"，需要后期"冲洗"（色彩转换/调色）才能呈现正常色彩。`dlog` 工具通过 3D LUT 完成这个转换。

### 文件名规则

DJI 视频文件名后缀含义：

| 后缀 | 拍摄模式 |
|------|---------|
| `_D.MP4` | D-Log 或 D-Log M |
| `_N.MP4` | Normal 普通模式 |
| `_HLG.MP4` | HLG HDR 模式 |

### 三种 LUT 的区别

| LUT | 色彩风格 | 适用场景 |
|-----|---------|---------|
| vivid | 鲜艳饱和，对比度高 | 风景、旅行视频 |
| std | 自然准确，适合调色 | 需要进一步调色的素材 |
| dlogm | D-Log M 标准转换 | D-Log M 模式拍摄的素材 |

---

## 技术细节

### ffmpeg 处理流程

```
输入视频 → lut3d 滤镜 (3D LUT 色彩映射) → 硬件编码器 → 输出视频
              ↑                                ↑
        .cube LUT 文件              VideoToolbox (macOS)
        tetrahedral 插值             或 libx264/libx265
```

### 编码器选择

在 macOS 上，工具会自动检测并优先使用 Apple VideoToolbox 硬件编码器：

| 编码 | 硬件加速 (macOS) | 软件回退 |
|------|-----------------|---------|
| H.264 | `h264_videotoolbox` | `libx264` |
| H.265 | `hevc_videotoolbox` | `libx265` |
| ProRes | `prores_ks` | `prores_ks` |

硬件加速编码速度通常是软件编码的 3-10 倍。

### 环境变量

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `DLOG_DATA_DIR` | 自定义 LUT 文件目录 | `~/.local/share/dlog` 或 `/usr/local/share/dlog` |

---

## 项目结构

```
dji/
├── dlog                    # 主工具脚本 (bash)
├── Makefile                # 安装/卸载
├── docs/
│   └── README.md           # 本文档
├── *.cube                  # LUT 文件 (不入库，.gitignore)
└── .gitignore
```

LUT 文件（`.cube`）通过 `.gitignore` 排除在 Git 仓库之外，需要用户自行从 DJI 官网下载。
