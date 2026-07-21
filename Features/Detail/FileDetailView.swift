import SwiftUI

/// 文件详情页 — 纯文字内容 + 左滑图片浮层
struct FileDetailView: View {
    let file: CollectionFile
    @Environment(DatabaseManager.self) private var database
    @Environment(PhotoStorageManager.self) private var storage
    @State private var showImageGallery = false
    @State private var isEditing = false
    @State private var isEditingTags = false
    @State private var editableTags: [String] = []

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // 标签区域
                    if !file.tags.isEmpty || isEditingTags {
                        tagSection
                            .padding(.horizontal, AppTheme.Spacing.md)
                            .padding(.top, AppTheme.Spacing.sm)
                            .padding(.bottom, AppTheme.Spacing.sm)
                    }

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
                Menu {
                    Button(action: { isEditing = true }) {
                        Label("编辑内容", systemImage: "square.and.pencil")
                    }
                    Button(action: {
                        editableTags = file.tags
                        isEditingTags.toggle()
                    }) {
                        Label(isEditingTags ? "完成标签编辑" : "编辑标签", systemImage: "tag")
                    }
                } label: {
                    Text("编辑")
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
            ComposeSheet(
                placeholder: "补充内容...",
                navTitle: "编辑内容",
                initialText: sortedBlocks.map(\.text).joined(separator: "\n\n")
            ) { text in
                saveEdits(text)
            }
        }
    }

    @ViewBuilder
    private var tagSection: some View {
        if isEditingTags {
            TagInputView(
                tags: $editableTags,
                allHistoryTags: database.allTags()
            )
            .onChange(of: editableTags) { _, newTags in
                // 实时同步到数据库
                let current = Set(file.tags)
                let updated = Set(newTags)
                for tag in updated.subtracting(current) {
                    database.addTag(tag, to: file)
                }
                for tag in current.subtracting(updated) {
                    database.removeTag(tag, from: file)
                }
            }
        } else {
            TagFlowView(tags: file.tags)
        }
    }

    private var sortedBlocks: [ContentBlock] {
        file.contentBlocks.sorted { $0.createdAt < $1.createdAt }
    }

    private func saveEdits(_ text: String) {
        let block = ContentBlock(text: text, isAIGenerated: false, file: file)
        file.contentBlocks.append(block)
        file.updatedAt = Date()
    }
}
