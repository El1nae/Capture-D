import SwiftUI
import SwiftData

/// App 入口
@main
struct CaptureDApp: App {
    // Managers are @Observable classes, injected via .environment()
    @State private var databaseManager = DatabaseManager()
    @State private var storageManager = PhotoStorageManager()
    @State private var aiManager = AIManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(databaseManager)
                .environment(storageManager)
                .environment(aiManager)
                .onAppear {
                    processPendingImages()
                }
                .preferredColorScheme(.light)
        }
    }

    /// 启动时处理 Share Extension 写入的待处理图片
    private func processPendingImages() {
        let pendingItems = storageManager.loadPendingImages()
        guard !pendingItems.isEmpty else { return }

        for item in pendingItems {
            guard let imageData = storageManager.loadPendingImageData(fileName: item.imageFileName) else { continue }

            let imageID = storageManager.saveImage(imageData)
            let imageRecord = ImageRecord(imageID: imageID, capturedAt: item.savedAt)

            let hasValidName = !item.name.isEmpty && AppConstants.isValidFileName(item.name)
            let title = hasValidName ? item.name : item.savedAt.unsortedFileName
            let status: FileStatus = hasValidName ? .sorted : .unsorted

            for categoryName in item.categories {
                guard let category = CategoryType(rawValue: categoryName) else { continue }
                let file = databaseManager.createUnsortedFile(
                    title: title,
                    category: category,
                    imageRecord: imageRecord
                )
                file.tags = item.tags
                if hasValidName {
                    file.status = .sorted
                }
            }

            storageManager.removePendingImageFile(fileName: item.imageFileName)
        }

        storageManager.clearPending()
    }
}
