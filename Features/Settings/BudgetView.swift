import SwiftUI

/// AI 使用预算管理
struct BudgetView: View {
    @Environment(AIManager.self) private var ai

    /// 可选的月度上限档位（0 = 不限）
    private let limitOptions = [0, 50, 100, 200, 500]

    var body: some View {
        @Bindable var ai = ai

        List {
            // MARK: - 本月概览
            Section {
                statRow(
                    icon: "chart.bar",
                    title: "本月分析次数",
                    value: "\(ai.monthlyAnalysisCount) 次"
                )
                statRow(
                    icon: "yensign.circle",
                    title: "预估费用",
                    value: ai.estimatedCost
                )
                statRow(
                    icon: "sparkles",
                    title: "当前平台",
                    value: ai.currentService.displayName
                )
            } header: {
                Text("本月使用情况")
                    .font(AppTheme.Fonts.sans(AppTheme.FontSize.footnote, weight: .regular))
                    .tracking(1.5)
                    .textCase(.uppercase)
            }

            // MARK: - 月度上限
            Section {
                Picker("月度分析上限", selection: $ai.monthlyLimit) {
                    ForEach(limitOptions, id: \.self) { option in
                        Text(label(for: option)).tag(option)
                    }
                }
                .pickerStyle(.menu)
                .font(AppTheme.Fonts.serif(AppTheme.FontSize.body, weight: .regular))
                .tint(AppTheme.Colors.accent)

                if ai.isBudgetExceeded {
                    Label("本月已达上限，AI 已暂停分析", systemImage: "pause.circle.fill")
                        .font(AppTheme.Fonts.sans(AppTheme.FontSize.caption, weight: .light))
                        .foregroundStyle(AppTheme.Colors.destructive)
                }
            } header: {
                Text("预算设置")
                    .font(AppTheme.Fonts.sans(AppTheme.FontSize.footnote, weight: .regular))
                    .tracking(1.5)
                    .textCase(.uppercase)
            } footer: {
                Text("设置每月最多分析次数。达到上限后，AI 将自动停止工作，直到下个月自动重置；选择「不限制」则不做限制。")
                    .font(AppTheme.Fonts.sans(AppTheme.FontSize.footnote, weight: .light))
            }

            // MARK: - 计费提醒
            Section {
                Label {
                    Text("以上费用为按调用次数的粗略估算，仅供参考。请前往对应 AI 平台官网查看实际的 Token 用量与账单。")
                        .font(AppTheme.Fonts.sans(AppTheme.FontSize.caption, weight: .light))
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                } icon: {
                    Image(systemName: "info.circle")
                        .font(.system(size: AppTheme.FontSize.body, weight: .light))
                        .foregroundStyle(AppTheme.Colors.accent.opacity(0.5))
                }
                .padding(.vertical, AppTheme.Spacing.xs)
            } header: {
                Text("计费说明")
                    .font(AppTheme.Fonts.sans(AppTheme.FontSize.footnote, weight: .regular))
                    .tracking(1.5)
                    .textCase(.uppercase)
            }
        }
        .navigationTitle("预算管理")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - 辅助

    private func label(for option: Int) -> String {
        option == 0 ? "不限制" : "\(option) 次/月"
    }

    private func statRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: AppTheme.FontSize.headline, weight: .light))
                .foregroundStyle(AppTheme.Colors.accent.opacity(0.5))
                .frame(width: 28)
            Text(title)
                .font(AppTheme.Fonts.serif(AppTheme.FontSize.body, weight: .light))
                .foregroundStyle(AppTheme.Colors.primaryText)
            Spacer()
            Text(value)
                .font(AppTheme.Fonts.sans(AppTheme.FontSize.body, weight: .regular))
                .foregroundStyle(AppTheme.Colors.secondaryText)
        }
    }
}
