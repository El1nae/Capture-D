import Foundation
import SwiftData
import Observation

/// 数据库管理器 — 所有数据的 CRUD 操作
@MainActor
@Observable
final class DatabaseManager {
    let modelContainer: ModelContainer
    let modelContext: ModelContext

    init() {
        // It is acceptable to crash early during development if the persistent container cannot be created.
        // In production, consider handling this error more gracefully.
        let schema = Schema([CollectionFile.self, ImageRecord.self, ContentBlock.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            groupContainer: .identifier(AppConstants.appGroupID)
        )
        modelContainer = try! ModelContainer(for: schema, configurations: [config])
        modelContext = modelContainer.mainContext
    }

    // MARK: - CollectionFile

    /// 创建未整理文件
    func createUnsortedFile(title: String, category: CategoryType, imageRecord: ImageRecord) -> CollectionFile {
        let file = CollectionFile(title: title, category: category, status: .unsorted)
        file.images.append(imageRecord)
        imageRecord.files.append(file)
        modelContext.insert(file)
        try? modelContext.save()
        return file
    }

    /// 获取某分类下的已整理文件（排除未整理和已删除）
    func sortedFiles(for category: CategoryType) -> [CollectionFile] {
        let raw = category.rawValue
        let status = FileStatus.sorted.rawValue
        let predicate = #Predicate<CollectionFile> {
            $0.categoryRawValue == raw && $0.statusRawValue == status
        }
        let descriptor = FetchDescriptor<CollectionFile>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    /// 获取所有已整理文件（首页混合瀑布流）
    func allSortedFiles() -> [CollectionFile] {
        let status = FileStatus.sorted.rawValue
        let predicate = #Predicate<CollectionFile> { $0.statusRawValue == status }
        let descriptor = FetchDescriptor<CollectionFile>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    /// 获取某分类下的未整理文件
    func unsortedFiles(for category: CategoryType) -> [CollectionFile] {
        let raw = category.rawValue
        let status = FileStatus.unsorted.rawValue
        let predicate = #Predicate<CollectionFile> {
            $0.categoryRawValue == raw && $0.statusRawValue == status
        }
        let descriptor = FetchDescriptor<CollectionFile>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    /// 获取某分类下未整理文件数量
    func unsortedCount(for category: CategoryType) -> Int {
        unsortedFiles(for: category).count
    }

    /// 分析完成 — 将文件从未整理提升为已整理
    func promoteFile(_ file: CollectionFile, newTitle: String, content: String) {
        // 检查是否已有同名文件
        if let existing = findFile(byTitle: newTitle, category: file.category) {
            mergeFiles(source: file, into: existing, newContent: content)
        } else {
            file.title = newTitle
            file.status = .sorted
            file.updatedAt = Date()
            let block = ContentBlock(text: content, isAIGenerated: true, file: file)
            modelContext.insert(block)
            file.contentBlocks.append(block)
            try? modelContext.save()
        }
    }

    /// 用户手动改名提升
    func manualPromote(_ file: CollectionFile, newTitle: String) {
        if let existing = findFile(byTitle: newTitle, category: file.category) {
            mergeFiles(source: file, into: existing, newContent: nil)
        } else {
            file.title = newTitle
            file.status = .sorted
            file.updatedAt = Date()
            try? modelContext.save()
        }
    }

    /// 查找同名文件
    func findFile(byTitle title: String, category: CategoryType) -> CollectionFile? {
        let raw = category.rawValue
        let status = FileStatus.sorted.rawValue
        let predicate = #Predicate<CollectionFile> {
            $0.title == title && $0.categoryRawValue == raw && $0.statusRawValue == status
        }
        let descriptor = FetchDescriptor<CollectionFile>(predicate: predicate)
        return try? modelContext.fetch(descriptor).first
    }

    /// 合并两个文件（按时间线粘贴）
    func mergeFiles(source: CollectionFile, into target: CollectionFile, newContent: String?) {
        for image in source.images where !target.images.contains(where: { $0.imageID == image.imageID }) {
            target.images.append(image)
            image.files.append(target)
        }
        if let content = newContent, !content.isEmpty {
            let block = ContentBlock(text: content, isAIGenerated: true, file: target)
            modelContext.insert(block)
            target.contentBlocks.append(block)
        }
        for block in source.contentBlocks {
            block.file = target
            target.contentBlocks.append(block)
        }
        target.updatedAt = Date()
        modelContext.delete(source)
        try? modelContext.save()
    }

    // MARK: - 删除 & 回收站

    /// 软删除文件
    func softDelete(_ file: CollectionFile) {
        file.status = .deleted
        file.deletedAt = Date()
        try? modelContext.save()
    }

    /// 软删除文件中的单张图片
    func removeImage(_ image: ImageRecord, from file: CollectionFile) {
        file.images.removeAll { $0.imageID == image.imageID }
        image.files.removeAll { $0.persistentModelID == file.persistentModelID }
        file.updatedAt = Date()
        // 如果图片不再被任何文件引用，可以考虑清理存储
        try? modelContext.save()
    }

    /// 恢复已删除文件
    func restore(_ file: CollectionFile) {
        file.status = .sorted
        file.deletedAt = nil
        try? modelContext.save()
    }

    /// 获取回收站文件
    func deletedFiles() -> [CollectionFile] {
        let status = FileStatus.deleted.rawValue
        let predicate = #Predicate<CollectionFile> { $0.statusRawValue == status }
        let descriptor = FetchDescriptor<CollectionFile>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.deletedAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    /// 永久删除过期的回收站文件（30 天）
    func cleanExpiredRecycleBin(storage: PhotoStorageManager) {
        let files = deletedFiles()
        for file in files {
            guard let deletedAt = file.deletedAt else { continue }
            if deletedAt.daysFromNow() >= AppConstants.recycleBinRetentionDays {
                permanentlyDelete(file, storage: storage)
            }
        }
    }

    /// 永久删除文件及其独占的图片
    func permanentlyDelete(_ file: CollectionFile, storage: PhotoStorageManager) {
        for image in file.images {
            image.files.removeAll { $0.persistentModelID == file.persistentModelID }
            if image.files.isEmpty {
                storage.deleteImage(id: image.imageID)
                modelContext.delete(image)
            }
        }
        modelContext.delete(file)
        try? modelContext.save()
    }

    // MARK: - 搜索

    /// 全局搜索（搜标题和标签，只搜已整理文件）
    func search(query: String) -> [CollectionFile] {
        let status = FileStatus.sorted.rawValue
        let predicate = #Predicate<CollectionFile> {
            $0.statusRawValue == status && (
                $0.title.localizedStandardContains(query) ||
                $0.tags.contains(where: { $0.localizedStandardContains(query) })
            )
        }
        let descriptor = FetchDescriptor<CollectionFile>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    // MARK: - 标签

    /// 给文件添加标签
    func addTag(_ tag: String, to file: CollectionFile) {
        let trimmed = tag.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !file.tags.contains(trimmed) else { return }
        file.tags.append(trimmed)
        file.updatedAt = Date()
        try? modelContext.save()
    }

    /// 从文件移除标签
    func removeTag(_ tag: String, from file: CollectionFile) {
        file.tags.removeAll { $0 == tag }
        file.updatedAt = Date()
        try? modelContext.save()
    }

    /// 获取所有历史标签（去重，按使用频率排序）
    func allTags() -> [String] {
        let status = FileStatus.sorted.rawValue
        let predicate = #Predicate<CollectionFile> { $0.statusRawValue == status }
        let descriptor = FetchDescriptor<CollectionFile>(predicate: predicate)
        let files = (try? modelContext.fetch(descriptor)) ?? []
        var counts: [String: Int] = [:]
        for file in files {
            for tag in file.tags { counts[tag, default: 0] += 1 }
        }
        return counts.sorted { $0.value > $1.value }.map(\.key)
    }

    // MARK: - 跨分类

    /// 查找同一张图片在其他分类中的文件
    func crossCategoryFiles(for image: ImageRecord, excluding file: CollectionFile) -> [CollectionFile] {
        image.files.filter { $0.persistentModelID != file.persistentModelID }
    }

    // MARK: - 碎碎念

    /// 创建碎碎念（直接为 sorted 状态，跳过 unsorted 流程）
    func createMurmur(text: String, tags: [String] = []) -> CollectionFile {
        let file = CollectionFile(title: Date().unsortedFileName, category: .murmur, status: .sorted)
        file.tags = tags
        let block = ContentBlock(text: text, isAIGenerated: false, file: file)
        modelContext.insert(file)
        modelContext.insert(block)
        file.contentBlocks.append(block)
        try? modelContext.save()
        return file
    }

    /// 获取所有碎碎念（按创建时间倒序）
    func murmurFiles() -> [CollectionFile] {
        let raw = CategoryType.murmur.rawValue
        let status = FileStatus.sorted.rawValue
        let predicate = #Predicate<CollectionFile> {
            $0.categoryRawValue == raw && $0.statusRawValue == status
        }
        let descriptor = FetchDescriptor<CollectionFile>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
}

