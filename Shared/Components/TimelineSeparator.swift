import SwiftUI

/// 时间隔断组件 — 类似微信聊天的时间气泡
struct TimelineSeparator: View {
    let date: Date

    var body: some View {
        HStack {
            Spacer()
            Text(date.formatted(date: .long, time: .omitted))
                .font(AppTheme.Fonts.sans(AppTheme.FontSize.footnote, weight: .light))
                .tracking(0.8)
                .foregroundStyle(AppTheme.Colors.tertiaryText)
                .padding(.horizontal, AppTheme.Spacing.sm)
                .padding(.vertical, AppTheme.Spacing.xs)
                .background(AppTheme.Colors.cardBackground)
                .clipShape(Capsule())
            Spacer()
        }
        .padding(.vertical, AppTheme.Spacing.md)
    }
}
