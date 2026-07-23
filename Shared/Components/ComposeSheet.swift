import SwiftUI
import PhotosUI

/// 统一输入 Sheet — 纯文本自动归为碎碎念，带图走分类发布
struct ComposeSheet: View {
    let placeholder: String
    let navTitle: String
    var initialText: String = ""
    var mode: ComposeMode = .compose
    let onPublish: (ComposeResult) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var selectedCategories: Set<CategoryType> = []
    @State private var tagText = ""
    @State private var tags: [String] = []
    @State private var fileName = ""
    @FocusState private var isFocused: Bool

    enum ComposeMode {
        case compose
        case editBlock
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    textArea

                    if mode == .compose {
                        imagePickerSection
                    }

                    if selectedImageData != nil {
                        categorySection
                        nameField
                        tagField
                    }
                }
                .padding(AppTheme.Spacing.md)
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.Colors.background)
            .navigationTitle(navTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") { dismiss() }
                        .font(AppTheme.Fonts.sans(AppTheme.FontSize.body, weight: .light))
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("发布") { publish() }
                        .font(AppTheme.Fonts.serif(AppTheme.FontSize.body, weight: .regular))
                        .foregroundStyle(canPublish ? AppTheme.Colors.accent : AppTheme.Colors.tertiaryText)
                        .disabled(!canPublish)
                }
                KeyboardToolbar()
            }
        }
        .presentationDetents(selectedImageData != nil ? [.fraction(0.85)] : [.fraction(0.45)])
        .onAppear {
            text = initialText
            isFocused = true
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    selectedImageData = data
                } else {
                    selectedImageData = nil
                }
            }
        }
    }

    private var canPublish: Bool {
        let hasText = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if selectedImageData != nil {
            return hasText && !selectedCategories.isEmpty
        }
        return hasText
    }

    private var textArea: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .font(AppTheme.Fonts.serif(AppTheme.FontSize.body, weight: .light))
                .lineSpacing(4)
                .focused($isFocused)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 80)

            if text.isEmpty {
                Text(placeholder)
                    .font(AppTheme.Fonts.serif(AppTheme.FontSize.body, weight: .light))
                    .foregroundStyle(AppTheme.Colors.tertiaryText)
                    .padding(.top, 8)
                    .padding(.leading, 5)
                    .allowsHitTesting(false)
            }
        }
    }

    private var imagePickerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imageData = selectedImageData, let uiImage = UIImage(data: imageData) {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    Button(action: {
                        selectedImageData = nil
                        selectedPhotoItem = nil
                        selectedCategories.removeAll()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.white, .black.opacity(0.5))
                    }
                    .padding(4)
                }
            }

            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                HStack(spacing: 4) {
                    Image(systemName: "photo")
                        .font(.system(size: 13, weight: .light))
                    Text(selectedImageData == nil ? "添加图片" : "更换图片")
                        .font(AppTheme.Fonts.sans(AppTheme.FontSize.caption, weight: .regular))
                }
                .foregroundStyle(AppTheme.Colors.accent)
            }
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("选择分类（必选）")
                .font(AppTheme.Fonts.sans(AppTheme.FontSize.caption, weight: .light))
                .foregroundStyle(AppTheme.Colors.secondaryText)

            HStack(spacing: 8) {
                ForEach(CategoryType.shareableCategories, id: \.self) { category in
                    let isSelected = selectedCategories.contains(category)
                    Button(action: {
                        if isSelected {
                            selectedCategories.remove(category)
                        } else {
                            selectedCategories.insert(category)
                        }
                    }) {
                        Text(category.rawValue)
                            .font(AppTheme.Fonts.serif(AppTheme.FontSize.caption, weight: .regular))
                            .tracking(0.3)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(isSelected ? AppTheme.Colors.accent : .clear)
                            .foregroundStyle(isSelected ? .white : AppTheme.Colors.accent)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(AppTheme.Colors.accent.opacity(0.5), lineWidth: 0.5)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("命名（可选，格式：作品名|作者）")
                .font(AppTheme.Fonts.sans(AppTheme.FontSize.caption, weight: .light))
                .foregroundStyle(AppTheme.Colors.secondaryText)

            TextField("例：静夜思|李白", text: $fileName)
                .font(AppTheme.Fonts.serif(AppTheme.FontSize.body, weight: .light))
                .padding(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(AppTheme.Colors.tertiaryText.opacity(0.3), lineWidth: 0.5)
                )
        }
    }

    private var tagField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("标签（可选，回车添加）")
                .font(AppTheme.Fonts.sans(AppTheme.FontSize.caption, weight: .light))
                .foregroundStyle(AppTheme.Colors.secondaryText)

            HStack {
                TextField("添加标签", text: $tagText)
                    .font(AppTheme.Fonts.serif(AppTheme.FontSize.body, weight: .light))
                    .onSubmit { addTag() }

                if !tagText.isEmpty {
                    Button(action: addTag) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(AppTheme.Colors.accent)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(AppTheme.Colors.tertiaryText.opacity(0.3), lineWidth: 0.5)
            )

            if !tags.isEmpty {
                TagFlowView(tags: tags, onRemove: { tag in
                    tags.removeAll { $0 == tag }
                })
            }
        }
    }

    private func addTag() {
        let trimmed = tagText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !tags.contains(trimmed) else { return }
        tags.append(trimmed)
        tagText = ""
    }

    private func publish() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let result = ComposeResult(
            text: trimmed,
            imageData: selectedImageData,
            categories: Array(selectedCategories),
            fileName: fileName.trimmingCharacters(in: .whitespaces),
            tags: tags
        )
        onPublish(result)
        dismiss()
    }
}

struct ComposeResult {
    let text: String
    let imageData: Data?
    let categories: [CategoryType]
    let fileName: String
    let tags: [String]
}

// MARK: - 向后兼容的初始化器（编辑/追加场景只需文字回调）
extension ComposeSheet {
    init(
        placeholder: String,
        navTitle: String,
        initialText: String = "",
        onPublish: @escaping (String) -> Void
    ) {
        self.placeholder = placeholder
        self.navTitle = navTitle
        self.initialText = initialText
        self.mode = .editBlock
        self.onPublish = { result in onPublish(result.text) }
    }
}
