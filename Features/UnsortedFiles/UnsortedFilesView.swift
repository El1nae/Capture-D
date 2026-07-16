import SwiftUI

/// 未整理文件列表 + AI 分析触发按钮
struct UnsortedFilesView: View {
    let category: CategoryType
    @Environment(DatabaseManager.self) private var database
    @Environment(PhotoStorageManager.self) private var storage
    @Environment(AIManager.self) private var aiManager
    @State private var selectedFiles: Set<String> = []
    @State private var isAnalyzing = false
    @State private var toastMessage: String?
    @State private var editingFile: CollectionFile?
    @State private var editingName = ""

    private var files: [CollectionFile] {
        database.unsortedFiles(for: category)
    }

    var body: some View {
        VStack(spacing: 0) {
            if files.isEmpty {
                VStack(spacing: AppTheme.Spacing.md) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 48))
                        .foregroundStyle(AppTheme.Colors.tertiaryText)
                    Text("没有未整理的文件")
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                fileList
                bottomBar
            }
        }
        .navigationTitle("\(category.rawValue) · 未整理")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(toastOverlay)
        .alert("重命名文件", isPresented: .init(
            get: { editingFile != nil },
            set: { if !$0 { editingFile = nil } }
        )) {
            TextField("输入文件名（如：作品名|作者）", text: $editingName)
            Button("确定") { confirmRename() }
            Button("取消", role: .cancel) { editingFile = nil }
        }
    }

    private var fileList: some View {
        List {
            ForEach(files, id: \.persistentModelID) { file in
                fileRow(file)
            }
        }
        .listStyle(.plain)
    }

    private func fileRow(_ file: CollectionFile) -> some View {
        let fileID = file.title
        let isSelected = selectedFiles.contains(fileID)

        return HStack {
            // 选择框
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.tertiaryText)
                .onTapGesture { toggleSelection(fileID) }

            // 缩略图
            if let firstImage = file.images.first,
               let thumbData = storage.loadThumbnail(id: firstImage.imageID),
               let uiImage = UIImage(data: thumbData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small))
            }

            VStack(alignment: .leading) {
                Text(file.title)
                    .font(.system(size: AppTheme.FontSize.body))
                Text("\(file.images.count) 张图片")
                    .font(.system(size: AppTheme.FontSize.caption))
                    .foregroundStyle(AppTheme.Colors.tertiaryText)
            }

            Spacer()

            // 手动改名按钮
            Button(action: {
                editingFile = file
                editingName = ""
            }) {
                Image(systemName: "pencil")
                    .foregroundStyle(AppTheme.Colors.secondaryText)
            }
        }
        .padding(.vertical, 4)
    }

    /// 底部操作栏
    private var bottomBar: some View {
        HStack {
            Text("已选 \(selectedFiles.count) 项")
                .font(.system(size: AppTheme.FontSize.caption))
                .foregroundStyle(AppTheme.Colors.secondaryText)

            Spacer()

            Button(action: { Task { await analyzeSelected() } }) {
                HStack {
                    if isAnalyzing {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    Text(isAnalyzing ? "分析中..." : "AI 分析")
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .frame(width: 140)
            .disabled(selectedFiles.isEmpty || isAnalyzing)
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.background)
    }

    private var toastOverlay: some View {
        Group {
            if let message = toastMessage {
                VStack {
                    Spacer()
                    Text(message)
                        .font(.system(size: AppTheme.FontSize.caption))
                        .foregroundStyle(.white)
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .padding(.vertical, AppTheme.Spacing.sm)
                        .background(Color.black.opacity(0.7))
                        .clipShape(Capsule())
                        .padding(.bottom, 80)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation { toastMessage = nil }
                    }
                }
            }
        }
    }

    // MARK: - Actions

    private func toggleSelection(_ fileID: String) {
        if selectedFiles.contains(fileID) {
            selectedFiles.remove(fileID)
        } else {
            selectedFiles.insert(fileID)
        }
    }

    private func analyzeSelected() async {
        isAnalyzing = true
        defer { isAnalyzing = false }

        let toAnalyze = files.filter { selectedFiles.contains($0.title) }

        for file in toAnalyze {
            guard let firstImage = file.images.first,
                  let imageData = storage.loadImage(id: firstImage.imageID) else { continue }

            // 找出同一张图在其他分类的未整理文件
            let allCategoryFiles = firstImage.files.filter { $0.status == .unsorted }
            let allCategories = allCategoryFiles.map(\.category)

            do {
                try await aiManager.analyzeImage(
                    imageData: imageData,
                    categories: allCategories.isEmpty ? [file.category] : allCategories,
                    database: database,
                    imageRecord: firstImage,
                    files: allCategoryFiles.isEmpty ? [file] : allCategoryFiles
                )
            } catch {
                withAnimation {
                    toastMessage = error.localizedDescription
                }
            }
        }

        selectedFiles.removeAll()
        withAnimation { toastMessage = "分析完成" }
    }

    private func confirmRename() {
        guard let file = editingFile, !editingName.isEmpty else {
            editingFile = nil
            return
        }

        if AppConstants.isValidFileName(editingName) {
            database.manualPromote(file, newTitle: editingName)
            withAnimation { toastMessage = "已移出未整理" }
        } else {
            file.title = editingName
            file.updatedAt = Date()
            withAnimation { toastMessage = "已重命名（格式为 作品名|作者 时会自动提升）" }
        }

        editingFile = nil
    }
}
