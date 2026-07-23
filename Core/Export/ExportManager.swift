import Foundation
import UIKit

/// 导出管理器 — 将所有数据打包为 ZIP
@MainActor
final class ExportManager {
    let database: DatabaseManager
    let storage: PhotoStorageManager
    private static let isoFormatter = ISO8601DateFormatter()
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    init(database: DatabaseManager, storage: PhotoStorageManager) {
        self.database = database
        self.storage = storage
    }

    func exportAll() throws -> URL {
        let fm = FileManager.default
        let tempDir = fm.temporaryDirectory.appendingPathComponent("CaptureD_Export_\(UUID().uuidString)")
        let imagesDir = tempDir.appendingPathComponent("images")
        try fm.createDirectory(at: imagesDir, withIntermediateDirectories: true)
        let iso = Self.isoFormatter

        let allFiles = database.allSortedFiles() + database.deletedFiles()

        var fileExports: [[String: Any]] = []
        var imageIDs: Set<String> = []

        for file in allFiles {
            var fileDict: [String: Any] = [
                "title": file.title,
                "category": file.categoryRawValue,
                "status": file.statusRawValue,
                "tags": file.tags,
                "createdAt": iso.string(from: file.createdAt),
                "updatedAt": iso.string(from: file.updatedAt)
            ]
            if let deletedAt = file.deletedAt {
                fileDict["deletedAt"] = iso.string(from: deletedAt)
            }

            var blocks: [[String: Any]] = []
            for block in file.sortedBlocks {
                blocks.append([
                    "text": block.text,
                    "isAIGenerated": block.isAIGenerated,
                    "createdAt": iso.string(from: block.createdAt)
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
            "exportDate": iso.string(from: Date()),
            "files": fileExports
        ]
        let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: [.prettyPrinted, .sortedKeys])
        try jsonData.write(to: tempDir.appendingPathComponent("data.json"))

        let zipURL = fm.temporaryDirectory.appendingPathComponent("CaptureD_Backup_\(Self.dateFormatter.string(from: Date())).zip")
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

    func share(zipURL: URL, from viewController: UIViewController) {
        let activity = UIActivityViewController(activityItems: [zipURL], applicationActivities: nil)
        viewController.present(activity, animated: true)
    }
}
