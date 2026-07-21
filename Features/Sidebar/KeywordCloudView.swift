import SwiftUI

/// 关键词云图
struct KeywordCloudView: View {
    let keywords: [(word: String, count: Int)]

    private var maxCount: Int {
        keywords.first?.count ?? 1
    }

    private func fontSize(for count: Int) -> CGFloat {
        let ratio = Double(count) / Double(max(maxCount, 1))
        return AppTheme.FontSize.footnote + ratio * (AppTheme.FontSize.title - AppTheme.FontSize.footnote)
    }

    private func opacity(for count: Int) -> Double {
        let ratio = Double(count) / Double(max(maxCount, 1))
        return 0.4 + ratio * 0.6
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("关键词")
                .font(AppTheme.Fonts.serif(AppTheme.FontSize.headline, weight: .regular))
                .foregroundStyle(AppTheme.Colors.primaryText)
                .tracking(0.5)

            if keywords.isEmpty {
                Text("内容不足，暂无关键词")
                    .font(AppTheme.Fonts.sans(AppTheme.FontSize.caption, weight: .light))
                    .foregroundStyle(AppTheme.Colors.tertiaryText)
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(keywords, id: \.word) { kw in
                        Text(kw.word)
                            .font(AppTheme.Fonts.serif(fontSize(for: kw.count), weight: .light))
                            .foregroundStyle(AppTheme.Colors.accent.opacity(opacity(for: kw.count)))
                    }
                }
            }
        }
    }
}
