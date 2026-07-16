import SwiftUI

/// 设置主页 — AI 配置、预算、存储、隐私
struct SettingsView: View {
    @Environment(AIManager.self) private var ai
    @Environment(PhotoStorageManager.self) private var storage

    var body: some View {
        NavigationStack {
            List {
                // MARK: - AI 配置
                Section {
                    NavigationLink {
                        AIConfigView()
                    } label: {
                        SettingsRow(
                            icon: "sparkles",
                            title: "AI 配置",
                            subtitle: ai.currentService.displayName
                        )
                    }
                } header: {
                    Text("智能识别")
                }

                // MARK: - 预算管理
                Section {
                    NavigationLink {
                        BudgetView()
                    } label: {
                        SettingsRow(
                            icon: "yensign.circle",
                            title: "AI 预算管理",
                            subtitle: budgetSubtitle
                        )
                    }
                } header: {
                    Text("费用")
                } footer: {
                    Text("本月已分析 \(ai.monthlyAnalysisCount) 次，预估 \(ai.estimatedCost)")
                        .font(.system(size: AppTheme.FontSize.footnote))
                }

                // MARK: - 存储管理
                Section {
                    NavigationLink {
                        StorageView()
                    } label: {
                        SettingsRow(
                            icon: "internaldrive",
                            title: "存储空间",
                            subtitle: storage.formattedStorageUsed()
                        )
                    }
                    NavigationLink {
                        RecycleBinView()
                            .navigationTitle("回收站")
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        SettingsRow(
                            icon: "trash",
                            title: "回收站",
                            subtitle: "已删除文件保留 \(AppConstants.recycleBinRetentionDays) 天"
                        )
                    }
                } header: {
                    Text("存储")
                }

                // MARK: - 隐私
                Section {
                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        SettingsRow(
                            icon: "hand.raised",
                            title: "隐私政策",
                            subtitle: nil
                        )
                    }
                } header: {
                    Text("关于")
                }
            }
            .navigationTitle("设置")
        }
    }

    private var budgetSubtitle: String {
        ai.monthlyLimit == 0 ? "不限次数" : "上限 \(ai.monthlyLimit) 次/月"
    }
}

/// 设置行 — 图标 + 标题 + 副标题
private struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String?

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: AppTheme.FontSize.headline))
                .foregroundStyle(AppTheme.Colors.accent)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(title)
                    .font(.system(size: AppTheme.FontSize.body, weight: .medium))
                    .foregroundStyle(AppTheme.Colors.primaryText)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: AppTheme.FontSize.caption))
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                }
            }
        }
        .padding(.vertical, AppTheme.Spacing.xs)
    }
}
