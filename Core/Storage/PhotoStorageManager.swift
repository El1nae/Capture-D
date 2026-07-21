import Foundation
import UIKit
import Observation

/// 图片存储管理器 — 负责图片文件的读写、缩略图生成和空间计算
@Observable
final class PhotoStorageManager {
    private let fileManager = FileManager.default

    /// App 内独立的图片存储目录
    private var storageURL: URL {
        let url = fileManager.containerURL(forSecurityApplicationGroupIdentifier: AppConstants.appGroupID)!
            .appendingPathComponent("Images", isDirectory: true)
        if !fileManager.fileExists(atPath: url.path) {
            try? fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        }
        return url
    }

    /// 缩略图存储目录
    private var thumbnailURL: URL {
        let url = storageURL.appendingPathComponent("Thumbnails", isDirectory: true)
        if !fileManager.fileExists(atPath: url.path) {
            try? fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        }
        return url
    }

    /// Share Extension 写入的待处理目录
    var pendingURL: URL {
        let url = fileManager.containerURL(forSecurityApplicationGroupIdentifier: AppConstants.appGroupID)!
            .appendingPathComponent(AppConstants.pendingFolderName, isDirectory: true)
        if !fileManager.fileExists(atPath: url.path) {
            try? fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        }
        return url
    }
    
    init() {}

    // MARK: - 存取

    /// 保存图片，返回生成的 imageID
    func saveImage(_ data: Data) -> String {
        let imageID = UUID().uuidString + ".jpg"
        let fileURL = storageURL.appendingPathComponent(imageID)
        try? data.write(to: fileURL)
        generateThumbnail(for: imageID, from: data)
        return imageID
    }

    /// 读取原图数据
    func loadImage(id: String) -> Data? {
        let fileURL = storageURL.appendingPathComponent(id)
        return try? Data(contentsOf: fileURL)
    }

    /// 读取缩略图数据
    func loadThumbnail(id: String) -> Data? {
        let fileURL = thumbnailURL.appendingPathComponent(id)
        return try? Data(contentsOf: fileURL)
    }

    /// 删除图片及其缩略图
    func deleteImage(id: String) {
        let imageURL = storageURL.appendingPathComponent(id)
        let thumbURL = thumbnailURL.appendingPathComponent(id)
        try? fileManager.removeItem(at: imageURL)
        try? fileManager.removeItem(at: thumbURL)
    }

    // MARK: - 缩略图

    private func generateThumbnail(for imageID: String, from data: Data) {
        guard let image = UIImage(data: data) else { return }
        let maxSize = AppConstants.thumbnailMaxSize
        let scale = min(maxSize / image.size.width, maxSize / image.size.height, 1.0)
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        let thumbnailData = renderer.jpegData(withCompressionQuality: 0.7) { context in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }

        let thumbURL = thumbnailURL.appendingPathComponent(imageID)
        try? thumbnailData.write(to: thumbURL)
    }

    // MARK: - 空间计算

    /// 计算所有图片占用的总空间（字节）
    func totalStorageUsed() -> Int64 {
        calculateDirectorySize(url: storageURL)
    }

    /// 格式化存储空间显示
    func formattedStorageUsed() -> String {
        let bytes = totalStorageUsed()
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }

    /// 是否超过存储警告阈值
    var isStorageWarning: Bool {
        totalStorageUsed() >= AppConstants.storageWarningThreshold
    }

    private func calculateDirectorySize(url: URL) -> Int64 {
        guard let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }
        var totalSize: Int64 = 0
        for case let fileURL as URL in enumerator {
            let size = (try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
            totalSize += Int64(size)
        }
        return totalSize
    }

    // MARK: - Pending 处理

    /// 读取 Share Extension 写入的待处理数据
    func loadPendingImages() -> [PendingImage] {
        let metadataURL = pendingURL.appendingPathComponent("metadata.json")
        guard let data = try? Data(contentsOf: metadataURL),
              let items = try? JSONDecoder().decode([PendingImage].self, from: data) else {
            return []
        }
        return items
    }

    /// 清除已处理的待处理数据
    func clearPending() {
        let metadataURL = pendingURL.appendingPathComponent("metadata.json")
        try? fileManager.removeItem(at: metadataURL)
    }

    /// 读取待处理图片文件
    func loadPendingImageData(fileName: String) -> Data? {
        let fileURL = pendingURL.appendingPathComponent(fileName)
        return try? Data(contentsOf: fileURL)
    }

    /// 删除待处理图片文件
    func removePendingImageFile(fileName: String) {
        let fileURL = pendingURL.appendingPathComponent(fileName)
        try? fileManager.removeItem(at: fileURL)
    }
}
