import SwiftUI
import SwiftData

/// App 入口
@main
struct CaptureDApp: App {
    @State private var databaseManager: DatabaseManager
    @State private var storageManager: PhotoStorageManager
    @State private var aiManager: AIManager

    init() {
        let db = try! DatabaseManager()
        let storage = PhotoStorageManager()
        let ai = AIManager()
        _databaseManager = State(initialValue: db)
        _storageManager = State(initialValue: storage)
        _aiManager = State(initialValue: ai)
    }

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

            for categoryName in item.categories {
                guard let category = CategoryType(rawValue: categoryName) else { continue }
                _ = databaseManager.createUnsortedFile(
                    title: item.savedAt.unsortedFileName,
                    category: category,
                    imageRecord: imageRecord
                )
            }

            storageManager.removePendingImageFile(fileName: item.imageFileName)
        }

        storageManager.clearPending()
    }
}
