import SwiftUI

/// 根视图 — 引导页完成前显示引导，完成后显示主界面
struct ContentView: View {
    @State private var onboardingCompleted = UserDefaults.standard.bool(forKey: "onboarding_completed")
    @State private var showCompose = false
    @Environment(DatabaseManager.self) private var database
    @Environment(PhotoStorageManager.self) private var storage

    var body: some View {
        if onboardingCompleted {
            ZStack(alignment: .bottomTrailing) {
                CollectionView()

                FABButton(showCompose: $showCompose)
                    .padding(.trailing, 20)
                    .padding(.bottom, 80)
            }
            .sheet(isPresented: $showCompose) {
                ComposeSheet(
                    placeholder: "记录此刻的想法...",
                    navTitle: "新内容",
                    mode: .compose
                ) { result in
                    handlePublish(result)
                }
            }
        } else {
            OnboardingView(isCompleted: $onboardingCompleted)
        }
    }

    private func handlePublish(_ result: ComposeResult) {
        if let imageData = result.imageData {
            // 带图 → 走分类发布流程
            let imageID = storage.saveImage(imageData)
            let imageRecord = database.createImageRecord(imageID: imageID)

            let hasValidName = !result.fileName.isEmpty && AppConstants.isValidFileName(result.fileName)
            let title = hasValidName ? result.fileName : Date().unsortedFileName
            let status: FileStatus = hasValidName ? .sorted : .unsorted

            for category in result.categories {
                let file = CollectionFile(title: title, category: category, status: status)
                file.tags = result.tags
                file.images.append(imageRecord)
                imageRecord.files.append(file)
                let block = ContentBlock(text: result.text, isAIGenerated: false, file: file)
                database.insertFileWithBlock(file, block: block)
            }
        } else {
            // 纯文本 → 自动归类为碎碎念
            _ = database.createMurmur(text: result.text, tags: result.tags)
        }
    }
}
