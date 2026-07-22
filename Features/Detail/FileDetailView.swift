import SwiftUI

/// 文件详情页 — 时间线内容 + 逐条编辑 + 追加 + 左滑图片浮层
struct FileDetailView: View {
    let file: CollectionFile
    @Environment(DatabaseManager.self) private var database
    @Environment(PhotoStorageManager.self) private var storage
    @State private var showImageGallery = false
    @State private var isEditingTags = false
    @State private var editableTags: [String] = []
    @State private var editingBlock: ContentBlock?
    @State private var showAppendSheet = false

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

                    ForEach(sortedBlocks, id: \.createdAt) { block in
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
                Button(action: {
                    editableTags = file.tags
                    isEditingTags.toggle()
                }) {
                    Text(isEditingTags ? "完成" : "编辑")
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
        file.contentBlocks.sorted { $0.createdAt < $1.createdAt }
    }
}
