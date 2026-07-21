import Foundation
import SwiftData

/// 每日活跃度统计
enum ActivityTracker {
    /// 统计每天新增文件数量（最近 N 天）
    static func dailyCounts(database: DatabaseManager, days: Int = 90) -> [Date: Int] {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -days, to: Date())!
        let allFiles = database.allSortedFiles() + database.murmurFiles()

        var counts: [Date: Int] = [:]
        for file in allFiles {
            guard file.createdAt >= startDate else { continue }
            let day = calendar.startOfDay(for: file.createdAt)
            counts[day, default: 0] += 1
        }
        return counts
    }
}
