import SwiftUI

/// 单条碎碎念卡片 — 纯文字 + tags + 时间
struct MurmurCard: View {
    let file: CollectionFile

    private var displayText: String {
        file.contentBlocks
            .sorted { $0.createdAt < $1.createdAt }
            .map(\.text)
            .joined(separator: "\n")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            if !file.tags.isEmpty {
                TagFlowView(tags: file.tags)
            }

            Text(displayText)
                .font(AppTheme.Fonts.serif(AppTheme.FontSize.body, weight: .light))
                .foregroundStyle(AppTheme.Colors.primaryText)
                .lineSpacing(6)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.background)
    }
}
