import Foundation

extension Date {
    /// 生成未整理文件的默认文件名（存入时间）
    var unsortedFileName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: self)
    }

    /// 时间隔断显示用（年月日）
    var timelineDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: self)
    }

    /// 图片时间标注（年月日）
    var imageTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: self)
    }

    /// 距今天数
    func daysFromNow() -> Int {
        Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
    }

    /// 瀑布流卡片用的简短时间显示
    var timelineBrief: String {
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
            return "昨天"
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        if calendar.isDate(self, equalTo: now, toGranularity: .year) {
            formatter.dateFormat = "M月d日"
        } else {
            formatter.dateFormat = "yyyy年M月d日"
        }
        return formatter.string(from: self)
    }
}
