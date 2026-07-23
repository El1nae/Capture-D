import SwiftUI

/// 时间标记 — Threads 风格左对齐小号浅色文字
struct TimelineSeparator: View {
    let date: Date

    var body: some View {
        Text(date.relativeDisplay(includeTime: true))
            .font(AppTheme.Fonts.sans(AppTheme.FontSize.footnote, weight: .light))
            .tracking(0.4)
            .foregroundStyle(AppTheme.Colors.tertiaryText)
            .padding(.leading, AppTheme.Spacing.md)
            .padding(.top, AppTheme.Spacing.sm)
            .padding(.bottom, 2)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
