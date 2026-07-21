import Foundation
import UIKit

/// 导出管理器 — 将所有数据打包为 ZIP
@MainActor
final class ExportManager {
    let database: DatabaseManager
    let storage: PhotoStorageManager

    init(database: DatabaseManager, storage: PhotoStorageManager) {
        self.database = database
        self.storage = storage
    }

    /// 生成导出 ZIP 文件并返回路径
    func exportAll() throws -> URL {
        let fm = FileManager.default
        let tempDir = fm.temporaryDirectory.appendingPathComponent("CaptureD_Export_\(UUID().uuidString)")
        let imagesDir = tempDir.appendingPathComponent("images")
        try fm.createDirectory(at: imagesDir, withIntermediateDirectories: true)

        let allFiles = database.allSortedFiles() + database.murmurFiles() + database.deletedFiles()

        var fileExports: [[String: Any]] = []
        var imageIDs: Set<String> = []

        for file in allFiles {
            var fileDict: [String: Any] = [
                "title": file.title,
                "category": file.categoryRawValue,
                "status": file.statusRawValue,
                "tags": file.tags,
                "createdAt": ISO8601DateFormatter().string(from: file.createdAt),
                "updatedAt": ISO8601DateFormatter().string(from: file.updatedAt)
            ]
            if let deletedAt = file.deletedAt {
                fileDict["deletedAt"] = ISO8601DateFormatter().string(from: deletedAt)
            }

            var blocks: [[String: Any]] = []
            for block in file.contentBlocks.sorted(by: { $0.createdAt < $1.createdAt }) {
                blocks.append([
                    "text": block.text,
                    "isAIGenerated": block.isAIGenerated,
                    "createdAt": ISO8601DateFormatter().string(from: block.createdAt)
                ])
            }
            fileDict["contentBlocks"] = blocks

            var imageRefs: [String] = []
            for image in file.images {
                imageRefs.append(image.imageID)
                if !imageIDs.contains(image.imageID) {
                    imageIDs.insert(image.imageID)
                    if let data = storage.loadImage(id: image.imageID) {
                        let imageFile = imagesDir.appendingPathComponent(image.imageID)
                        try data.write(to: imageFile)
                    }
                }
            }
            fileDict["imageIDs"] = imageRefs
            fileExports.append(fileDict)
        }

        let exportData: [String: Any] = [
            "version": 1,
            "exportDate": ISO8601DateFormatter().string(from: Date()),
            "files": fileExports
        ]
        let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: [.prettyPrinted, .sortedKeys])
        try jsonData.write(to: tempDir.appendingPathComponent("data.json"))

        let zipURL = fm.temporaryDirectory.appendingPathComponent("CaptureD_Backup_\(formattedDate()).zip")
        if fm.fileExists(atPath: zipURL.path) {
            try fm.removeItem(at: zipURL)
        }

        let coordinator = NSFileCoordinator()
        var error: NSError?
        coordinator.coordinate(readingItemAt: tempDir, options: .forUploading, error: &error) { zipTempURL in
            try? fm.copyItem(at: zipTempURL, to: zipURL)
        }
        if let error { throw error }

        try? fm.removeItem(at: tempDir)
        return zipURL
    }

    /// 通过系统分享面板分享 ZIP 文件
    func share(zipURL: URL, from viewController: UIViewController) {
        let activity = UIActivityViewController(activityItems: [zipURL], applicationActivities: nil)
        viewController.present(activity, animated: true)
    }

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
