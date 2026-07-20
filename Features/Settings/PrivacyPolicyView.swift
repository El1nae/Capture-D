import SwiftUI

/// App 内隐私政策
struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                Text("隐私政策")
                    .font(AppTheme.Fonts.serif(AppTheme.FontSize.largeTitle, weight: .light))
                    .tracking(1)
                    .foregroundStyle(AppTheme.Colors.primaryText)

                Text("最近更新：2026 年 7 月")
                    .font(AppTheme.Fonts.sans(AppTheme.FontSize.caption, weight: .light))
                    .foregroundStyle(AppTheme.Colors.tertiaryText)

                Text("我们非常重视你的隐私。本页说明 Capture:D 如何处理你的数据。")
                    .font(AppTheme.Fonts.serif(AppTheme.FontSize.body, weight: .light))
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                    .lineSpacing(6)

                section(
                    title: "不访问相册",
                    body: "Capture:D 不会读取、扫描或访问你的系统相册。App 中的图片仅来自你主动通过系统「分享」功能发送进来的内容，我们不会在后台获取任何你未主动提供的照片。"
                )

                section(
                    title: "图片会发送至第三方 AI 服务",
                    body: "当你使用智能识别功能时，你所选择分析的图片会被发送到你所配置的第三方 AI 平台（如 DeepSeek、豆包、Claude）进行处理。这些图片的处理受对应平台的隐私政策与条款约束，我们建议你在使用前阅读相关平台的政策。若你不使用 AI 分析功能，图片不会离开你的设备。"
                )

                section(
                    title: "数据存储在本地",
                    body: "你的图片、文件和分类信息均保存在本设备的 App 沙盒中，不会上传到我们的服务器（我们也没有服务器收集这些内容）。删除 App 即会清除这些本地数据。"
                )

                section(
                    title: "API Key 安全存储",
                    body: "你填写的各 AI 平台 API Key 会通过系统 Keychain（钥匙串）加密存储在本设备上，不会被上传或与我们共享。你可以随时在「AI 配置」中清除它们。"
                )

                section(
                    title: "联系我们",
                    body: "如你对本隐私政策有任何疑问，欢迎通过 App Store 页面提供的方式与我们联系。"
                )
            }
            .padding(AppTheme.Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(AppTheme.Colors.background)
        .navigationTitle("隐私政策")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func section(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(title)
                .font(AppTheme.Fonts.serif(AppTheme.FontSize.headline, weight: .regular))
                .foregroundStyle(AppTheme.Colors.primaryText)
            Text(body)
                .font(AppTheme.Fonts.serif(AppTheme.FontSize.body, weight: .light))
                .foregroundStyle(AppTheme.Colors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(6)
        }
    }
}
