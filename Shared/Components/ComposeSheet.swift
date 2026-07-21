import SwiftUI

/// 统一输入 Sheet — 9/12 屏，用于碎碎念新建和文件内容编辑
struct ComposeSheet: View {
    let placeholder: String
    let navTitle: String
    var initialText: String = ""
    let onPublish: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TextEditor(text: $text)
                    .font(AppTheme.Fonts.serif(AppTheme.FontSize.body, weight: .light))
                    .lineSpacing(6)
                    .focused($isFocused)
                    .padding(AppTheme.Spacing.md)
                    .scrollContentBackground(.hidden)
                    .background(AppTheme.Colors.background)
                    .overlay(alignment: .topLeading) {
                        if text.isEmpty {
                            Text(placeholder)
                                .font(AppTheme.Fonts.serif(AppTheme.FontSize.body, weight: .light))
                                .foregroundStyle(AppTheme.Colors.tertiaryText)
                                .padding(AppTheme.Spacing.md)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                                .allowsHitTesting(false)
                        }
                    }
            }
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
                    Button("发布") {
                        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        onPublish(trimmed)
                        dismiss()
                    }
                    .font(AppTheme.Fonts.serif(AppTheme.FontSize.body, weight: .regular))
                    .foregroundStyle(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        ? AppTheme.Colors.tertiaryText
                        : AppTheme.Colors.accent
                    )
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                KeyboardToolbar()
            }
        }
        .presentationDetents([.fraction(0.75)])
        .onAppear {
            text = initialText
            isFocused = true
        }
    }
}
