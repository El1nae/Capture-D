import Foundation

/// 文件状态
enum FileStatus: String, Codable {
    /// 已整理 — AI 分析完成或用户手动命名
    case sorted
    /// 未整理 — 等待 AI 分析或用户手动处理
    case unsorted
    /// 已删除 — 在回收站中
    case deleted
}
