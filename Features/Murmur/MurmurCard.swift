import SwiftUI

/// 单条碎碎念卡片 — Threads 风格紧凑布局
struct MurmurCard: View {
    let file: CollectionFile

    private var displayText: String {
        file.contentBlocks
            .sorted { $0.createdAt < $1.createdAt }
            .map(\.text)
            .joined(separator: "\n")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if !file.tags.isEmpty {
                TagFlowView(tags: file.tags)
            }

            Text(displayText)
                .font(AppTheme.Fonts.serif(AppTheme.FontSize.body, weight: .light))
                .foregroundStyle(AppTheme.Colors.primaryText)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.sm)
    }
}
