# Capture:D 开发日志

> 按时间倒序记录每次开发内容。最新的在最上面。

---

## 2026-07-22 — 九项功能优化与重构

### 开发内容

#### P1：图片画廊样式优化
- `FloatingImageCard.swift`：去掉白色边框和 padding，图片 `scaledToFit` 撑满。日期改为左下角悬浮白字（带阴影），无底色
- `ImageGalleryOverlay.swift`：去掉 `.floatingCardStyle()` 和 `.padding(.horizontal, lg)`，TabView 用 `.frame(maxHeight: .infinity)` 撑满

#### P2：旧消息可编辑 + 新消息可追加
- `FileDetailView.swift`：整文件重写。每条 ContentBlock 右侧增加铅笔按钮可编辑，最底部右对齐"+ 追加"胶囊按钮。删除了旧的 `saveEdits` 方法（该方法有 bug：只追加不删旧，导致数据重复）
- `DatabaseManager.swift`：新增 `updateContentBlock()` 和 `appendContentBlock()` 方法
- `Models.swift`：ContentBlock 增加 `Identifiable` 协议（用于 `sheet(item:)`）

#### P3：FAB 位置抬高
- `ContentView.swift`：FAB bottom padding 从 30 改为 80，避免与底部操作栏重叠

#### P4：弹窗高度统一 45%
- `ComposeSheet.swift`：`.presentationDetents` 从 `.fraction(0.75)` 改为 `.fraction(0.45)`

#### P5：Threads 风格时间线排版
- `TimelineSeparator.swift`：整文件重写。去掉居中气泡底色，改为左对齐相对时间（"刚刚/X分钟前/X小时前/昨天/M月d日 HH:mm"）
- `MurmurCard.swift`：减小间距 `spacing: 4`，减小行距 `lineSpacing: 4`，去掉 `.background`
- `MurmurTimelineView.swift`：Divider 加 `.padding(.leading, md)` 左缩进

#### P6+P7：统一图片发布流程
- `ComposeSheet.swift`：整文件重写。新增 `PhotosPicker` 图片选择器、分类选择按钮（必选1+）、命名框（可选）、标签框（可选）。新增 `ComposeResult` 结构体和 `ComposeMode` 枚举。保留向后兼容的纯文字初始化器
- `ContentView.swift`：FAB 发布逻辑改为 `handlePublish()`——纯文字→碎碎念，带图→按分类入库
- `ShareViewController.swift`：整文件重写。增加命名框和标签框（UIKit），`PendingImageDTO` 新增 `name`/`tags` 字段
- `Models.swift`：`PendingImage` 新增 `name: String` 和 `tags: [String]` 字段
- `DatabaseManager.swift`：新增 `createImageRecord()` 和 `insertFileWithBlock()` 方法
- `CaptureDApp.swift`：`processPendingImages()` 更新——读取 name/tags，格式正确则 `.sorted`

#### P8：点击 CaptureD 标题回主界面
- `CollectionView.swift`：toolbar principal 从 `Text` 改为 `Button`，点击设 `selectedCategory = nil`

#### P9：搜索改为主页面内筛选
- `CollectionView.swift`：整文件重写。新增 `searchQuery`/`isSearching` 状态，搜索栏嵌入页面顶部。搜索+分类组合过滤。搜索图标改为切换搜索栏显隐。点击标题同时清空搜索
- `DatabaseManager.swift`：新增 `search(query:, category:)` 组合查询方法
- **删除** `Features/Search/SearchView.swift` 及其 pbxproj 引用

### 决策原因
- 编辑模式：旧的"全量拼接→重新追加"逻辑导致数据重复，改为逐条编辑+独立追加
- 搜索内嵌：独立搜索页面割裂了筛选体验，用户无法同时搜索+按分类过滤
- 统一发布：截屏/分享/碎碎念三个入口的发布流程不一致，统一为带分类+tag+命名的表单
- ShareExtension 加 tag/命名：手动输入（无自动补全），因为 Extension 无法访问 SwiftData

### 遇到的问题
- `ContentBlock` 需要 `Identifiable` 才能用于 `sheet(item:)`，SwiftData `@Model` 默认不带
- ComposeSheet 需要两种回调签名（`(String)` 和 `(ComposeResult)`），通过 extension 提供向后兼容初始化器解决
- `PendingImage` 和 `PendingImageDTO` 两个结构体需要同步新增字段

### 下一步
- 在 Xcode 中编译验证所有改动
- 测试完整的发布流程（纯文字/带图/Share Extension）
- 测试搜索+分类组合过滤
- 测试编辑和追加功能

---

## 2026-07-16 — 项目初始化

### 开发内容
- 创建项目规范文件 PROJECT_RULES.md
- 创建架构文档 ARCHITECTURE.md
- 创建开发日志 DEVELOPMENT_LOG.md（本文件）
- 创建初始 ADR（000-005）
- 完成产品需求规格书 PROJECT_SPEC.md（经过 16 轮需求讨论）
- 完成对话存档 CONVERSATION_LOG.md

### 决策原因
- 通过 16 轮需求讨论，确定了完整的产品定位、技术栈、交互设计和异常处理
- 建立规范文件体系，确保未来开发有据可依
- 先规范后开发，避免后期返工

### 遇到的问题
- 最初设想的"截屏自动弹窗"在 iOS 上不可行（Apple 安全限制）→ 改为 Share Extension
- "待分析"和"未知来源"职责模糊 → 合并为"未整理"
- AI 自动运行会导致费用不可控 → 改为完全手动触发
- App 名 `Capture:D` 的冒号在文件系统不合法 → 项目目录用 `CaptureD`，桌面显示用 `Capture:D`

### 下一步
- 等待开发者确认规范文件
- 进行架构评审
- 确认模块开发顺序后开始第一个模块（Core/Database）
