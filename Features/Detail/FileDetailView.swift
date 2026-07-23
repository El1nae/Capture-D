import SwiftUI

/// 文件详情页 — 时间线内容 + 逐条编辑/删除 + 追加 + 左滑图片浮层
struct FileDetailView: View {
    let file: CollectionFile
    @Environment(DatabaseManager.self) private var database
    @Environment(PhotoStorageManager.self) private var storage
    @Environment(\.dismiss) private var dismiss
    @State private var showImageGallery = false
    @State private var isEditingTags = false
    @State private var editableTags: [String] = []
    @State private var editingBlock: ContentBlock?
    @State private var showAppendSheet = false
    @State private var showDeleteAlert = false
    @State private var blockToDelete: ContentBlock?

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if !file.tags.isEmpty || isEditingTags {
                        tagSection
                            .padding(.horizontal, AppTheme.Spacing.md)
                            .padding(.top, AppTheme.Spacing.sm)
                            .padding(.bottom, AppTheme.Spacing.sm)
                    }

                    ForEach(sortedBlocks, id: \.persistentModelID) { block in
                        VStack(alignment: .leading, spacing: 0) {
                            TimelineSeparator(date: block.createdAt)

                            HStack(alignment: .top, spacing: 4) {
                                Text(block.text)
                                    .bodyTextStyle()
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Button(action: { editingBlock = block }) {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 13, weight: .light))
                                        .foregroundStyle(AppTheme.Colors.tertiaryText)
                                }
                                .buttonStyle(.plain)
                                .padding(.top, 2)
                            }
                            .padding(.horizontal, AppTheme.Spacing.md)
                            .padding(.bottom, AppTheme.Spacing.sm)

                            Divider()
                                .padding(.leading, AppTheme.Spacing.md)
                        }
                        .contextMenu {
                            Button(action: { editingBlock = block }) {
                                Label("编辑", systemImage: "pencil")
                            }
                            Button(role: .destructive, action: {
                                blockToDelete = block
                                showDeleteAlert = true
                            }) {
                                Label("删除", systemImage: "trash")
                            }
                        }
                    }

                    if sortedBlocks.isEmpty {
                        Text("暂无内容")
                            .font(AppTheme.Fonts.sans(AppTheme.FontSize.caption, weight: .light))
                            .tracking(0.6)
                            .foregroundStyle(AppTheme.Colors.tertiaryText)
                            .padding(AppTheme.Spacing.md)
                    }

                    HStack {
                        Spacer()
                        Button(action: { showAppendSheet = true }) {
                            HStack(spacing: 4) {
                                Image(systemName: "plus")
                                    .font(.system(size: 12, weight: .medium))
                                Text("追加")
                                    .font(AppTheme.Fonts.sans(AppTheme.FontSize.caption, weight: .regular))
                            }
                            .foregroundStyle(AppTheme.Colors.accent)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .overlay(
                                Capsule()
                                    .stroke(AppTheme.Colors.accent.opacity(0.4), lineWidth: 0.5)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.top, AppTheme.Spacing.xs)
                    .padding(.bottom, AppTheme.Spacing.xl)
                }
            }

            if showImageGallery {
                ImageGalleryOverlay(
                    file: file,
                    isPresented: $showImageGallery
                )
                .transition(.move(edge: .trailing))
            }
        }
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
                    Button(action: {
                        editableTags = file.tags
                        isEditingTags.toggle()
                    }) {
                        Label(isEditingTags ? "完成标签编辑" : "编辑标签", systemImage: "tag")
                    }
                    Divider()
                    Button(role: .destructive, action: {
                        showDeleteAlert = true
                        blockToDelete = nil
                    }) {
                        Label("删除", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: AppTheme.FontSize.headline, weight: .light))
                        .foregroundStyle(AppTheme.Colors.accent)
                }
            }
        }
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    if value.translation.width < -50 && !file.images.isEmpty {
                        withAnimation(AppTheme.Animation.standard) {
                            showImageGallery = true
                        }
                    }
                }
        )
        .sheet(item: $editingBlock) { block in
            ComposeSheet(
                placeholder: "编辑内容...",
                navTitle: "编辑",
                initialText: block.text
            ) { text in
                database.updateContentBlock(block, newText: text)
            }
        }
        .sheet(isPresented: $showAppendSheet) {
            ComposeSheet(
                placeholder: "补充内容...",
                navTitle: "追加内容"
            ) { text in
                database.appendContentBlock(to: file, text: text)
            }
        }
        .alert("确认删除", isPresented: $showDeleteAlert) {
            Button("取消", role: .cancel) {
                blockToDelete = nil
            }
            Button("删除", role: .destructive) {
                if let block = blockToDelete {
                    let isLastMurmurBlock = file.category == .murmur && file.contentBlocks.count <= 1
                    database.deleteContentBlock(block)
                    if isLastMurmurBlock {
                        dismiss()
                    }
                } else {
                    database.softDelete(file)
                    dismiss()
                }
                blockToDelete = nil
            }
        } message: {
            if blockToDelete != nil {
                Text("删除后无法恢复这条内容")
            } else {
                Text("将移入回收站，30天后永久删除")
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
        file.sortedBlocks
    }
}
