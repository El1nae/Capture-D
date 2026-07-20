import SwiftUI

/// API Key 获取指南
struct APIKeyGuideView: View {
    var body: some View {
        List {
            introSection

            guideSection(
                title: "DeepSeek",
                platform: "DeepSeek 开放平台",
                url: "platform.deepseek.com",
                steps: [
                    "打开浏览器，访问 platform.deepseek.com 并注册账号。",
                    "登录后进入左侧「API Keys」页面。",
                    "点击「创建 API Key」，输入一个便于识别的名称。",
                    "复制生成的密钥（仅显示一次，请妥善保存）。",
                    "回到本 App 的「AI 配置」页，粘贴到 DeepSeek 密钥输入框并保存。"
                ]
            )

            guideSection(
                title: "豆包（火山方舟）",
                platform: "火山引擎 - 火山方舟",
                url: "console.volcengine.com/ark",
                steps: [
                    "访问火山引擎控制台 console.volcengine.com/ark 并完成实名注册。",
                    "在「API Key 管理」中创建一个新的 API Key。",
                    "开通所需的视觉大模型服务（如豆包视觉模型）。",
                    "复制 API Key。",
                    "回到本 App 的「AI 配置」页，粘贴到豆包密钥输入框并保存。"
                ]
            )

            guideSection(
                title: "Claude",
                platform: "Anthropic Console",
                url: "console.anthropic.com",
                steps: [
                    "访问 console.anthropic.com 并注册账号（部分地区需要额外验证）。",
                    "进入「API Keys」页面。",
                    "点击「Create Key」创建一个新的密钥。",
                    "复制生成的密钥（以 sk-ant- 开头）。",
                    "回到本 App 的「AI 配置」页，粘贴到 Claude 密钥输入框并保存。"
                ]
            )

            billingSection
        }
        .navigationTitle("获取 API Key")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - 分节

    private var introSection: some View {
        Section {
            Text("本 App 使用你自己的 AI 平台账号进行图片识别。你需要在对应平台注册并创建 API Key，然后填入「AI 配置」页面。费用由各平台按用量向你收取。")
                .font(AppTheme.Fonts.serif(AppTheme.FontSize.body, weight: .light))
                .foregroundStyle(AppTheme.Colors.secondaryText)
                .lineSpacing(6)
                .padding(.vertical, AppTheme.Spacing.xs)
        }
    }

    private func guideSection(title: String, platform: String, url: String, steps: [String]) -> some View {
        Section {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: AppTheme.Spacing.md) {
                    Text("\(index + 1)")
                        .font(AppTheme.Fonts.sans(AppTheme.FontSize.caption, weight: .regular))
                        .foregroundStyle(AppTheme.Colors.accent)
                        .frame(width: 22, height: 22)
                        .overlay(
                            Circle()
                                .stroke(AppTheme.Colors.accent, lineWidth: 0.75)
                        )

                    Text(step)
                        .font(AppTheme.Fonts.serif(AppTheme.FontSize.body, weight: .light))
                        .foregroundStyle(AppTheme.Colors.primaryText)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, AppTheme.Spacing.xs)
            }
        } header: {
            Text(title)
                .font(AppTheme.Fonts.sans(AppTheme.FontSize.footnote, weight: .regular))
                .tracking(1.5)
                .textCase(.uppercase)
        } footer: {
            Text("平台：\(platform)（\(url)）")
                .font(AppTheme.Fonts.sans(AppTheme.FontSize.footnote, weight: .light))
        }
    }

    private var billingSection: some View {
        Section {
            Label {
                Text("请前往对应平台官网查看你的 Token 用量与账单。本 App 内显示的费用仅为按次数的粗略估算，实际扣费以平台为准。")
                    .font(AppTheme.Fonts.sans(AppTheme.FontSize.caption, weight: .light))
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            } icon: {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: AppTheme.FontSize.body, weight: .light))
                    .foregroundStyle(Color.orange.opacity(0.55))
            }
            .padding(.vertical, AppTheme.Spacing.xs)
        } header: {
            Text("关于用量与计费")
                .font(AppTheme.Fonts.sans(AppTheme.FontSize.footnote, weight: .regular))
                .tracking(1.5)
                .textCase(.uppercase)
        }
    }
}
