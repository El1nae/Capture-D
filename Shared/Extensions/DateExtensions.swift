import Foundation

private enum DateFormatters {
    static let unsorted: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm"
        f.locale = Locale(identifier: "zh_CN")
        return f
    }()

    static let yearMonthDay: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy年M月d日"
        f.locale = Locale(identifier: "zh_CN")
        return f
    }()

    static let imageStamp: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy.MM.dd"
        f.locale = Locale(identifier: "zh_CN")
        return f
    }()

    static let monthDayTime: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "M月d日 HH:mm"
        f.locale = Locale(identifier: "zh_CN")
        return f
    }()

    static let monthDay: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "M月d日"
        f.locale = Locale(identifier: "zh_CN")
        return f
    }()

    static let fullDateTime: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy年M月d日 HH:mm"
        f.locale = Locale(identifier: "zh_CN")
        return f
    }()

    static let fullDate: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy年M月d日"
        f.locale = Locale(identifier: "zh_CN")
        return f
    }()
}

extension Date {
    var unsortedFileName: String {
        DateFormatters.unsorted.string(from: self)
    }

    var timelineDateString: String {
        DateFormatters.yearMonthDay.string(from: self)
    }

    var imageTimestamp: String {
        DateFormatters.imageStamp.string(from: self)
    }

    func daysFromNow() -> Int {
        Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
    }

    /// 相对时间显示。includeTime=true 在"昨天"及更早时附带具体时间
    func relativeDisplay(includeTime: Bool = false) -> String {
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
            if includeTime {
                return "昨天 \(self.formatted(date: .omitted, time: .shortened))"
            }
            return "昨天"
        }
        if calendar.isDate(self, equalTo: now, toGranularity: .year) {
            return includeTime
                ? DateFormatters.monthDayTime.string(from: self)
                : DateFormatters.monthDay.string(from: self)
        }
        return includeTime
            ? DateFormatters.fullDateTime.string(from: self)
            : DateFormatters.fullDate.string(from: self)
    }

    /// 瀑布流卡片用的简短时间（不含具体时间）
    var timelineBrief: String {
        relativeDisplay(includeTime: false)
    }
}
