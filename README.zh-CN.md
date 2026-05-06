# apple-remove-bg

使用 Apple 原生 Vision 框架去除图片背景。**离线运行，零 API 费用，即时出图。**

底层调用 `VNGenerateForegroundInstanceMaskRequest` — 与照片 App、Safari、iMessage 中「抠图」功能使用相同的 AI 引擎。

[English](README.md)

## 环境要求

- macOS 14.0 (Sonoma) 或更高版本
- 搭载神经网络引擎的 Mac（Apple Silicon 全系，或 2018 年后的 Intel Mac）

## 安装

```bash
# 下载预编译二进制
curl -L -o remove-bg https://github.com/Muzileess290/apple-remove-bg/releases/latest/download/remove-bg
chmod +x remove-bg
```

或者克隆仓库并从源码编译：

```bash
git clone https://github.com/Muzileess290/apple-remove-bg.git
cd apple-remove-bg
swiftc apple-remove-bg/remove-bg.swift -o apple-remove-bg/remove-bg
```

## 使用方法

```bash
./remove-bg input.png output.png
```

```bash
# 批量处理
for f in *.png; do
  ./remove-bg "$f" "nobg/${f%.png}_nobg.png"
done
```

## 效果对比

AI 生成的游戏素材，一行命令完成去背景：

| 类型 | 处理前 | 处理后 |
|------|--------|--------|
| 民宅 | ![house before](demo/house_before.png) | ![house after](demo/house_after.png) |
| 商铺 | ![shop before](demo/shop_before.png) | ![shop after](demo/shop_after.png) |
| 工坊 | ![workshop before](demo/workshop_before.png) | ![workshop after](demo/workshop_after.png) |
| 学校 | ![school before](demo/school_before.png) | ![school after](demo/school_after.png) |

*AI 生成的冒险岛风格建筑精灵，每张仅需一条 `./remove-bg` 命令完成去背。*

## 工作原理

```
输入 PNG
  ↓ AppKit（NSImage → CGImage）
  ↓ VNGenerateForegroundInstanceMaskRequest（检测前景主体）
  ↓ CVPixelBuffer 遮罩
  ↓ CIBlendWithMask + 透明背景混合
  ↓ NSBitmapImageRep → PNG
输出 PNG（RGBA，含透明通道）
```

全程在设备端运行，仅使用系统自带的 Vision / CoreImage / AppKit 框架。无网络请求、无第三方依赖、无需 API Key。

## 适用场景

| 效果好                         | 效果差                          |
|-------------------------------|---------------------------------|
| 物体、产品、物品                | 无明确主体的平面场景               |
| 人物、动物、角色                | 抽象纹理                        |
| 建筑、载具、家具                | 俯视地形/远景                    |
| 前景主体清晰、轮廓分明           | 前景与背景高度融合                |

## 作为 Claude Code Skill 使用

将文件夹放入 `~/.claude/skills/apple-remove-bg/`：

```
~/.claude/skills/apple-remove-bg/
├── SKILL.md
├── remove-bg          # 编译好的二进制文件
└── remove-bg.swift    # 源码（可选）
```

然后在 Claude Code 中调用：

```
使用 apple-remove-bg 去掉 photo.png 的背景
```

## 开源协议

MIT
