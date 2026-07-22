import SwiftUI

/// 时间标记 — Threads 风格左对齐小号浅色文字
struct TimelineSeparator: View {
    let date: Date

    var body: some View {
        Text(date.timelineDisplay)
            .font(AppTheme.Fonts.sans(AppTheme.FontSize.footnote, weight: .light))
            .tracking(0.4)
            .foregroundStyle(AppTheme.Colors.tertiaryText)
            .padding(.leading, AppTheme.Spacing.md)
            .padding(.top, AppTheme.Spacing.sm)
            .padding(.bottom, 2)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private extension Date {
    var timelineDisplay: String {
        let calendar = Calendar.current
        let now = Date()

        let minutesDiff = Int(now.timeIntervalSince(self) / 60)
        if minutesDiff < 1 { return "刚刚" }
        if minutesDiff < 60 { return "\(minutesDiff)分钟前" }

        let hoursDiff = minutesDiff / 60
        if hoursDiff < 24 && calendar.isDateInToday(self) {
            return "\(hoursDiff)小时前"
        }

        if calendar.isDateInYesterday(self) {
            return "昨天 \(self.formatted(date: .omitted, time: .shortened))"
        }

        if calendar.isDate(self, equalTo: now, toGranularity: .year) {
            let formatter = DateFormatter()
            formatter.dateFormat = "M月d日 HH:mm"
            return formatter.string(from: self)
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日 HH:mm"
        return formatter.string(from: self)
    }
}
