import Foundation
import SwiftData

/// 图片记录 — 实际图片文件的引用（一图多分类共享同一个 ImageRecord）
@Model
final class ImageRecord {
    /// 图片在 Storage 中的唯一文件名
    var imageID: String
    /// 存入 app 的时间
    var capturedAt: Date
    /// 缩略图数据（懒加载用）
    @Attribute(.externalStorage) var thumbnailData: Data?
    /// 关联的收藏文件（反向关系，一图多文件）
    var files: [CollectionFile]

    init(imageID: String, capturedAt: Date, thumbnailData: Data? = nil) {
        self.imageID = imageID
        self.capturedAt = capturedAt
        self.thumbnailData = thumbnailData
        self.files = []
    }
}

/// 收藏文件 — 一个出处对应一个文件，包含 AI 分析内容和图片引用
@Model
final class CollectionFile {
    /// 文件标题（如 "静夜思|李白"，未整理时为时间戳）
    var title: String
    /// 所属分类
    var categoryRawValue: String
    /// 文件状态
    var statusRawValue: String
    /// 用户自定义标签
    var tags: [String]
    /// 创建时间
    var createdAt: Date
    /// 最后更新时间
    var updatedAt: Date
    /// 删除时间（回收站用）
    var deletedAt: Date?
    /// 关联的图片
    var images: [ImageRecord]
    /// 内容块（时间线式追加）
    @Relationship(deleteRule: .cascade) var contentBlocks: [ContentBlock]

    var category: CategoryType {
        get { CategoryType(rawValue: categoryRawValue) ?? .literature }
        set { categoryRawValue = newValue.rawValue }
    }

    var status: FileStatus {
        get { FileStatus(rawValue: statusRawValue) ?? .unsorted }
        set { statusRawValue = newValue.rawValue }
    }

    init(title: String, category: CategoryType, status: FileStatus = .unsorted) {
        self.title = title
        self.categoryRawValue = category.rawValue
        self.statusRawValue = status.rawValue
        self.tags = []
        self.createdAt = Date()
        self.updatedAt = Date()
        self.images = []
        self.contentBlocks = []
    }
}

/// 内容块 — 文件内的一段内容（AI 生成或用户编辑），按时间线排列
@Model
final class ContentBlock: Identifiable {
    /// 文本内容
    var text: String
    /// 是否为 AI 生成
    var isAIGenerated: Bool
    /// 创建时间（用于时间隔断显示）
    var createdAt: Date
    /// 所属文件
    var file: CollectionFile?

    init(text: String, isAIGenerated: Bool, file: CollectionFile? = nil) {
        self.text = text
        self.isAIGenerated = isAIGenerated
        self.createdAt = Date()
        self.file = file
    }
}

/// Share Extension 写入 App Group 时使用的临时数据结构
struct PendingImage: Codable {
    let imageFileName: String
    let categories: [String]
    let savedAt: Date
    let name: String
    let tags: [String]
}
