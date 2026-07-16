# Capture:D 架构文档

> 本文件描述 Capture:D 的系统架构、模块关系和数据流。
> 每次架构变更时必须同步更新本文件。

---

## 一、系统架构概览

```
┌─────────────────────────────────────────────────┐
│                    Capture:D                     │
├──────────┬──────────────────────┬────────────────┤
│ Share    │     Main App         │   Config       │
│ Extension│                      │                │
│          │  ┌─────────────────┐ │  Debug.xcconfig│
│ 分类选择  │  │   Features/     │ │  Release.      │
│ UI       │  │                 │ │  xcconfig      │
│          │  │ Collection      │ │  DISTRIBUTION  │
│ 写入     │  │ Detail          │ │  .md           │
│ App      │  │ Search          │ │                │
│ Group    │  │ Settings        │ │                │
│          │  │ RecycleBin      │ │                │
│          │  │ Onboarding      │ │                │
│          │  │ UnsortedFiles   │ │                │
│          │  └────────┬────────┘ │                │
│          │           │          │                │
│          │  ┌────────▼────────┐ │                │
│          │  │     Core/       │ │                │
│          │  │                 │ │                │
│          │  │ AI/             │ │                │
│          │  │ Storage/        │ │                │
│          │  │ Database/       │ │                │
│          │  │ Network/        │ │                │
│          │  │ Keychain/       │ │                │
│          │  └────────┬────────┘ │                │
│          │           │          │                │
│          │  ┌────────▼────────┐ │                │
│          │  │    Shared/      │ │                │
│          │  │                 │ │                │
│          │  │ Theme/          │ │                │
│          │  │ Components/     │ │                │
│          │  │ Extensions/     │ │                │
│          │  │ Models/         │ │                │
│          │  │ Constants/      │ │                │
│          │  └─────────────────┘ │                │
└──────────┴──────────────────────┴────────────────┘
```

---

## 二、目录结构

```
CaptureD/
├── App/                        # App 入口和生命周期
│   ├── CaptureDApp.swift
│   └── AppDelegate.swift
│
├── Features/                   # 按功能拆分，每个功能一个文件夹
│   ├── Collection/             # 首页瀑布流、文件列表、未整理文件入口
│   ├── Detail/                 # 文件内页面（纯文字 + 左滑图片浮层）
│   ├── Search/                 # 全局搜索
│   ├── Settings/               # 设置页（AI 配置 + 费用管理 + 存储 + 隐私）
│   ├── RecycleBin/             # 回收站
│   ├── Onboarding/             # 首次引导
│   └── UnsortedFiles/          # 未整理文件夹页面 + AI 分析触发按钮
│
├── Core/                       # 核心基础设施，不含 UI
│   ├── AI/                     # AI 接入层
│   │   ├── AIServiceProtocol.swift
│   │   ├── ClaudeService.swift
│   │   ├── DeepSeekService.swift
│   │   ├── DoubaoService.swift
│   │   ├── AIManager.swift
│   │   └── Prompts/            # 各分类的提示词配置
│   ├── Storage/                # 图片存储管理
│   ├── Database/               # SwiftData 模型定义和数据操作
│   ├── Network/                # 网络请求封装
│   └── Keychain/               # API Key 安全存储
│
├── Shared/                     # 跨模块复用
│   ├── Theme/                  # 全局样式
│   │   ├── AppTheme.swift
│   │   ├── ButtonStyles.swift
│   │   ├── CardStyles.swift
│   │   └── TextStyles.swift
│   ├── Components/             # 通用 UI 组件
│   ├── Extensions/             # Swift 扩展方法
│   ├── Models/                 # 跨模块共享数据结构
│   └── Constants/              # 分类定义、字符串常量
│
├── ShareExtension/             # Share Extension（独立 target）
│
├── Resources/                  # 资源文件
│   ├── Assets.xcassets
│   └── Localizable.strings
│
└── Config/                     # 构建和分发配置
    ├── Debug.xcconfig
    ├── Release.xcconfig
    └── DISTRIBUTION.md
```

---

## 三、模块依赖关系

```
ShareExtension
    │
    ├──→ App Group（共享文件空间）
    │
    ▼
Features/Collection ──→ Core/Database
    │                    Core/Storage
    ▼
Features/UnsortedFiles ──→ Core/AI
    │                       Core/Database
    │                       Core/Storage
    │                       Core/Network
    ▼
Features/Detail ──→ Core/Database
    │               Core/Storage
    ▼
Features/Settings ──→ Core/Keychain
    │                  Core/AI (配置)
    │                  Core/Storage (用量)
    ▼
Features/Search ──→ Core/Database
    ▼
Features/RecycleBin ──→ Core/Database
                        Core/Storage
```

### 依赖规则

- `Features/` 可以依赖 `Core/` 和 `Shared/`
- `Core/` 可以依赖 `Shared/`
- `Shared/` 不依赖任何其他层
- `Features/` 之间**不直接依赖**（通过 Core 层交互）
- `ShareExtension/` 只依赖 App Group 共享空间

---

## 四、数据模型（SwiftData）

### 4.1 核心实体

```
Category（分类）
├── name: String          // 小说/诗词/画风/歌曲
└── files: [CollectionFile]

CollectionFile（收藏文件）
├── title: String         // 如 "静夜思|李白"
├── category: Category
├── content: String       // AI 生成或用户编辑的文本
├── isUserEdited: Bool    // 用户是否编辑过
├── createdAt: Date
├── updatedAt: Date
├── images: [ImageRef]
└── status: FileStatus    // .sorted / .unsorted

ImageRef（图片引用）
├── imageID: String       // 对应 Storage 中的文件名
├── capturedAt: Date      // 存入时间
├── files: [CollectionFile]  // 反向关系（一图多文件）

ContentBlock（内容块 — 时间线式追加）
├── file: CollectionFile
├── text: String
├── isAIGenerated: Bool
├── createdAt: Date       // 用于时间隔断显示
```

### 4.2 关系说明

- `Category` 1:N `CollectionFile`
- `CollectionFile` N:N `ImageRef`（一图多分类）
- `CollectionFile` 1:N `ContentBlock`（时间线追加）

---

## 五、数据流

### 5.1 图片存入流

```
Share Extension
    │ 写入图片文件 + 分类 JSON 到 App Group
    ▼
主 App 启动
    │ 读取 App Group 中的待处理数据
    │ 创建 ImageRef → 存入 Core/Storage
    │ 创建 CollectionFile（status = .unsorted）→ 存入 Database
    │ 清除 App Group 中已处理的数据
    ▼
未整理文件夹显示
```

### 5.2 AI 分析流

```
用户在 UnsortedFiles 页面选中图片 → 点 AI 分析
    │
    │ 检查同一 ImageRef 是否在其他大类也有 unsorted 文件
    │ 构建 Prompt（图片 + 所有相关分类方向）
    │
    ▼
Core/AI/AIManager
    │ 根据用户选择的 AI 平台调用对应 Service
    │ 发送请求（队列化，逐一处理）
    ▼
AI 返回结果
    │ 校验出处名格式（必须为 X|Y）
    │
    ├── 格式合规 → 更新 CollectionFile（title、content、status = .sorted）
    │              检查是否已有同名文件 → 有则合并
    │
    └── 格式不合规 → 文件留在 unsorted，toast 提示
```

---

## 六、安全架构

| 层级 | 保护措施 |
|------|---------|
| API Key 存储 | iOS Keychain，系统级加密 |
| 网络传输 | HTTPS（所有 AI API 强制） |
| AI 费用 | 用户设月度上限，app 到达后停止请求 |
| 数据隔离 | App 不访问系统相册，独立存储 |
| 用户内容 | AI 不可覆盖用户编辑内容 |

---

## 七、架构变更记录

| 日期 | 变更 | ADR |
|------|------|-----|
| 2026-07-16 | 初始架构设计 | - |
