import SwiftUI

/// GitHub 风格日期活跃热力图
struct HeatmapView: View {
    let dailyCounts: [Date: Int]
    private let weeks = 13
    private let cellSize: CGFloat = 12
    private let cellSpacing: CGFloat = 3

    private var maxCount: Int {
        dailyCounts.values.max() ?? 1
    }

    private var calendar: Calendar { Calendar.current }

    private func color(for count: Int) -> Color {
        guard count > 0 else {
            return AppTheme.Colors.accent.opacity(0.06)
        }
        let ratio = Double(count) / Double(max(maxCount, 1))
        if ratio <= 0.25 { return AppTheme.Colors.accent.opacity(0.15) }
        if ratio <= 0.5 { return AppTheme.Colors.accent.opacity(0.30) }
        if ratio <= 0.75 { return AppTheme.Colors.accent.opacity(0.60) }
        return AppTheme.Colors.accent
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("活跃记录")
                .font(AppTheme.Fonts.serif(AppTheme.FontSize.headline, weight: .regular))
                .foregroundStyle(AppTheme.Colors.primaryText)
                .tracking(0.5)

            HStack(alignment: .top, spacing: cellSpacing) {
                ForEach(0..<weeks, id: \.self) { weekOffset in
                    VStack(spacing: cellSpacing) {
                        ForEach(0..<7, id: \.self) { dayOfWeek in
                            let date = dateFor(week: weekOffset, day: dayOfWeek)
                            let count = date.flatMap { dailyCounts[calendar.startOfDay(for: $0)] } ?? 0
                            RoundedRectangle(cornerRadius: 2)
                                .fill(date != nil ? color(for: count) : .clear)
                                .frame(width: cellSize, height: cellSize)
                        }
                    }
                }
            }

            HStack(spacing: AppTheme.Spacing.sm) {
                Text("少")
                    .font(AppTheme.Fonts.sans(AppTheme.FontSize.footnote, weight: .light))
                    .foregroundStyle(AppTheme.Colors.tertiaryText)
                ForEach([0.06, 0.15, 0.30, 0.60, 1.0], id: \.self) { opacity in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(AppTheme.Colors.accent.opacity(opacity))
                        .frame(width: cellSize, height: cellSize)
                }
                Text("多")
                    .font(AppTheme.Fonts.sans(AppTheme.FontSize.footnote, weight: .light))
                    .foregroundStyle(AppTheme.Colors.tertiaryText)
            }
        }
    }

    private func dateFor(week: Int, day: Int) -> Date? {
        let today = Date()
        let todayWeekday = calendar.component(.weekday, from: today)
        let daysBack = (weeks - 1 - week) * 7 + (todayWeekday - 1 - day)
        guard daysBack >= 0 else { return nil }
        return calendar.date(byAdding: .day, value: -daysBack, to: today)
    }
}
