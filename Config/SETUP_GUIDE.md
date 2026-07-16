# Capture:D Xcode 项目设置指南

## 前置条件

- macOS + Xcode 16+（从 Mac App Store 免费下载）
- Apple ID（免费即可，TestFlight 分发需付费账号）

## 步骤 1：创建 Xcode 项目

1. 打开 Xcode → File → New → Project
2. 选择 **iOS → App**
3. 填写：
   - Product Name: `CaptureD`
   - Team: 选你的 Apple ID
   - Organization Identifier: `com.yourname`（改成你自己的）
   - Interface: **SwiftUI**
   - Storage: **SwiftData**
   - Language: **Swift**
4. 保存位置选择桌面

## 步骤 2：导入源文件

1. 在 Finder 中打开 `SmartCollector/CaptureD/` 文件夹
2. 选中以下文件夹：`App/`, `Features/`, `Core/`, `Shared/`, `Resources/`
3. 拖入 Xcode 项目导航器中（左侧面板）
4. 弹出对话框时选择：
   - ☑ Copy items if needed
   - ☑ Create groups
   - Target: CaptureD
5. **删除** Xcode 自动生成的 `CaptureDApp.swift` 和 `ContentView.swift`（因为我们有自己的版本）

## 步骤 3：配置 App Group

1. 选中项目根节点 → Signing & Capabilities
2. 点 + Capability → 搜索 **App Groups**
3. 添加 Group: `group.com.yourname.captured`
4. 确保与代码中 `AppConstants.appGroupID` 一致

## 步骤 4：添加 Share Extension

1. File → New → Target → **Share Extension**
2. Product Name: `ShareExtension`
3. Activate scheme 选 **Activate**
4. 在 ShareExtension 的 Signing & Capabilities 中也添加同一个 App Group
5. 删除 Xcode 自动生成的 `ShareViewController.swift`
6. 将 `ShareExtension/ShareViewController.swift` 拖入 ShareExtension target
7. 在 ShareExtension 的 Info.plist 中配置：
   ```xml
   <key>NSExtensionActivationRule</key>
   <dict>
       <key>NSExtensionActivationSupportsImageWithMaxCount</key>
       <integer>10</integer>
   </dict>
   ```

## 步骤 5：运行

1. 选择目标设备（iPhone Simulator 或真机）
2. 选择 scheme 为 `CaptureD`
3. 按 `Cmd + R` 运行
4. 测试 Share Extension：
   - 在 Simulator 中打开 Safari 或 Photos
   - 长按图片 → 分享 → 找到 CaptureD → 选分类 → 确认

## 步骤 6：真机测试

1. 用 USB 连接 iPhone
2. 在 Xcode 中选择你的设备
3. 首次运行需要信任开发者：
   - iPhone → 设置 → 通用 → VPN与设备管理 → 信任开发者
4. 免费 Apple ID 的证书 7 天过期，过期后重新运行即可

## 步骤 7：TestFlight 分发（需付费账号）

详见 `Config/DISTRIBUTION.md`
