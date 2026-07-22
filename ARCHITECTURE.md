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
│          │  ┌─────────────────┐ │  DISTRIBUTION  │
│ 分类选择  │  │   Features/     │ │  .md           │
│ 命名输入  │  │                 │ │  SETUP_GUIDE   │
│ 标签输入  │  │ Collection      │ │  .md           │
│ UI       │  │ Detail          │ │                │
│          │  │ Murmur          │ │                │
│ 写入     │  │ Settings        │ │                │
│ App      │  │ RecycleBin      │ │                │
│ Group    │  │ Onboarding      │ │                │
│          │  │ UnsortedFiles   │ │                │
│          │  │ Sidebar         │ │                │
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
│          │  │ Analytics/      │ │                │
│          │  │ Export/         │ │                │
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
│   └── ContentView.swift
│
├── Features/                   # 按功能拆分，每个功能一个文件夹
│   ├── Collection/             # 首页瀑布流 + 分类 tab + 内嵌搜索
│   ├── Detail/                 # 文件内页面（逐条编辑 + 追加 + 左滑图片浮层）
│   ├── Murmur/                 # 碎碎念时间线（Threads 风格）
│   ├── Settings/               # 设置页（AI 配置 + 费用管理 + 存储 + 隐私 + 导出）
│   ├── RecycleBin/             # 回收站
│   ├── Onboarding/             # 首次引导
│   ├── UnsortedFiles/          # 未整理文件夹页面 + AI 分析触发按钮
│   └── Sidebar/                # 侧边栏（热力图 + 关键词云）
│
├── Core/                       # 核心基础设施，不含 UI
│   ├── AI/                     # AI 接入层
│   │   ├── AIServiceProtocol.swift
│   │   ├── ClaudeService.swift
│   │   ├── DeepSeekService.swift
│   │   ├── DoubaoService.swift
│   │   ├── AIManager.swift
│   │   └── Prompts/            # 各分类的提示词配置
│   ├── Analytics/              # 活跃度追踪 + 关键词分析
│   ├── Storage/                # 图片存储管理
│   ├── Database/               # SwiftData 模型定义和数据操作
│   ├── Export/                 # 数据导出
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
│   │   ├── ComposeSheet.swift      # 统一输入（碎碎念/带图发布/编辑/追加）
│   │   ├── FloatingImageCard.swift  # 浮层图片卡片
│   │   ├── TimelineSeparator.swift  # Threads 风格时间标记
│   │   ├── TagFlowView.swift       # 标签流式布局
│   │   ├── TagChip.swift           # 标签胶囊
│   │   ├── TagInputView.swift      # 标签编辑输入
│   │   ├── WaterfallGrid.swift     # 瀑布流布局
│   │   ├── FABButton.swift         # 悬浮按钮
│   │   ├── EmptyStateView.swift    # 空白提示
│   │   └── KeyboardToolbar.swift   # 键盘工具栏
│   ├── Extensions/             # Swift 扩展方法
│   ├── Models/                 # 跨模块共享数据结构
│   └── Constants/              # 全局常量
│
├── ShareExtension/             # Share Extension（独立 target）
│
└── Config/                     # 构建和分发配置
    ├── SETUP_GUIDE.md
    └── DISTRIBUTION.md
```

---

## 三、模块依赖关系

```
ShareExtension
    │
    ├──→ App Group（共享文件空间：图片 + metadata.json 含 categories/name/tags）
    │
    ▼
App/ContentView ──→ Core/Database（统一发布：纯文字→碎碎念，带图→分类入库）
    │               Core/Storage
    ▼
Features/Collection ──→ Core/Database（内嵌搜索 + 分类组合过滤）
    │                    Core/Storage
    ▼
Features/UnsortedFiles ──→ Core/AI
    │                       Core/Database
    │                       Core/Storage
    │                       Core/Network
    ▼
Features/Detail ──→ Core/Database（逐条编辑 + 追加内容块）
    │               Core/Storage
    ▼
Features/Murmur ──→ Core/Database
    ▼
Features/Settings ──→ Core/Keychain
    │                  Core/AI (配置)
    │                  Core/Storage (用量)
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
CollectionFile（收藏文件）
├── title: String         // 如 "静夜思|李白"，未整理时为时间戳
├── categoryRawValue: String  // 找书/找诗/找画/找歌/碎碎念
├── statusRawValue: String    // sorted / unsorted / deleted
├── tags: [String]        // 用户自定义标签
├── createdAt: Date
├── updatedAt: Date
├── deletedAt: Date?      // 回收站用
├── images: [ImageRecord]
└── contentBlocks: [ContentBlock]  // @Relationship(deleteRule: .cascade)

ImageRecord（图片引用）
├── imageID: String       // 对应 Storage 中的文件名
├── capturedAt: Date      // 存入时间
├── thumbnailData: Data?  // 缩略图（@Attribute(.externalStorage)）
└── files: [CollectionFile]  // 反向关系（一图多文件）

ContentBlock: Identifiable（内容块 — 时间线式追加）
├── text: String
├── isAIGenerated: Bool
├── createdAt: Date       // 用于时间标记显示
└── file: CollectionFile?

PendingImage: Codable（Share Extension → 主 App 传输结构）
├── imageFileName: String
├── categories: [String]
├── savedAt: Date
├── name: String          // 用户填写的命名（可选）
└── tags: [String]        // 用户填写的标签（可选）
```

### 4.2 关系说明

- `CollectionFile` N:N `ImageRecord`（一图多分类）
- `CollectionFile` 1:N `ContentBlock`（时间线追加，cascade 删除）
- 分类通过 `categoryRawValue` 存储，运算属性 `category` 转换为 `CategoryType` 枚举

---

## 五、数据流

### 5.1 图片存入流（Share Extension）

```
Share Extension
    │ 用户选择分类（必选1+），可选填命名和标签
    │ 写入图片文件 + metadata.json（含 categories/name/tags）到 App Group
    ▼
主 App 启动
    │ 读取 App Group 中的待处理数据
    │ 创建 ImageRecord → 存入 Core/Storage
    │ 判断 name 格式：
    │   ├── 格式正确（X|Y）→ status = .sorted
    │   └── 格式错误或为空 → status = .unsorted
    │ 创建 CollectionFile → 写入 tags → 存入 Database
    │ 清除 App Group 中已处理的数据
    ▼
首页瀑布流 / 未整理文件夹显示
```

### 5.2 图片存入流（App 内 FAB 按钮）

```
用户点击右下角 + 号
    │ 弹出统一输入 Sheet（ComposeSheet）
    │
    ├── 纯文字 → 直接创建碎碎念（.murmur + .sorted）
    │
    └── 带图片 → 显示分类选择（必选1+）+ 命名框 + 标签框
        │ 发布时：
        │   ├── 命名格式正确 → status = .sorted
        │   └── 命名为空或格式错误 → status = .unsorted
        │ 文字作为 ContentBlock 存入
        ▼
    首页瀑布流 / 未整理文件夹显示
```

### 5.3 AI 分析流

```
用户在 UnsortedFiles 页面选中图片 → 点 AI 分析
    │
    │ 检查同一 ImageRecord 是否在其他大类也有 unsorted 文件
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

### 5.4 内容编辑流

```
用户进入 FileDetailView
    │
    ├── 点击某条 ContentBlock 旁的铅笔图标
    │   → 弹出 ComposeSheet（编辑模式）
    │   → 保存时调用 DatabaseManager.updateContentBlock() 原地更新
    │
    └── 点击底部"+ 追加"按钮
        → 弹出 ComposeSheet（追加模式）
        → 保存时调用 DatabaseManager.appendContentBlock() 新建 block
```

### 5.5 搜索流

```
用户点击首页搜索图标 → 顶部显示搜索栏
    │ 输入关键词（搜标题和标签）
    │
    ├── 无分类筛选 → database.search(query:) → 显示所有匹配结果
    │
    └── 有分类筛选 → database.search(query:, category:) → 显示同时满足的结果
    │
用户点击 Capture:D 标题 → 清空搜索 + 清空分类筛选 → 回到全部内容
```

---

## 六、安全架构

| 层级 | 保护措施 |
|------|---------|
| API Key 存储 | iOS Keychain，系统级加密 |
| 网络传输 | HTTPS（所有 AI API 强制） |
| AI 费用 | 用户设月度上限，app 到达后停止请求 |
| 数据隔离 | App 不访问系统相册，独立存储 |
| 用户内容 | AI 不可覆盖用户编辑内容；编辑为原地更新，不重复创建 |

---

## 七、架构变更记录

| 日期 | 变更 | ADR |
|------|------|-----|
| 2026-07-16 | 初始架构设计 | - |
| 2026-07-22 | 搜索内嵌至首页，删除独立 SearchView | - |
| 2026-07-22 | 统一发布流程（ComposeSheet 支持图片+分类+tag+命名） | - |
| 2026-07-22 | 内容编辑改为逐条编辑+追加，修复重复 block bug | - |
| 2026-07-22 | ShareExtension 增加 tag/命名输入 | - |
| 2026-07-22 | 时间线组件改为 Threads 风格 | - |
| 2026-07-22 | 图片画廊去白边，日期改为悬浮白字 | - |
| 2026-07-22 | 点击 CaptureD 标题回主界面 | - |
