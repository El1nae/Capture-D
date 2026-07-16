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
}
