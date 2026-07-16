import Foundation

enum AppConstants {
    /// App Group ID — 主 App 和 Share Extension 共享数据
    static let appGroupID = "group.com.yourname.captured"

    /// 文件命名格式正则：匹配 `X|Y`（至少各一个字符）
    static let fileNamePattern = "^.+\\|.+$"

    /// 判断文件名是否符合 `X|Y` 格式
    static func isValidFileName(_ name: String) -> Bool {
        name.range(of: fileNamePattern, options: .regularExpression) != nil
    }

    /// 日期/时间格式的文件名正则（未整理文件的默认名）
    static let dateTimePattern = "^\\d{4}-\\d{2}-\\d{2}"

    /// 判断文件名是否为日期格式（未整理状态）
    static func isDateFormatName(_ name: String) -> Bool {
        name.range(of: dateTimePattern, options: .regularExpression) != nil
    }

    /// 分隔符
    static let nameSeparator: Character = "|"

    /// 回收站自动清理天数
    static let recycleBinRetentionDays = 30

    /// 存储空间软提醒阈值（字节）— 1GB
    static let storageWarningThreshold: Int64 = 1_073_741_824

    /// Share Extension 待处理文件夹名
    static let pendingFolderName = "Pending"

    /// 缩略图最大尺寸
    static let thumbnailMaxSize: CGFloat = 300

    /// AI 分析队列并发数
    static let aiQueueConcurrency = 1
}
