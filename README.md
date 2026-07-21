# CaptureD 项目结构说明

> 本文件夹是 Capture:D 项目的最终版唯一交付物。

---

## 目录总览

```
CaptureD/
├── PROJECT_RULES.md          ← 开发规范（唯一权威）
├── ARCHITECTURE.md           ← 架构文档
├── DEVELOPMENT_LOG.md        ← 开发日志
├── README.md                 ← 本文件
│
├── ADR/                      ← 架构决策记录（6 文件）
├── App/                      ← App 入口（2 文件）
├── Core/                     ← 底层服务（11 文件）
├── Features/                 ← UI 功能模块（15 文件）
├── Shared/                   ← 通用组件/主题/常量（12 文件）
├── ShareExtension/           ← 分享扩展（1 文件）
├── Config/                   ← 设置指南 + 分发指南（2 文件）
└── Resources/                ← 资源文件（待添加图标等）
```

---

## 各目录详细说明

### PROJECT_RULES.md
项目唯一权威开发规范。覆盖开发流程、架构规范、代码规范、测试规范、文档规范、Git 规范、ADR 规范、重构规范和 Capture:D 专项规范。所有开发行为必须以此为准。

### ARCHITECTURE.md
系统架构文档。包含目录结构、模块依赖关系图、SwiftData 数据模型定义、数据流说明和安全架构。

### DEVELOPMENT_LOG.md
开发日志。按时间倒序记录每次开发内容、决策原因、遇到的问题和下一步计划。

---

### ADR/（6 文件）
架构决策记录。每条 ADR 记录一个重大架构决策的背景、决定和后果。

| 文件 | 决策内容 |
|------|---------|
| 000-record-architecture-decisions.md | 采用 ADR 记录架构决策 |
| 001-share-extension-as-only-entry.md | Share Extension 作为唯一图片入口 |
| 002-ai-manual-trigger-only.md | AI 完全手动触发，不自动运行 |
| 003-no-photo-library-access.md | 废除相册权限，App 完全独立 |
| 004-merge-unsorted-folders.md | 合并"未分析"和"未知来源"为"未整理" |
| 005-file-naming-convention.md | 文件命名规范：作品名\|作者 格式 |

---

### App/（2 文件）
App 入口和生命周期管理。

| 文件 | 职责 |
|------|------|
| CaptureDApp.swift | SwiftUI App 入口，启动时处理 Share Extension 写入的待处理图片 |
| ContentView.swift | 根视图，判断是否完成引导，切换引导页或主界面 |

---

### Core/（11 文件）
核心基础设施层，不包含任何 UI 代码。被 Features 层调用。

| 子目录 | 文件 | 职责 |
|--------|------|------|
| AI/ | AIServiceProtocol.swift | AI 服务统一接口定义 |
| AI/ | ClaudeService.swift | Claude API 适配器 |
| AI/ | DeepSeekService.swift | DeepSeek API 适配器 |
| AI/ | DoubaoService.swift | 豆包 API 适配器 |
| AI/ | AIManager.swift | AI 调用管理、队列化、费用计数、平台切换 |
| AI/Prompts/ | PromptTemplates.swift | 各分类（找书/找诗/找画/找歌）的 AI 提示词模板 |
| Database/ | Models.swift | SwiftData 数据模型（CollectionFile、ImageRecord、ContentBlock） |
| Database/ | DatabaseManager.swift | 数据库 CRUD 操作、文件合并、回收站管理 |
| Storage/ | PhotoStorageManager.swift | 图片文件读写、缩略图生成、空间计算 |
| Keychain/ | KeychainManager.swift | API Key 安全存取（iOS Keychain） |
| Network/ | NetworkManager.swift | HTTP 请求封装、错误处理 |

---

### Features/（15 文件）
按功能拆分的 UI 模块，每个子目录对应 App 的一个屏幕/功能。

| 子目录 | 文件 | 职责 |
|--------|------|------|
| Collection/ | CollectionView.swift | 首页双列瀑布流 + 分类 tab |
| Collection/ | CategoryFilterBar.swift | 分类筛选 tab 栏（带 Safari 弹性动画） |
| Collection/ | UnsortedBanner.swift | 固定顶部白条——未整理文件入口 |
| Detail/ | FileDetailView.swift | 文件详情页（纯文字 + 编辑 + 左滑触发） |
| Detail/ | ImageGalleryOverlay.swift | 左滑图片浮层（跨分类金色光晕 + tag 跳转） |
| UnsortedFiles/ | UnsortedFilesView.swift | 未整理文件列表 + 选图 + AI 分析按钮 |
| Search/ | SearchView.swift | 全局搜索（搜文件名和文本内容） |
| Settings/ | SettingsView.swift | 设置主页（AI 配置/费用/存储/隐私） |
| Settings/ | AIConfigView.swift | AI 平台选择 + API Key 输入 |
| Settings/ | APIKeyGuideView.swift | API Key 申领指导（各平台图文步骤） |
| Settings/ | BudgetView.swift | AI 费用管理（调用次数/费用估算/月度上限） |
| Settings/ | StorageView.swift | 存储空间用量查看 |
| Settings/ | PrivacyPolicyView.swift | 隐私政策页面 |
| RecycleBin/ | RecycleBinView.swift | 回收站（恢复/清空/30 天自动清理） |
| Onboarding/ | OnboardingView.swift | 首次引导页（3 页分步介绍） |

---

### Shared/（12 文件）
跨模块复用的组件、样式和工具。

| 子目录 | 文件 | 职责 |
|--------|------|------|
| Theme/ | AppTheme.swift | 全局颜色、字号、间距、圆角、阴影、动画参数 |
| Theme/ | ButtonStyles.swift | 分类按钮、主要按钮、次要按钮样式 |
| Theme/ | CardStyles.swift | 浮层卡片、瀑布流卡片样式修饰符 |
| Theme/ | TextStyles.swift | AI 注释、文件标题、正文、时间标注样式 |
| Components/ | TimelineSeparator.swift | 时间隔断组件（类似微信时间气泡） |
| Components/ | FloatingImageCard.swift | 浮层图片卡片（含金色光晕 + 长按触感反馈） |
| Components/ | WaterfallGrid.swift | 双列瀑布流布局组件 |
| Components/ | EmptyStateView.swift | 首页空白引导提示 |
| Extensions/ | DateExtensions.swift | 日期格式化扩展 |
| Models/ | CategoryType.swift | 四大分类枚举定义（找书/找诗/找画/找歌） |
| Models/ | FileStatus.swift | 文件状态枚举（已整理/未整理/已删除） |
| Constants/ | AppConstants.swift | App Group ID、文件名正则、回收站天数等全局常量 |

---

### ShareExtension/（1 文件）
iOS Share Extension，独立 target。

| 文件 | 职责 |
|------|------|
| ShareViewController.swift | 分享面板 UI（四个分类按钮），将图片 + 分类信息写入 App Group 共享空间，不跳转主 App |

---

### Config/（2 文件）
构建和分发配置文档。

| 文件 | 职责 |
|------|------|
| SETUP_GUIDE.md | Xcode 项目创建和配置的完整步骤指南 |
| DISTRIBUTION.md | TestFlight 分发和 App Store 上架指南 |

---

### Resources/
资源文件目录。待添加：
- Assets.xcassets（App 图标、颜色资源）
- Localizable.strings（本地化字符串）

---

## 如何开始

1. 阅读 `Config/SETUP_GUIDE.md`，按步骤在 Xcode 中创建项目
2. 将本文件夹中的源代码拖入 Xcode
3. 配置 App Group 和 Share Extension
4. `Cmd + R` 编译运行
