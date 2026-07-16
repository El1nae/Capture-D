# Capture:D 分发指南

## TestFlight 分发（推荐）

### 前置条件
- Apple Developer Program 账号（¥688/年）
- 注册：https://developer.apple.com/programs/enroll
- 审核周期：通常 24-48 小时

### 步骤

1. **创建 App ID**
   - 登录 https://developer.apple.com
   - Certificates, Identifiers & Profiles → Identifiers → +
   - App ID → `com.yourname.captured`
   - 勾选 App Groups

2. **创建 Provisioning Profile**
   - Profiles → + → iOS App Development
   - 选择 App ID → 选择设备 → 下载并安装

3. **Archive & Upload**
   - Xcode → Product → Archive
   - Archive 完成后 → Distribute App → App Store Connect
   - 上传到 App Store Connect

4. **TestFlight 配置**
   - 登录 https://appstoreconnect.apple.com
   - My Apps → CaptureD → TestFlight
   - 内部测试 → 添加测试员（最多 100 人，不需审核）
   - 外部测试 → 添加测试员（最多 10000 人，需要简单审核）

5. **邀请测试**
   - 测试员会收到邮件邀请
   - 安装 TestFlight app → 接受邀请 → 下载 CaptureD

### 注意事项
- 每个 Build 有 90 天有效期
- 需要准备隐私政策 URL（app 内已包含内容，可部署为网页）
- TestFlight 审核通常 24-48 小时

## 未来 App Store 上架

上架需要额外准备：
- App 图标（1024x1024）
- 截屏（各设备尺寸）
- App 描述（中英文）
- 隐私政策 URL
- 通过 Apple 审核（通常 1-3 天）
