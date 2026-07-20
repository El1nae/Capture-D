import SwiftUI

/// 文件详情页 — 纯文字内容 + 左滑图片浮层
struct FileDetailView: View {
    let file: CollectionFile
    @Environment(DatabaseManager.self) private var database
    @Environment(PhotoStorageManager.self) private var storage
    @State private var showImageGallery = false
    @State private var editingText = ""
    @State private var isEditing = false

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // 时间线式内容块
                    ForEach(sortedBlocks, id: \.createdAt) { block in
                        TimelineSeparator(date: block.createdAt)

                        Text(block.text)
                            .bodyTextStyle()
                            .padding(.horizontal, AppTheme.Spacing.md)
                            .padding(.bottom, AppTheme.Spacing.md)
                    }

                    if sortedBlocks.isEmpty {
                        Text("暂无内容")
                            .font(AppTheme.Fonts.sans(AppTheme.FontSize.caption, weight: .light))
                            .tracking(0.6)
                            .foregroundStyle(AppTheme.Colors.tertiaryText)
                            .padding(AppTheme.Spacing.md)
                    }
                }
                .padding(.bottom, AppTheme.Spacing.xl)
            }

            // 左滑图片浮层
            if showImageGallery {
                ImageGalleryOverlay(
                    file: file,
                    isPresented: $showImageGallery
                )
                .transition(.move(edge: .trailing))
            }
        }
        .navigationTitle(file.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(file.title)
                    .font(AppTheme.Fonts.serif(AppTheme.FontSize.headline, weight: .regular))
                    .tracking(0.5)
                    .foregroundStyle(AppTheme.Colors.primaryText)
                    .lineLimit(1)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { isEditing.toggle() }) {
                    Text(isEditing ? "完成" : "编辑")
                        .font(AppTheme.Fonts.serif(AppTheme.FontSize.body, weight: .light))
                        .tracking(0.5)
                        .foregroundStyle(AppTheme.Colors.accent)
                }
            }
        }
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    if value.translation.width < -50 {
                        withAnimation(AppTheme.Animation.standard) {
                            showImageGallery = true
                        }
                    }
                }
        )
        .sheet(isPresented: $isEditing) {
            editSheet
        }
    }

    private var sortedBlocks: [ContentBlock] {
        file.contentBlocks.sorted { $0.createdAt < $1.createdAt }
    }

    /// 编辑模式 — 模仿备忘录
    private var editSheet: some View {
        NavigationStack {
            TextEditor(text: $editingText)
                .font(.system(size: AppTheme.FontSize.body))
                .padding(AppTheme.Spacing.md)
                .onAppear {
                    editingText = sortedBlocks.map(\.text).joined(separator: "\n\n")
                }
                .navigationTitle("编辑内容")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("取消") { isEditing = false }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("保存") {
                            saveEdits()
                            isEditing = false
                        }
                    }
                }
        }
    }

    private func saveEdits() {
        let block = ContentBlock(text: editingText, isAIGenerated: false, file: file)
        file.contentBlocks.append(block)
        file.updatedAt = Date()
    }
}
