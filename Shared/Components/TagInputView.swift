import SwiftUI

/// Tag 输入组件：输入框 + 历史建议列表
struct TagInputView: View {
    @Binding var tags: [String]
    let allHistoryTags: [String]
    @State private var inputText = ""
    @FocusState private var isFocused: Bool

    private var suggestions: [String] {
        let existing = Set(tags)
        if inputText.isEmpty {
            return allHistoryTags.filter { !existing.contains($0) }
        }
        return allHistoryTags.filter {
            !existing.contains($0) && $0.localizedStandardContains(inputText)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            TagFlowView(tags: tags, onRemove: { tag in
                tags.removeAll { $0 == tag }
            })

            HStack(spacing: 8) {
                TextField("添加标签", text: $inputText)
                    .font(AppTheme.Fonts.sans(AppTheme.FontSize.body, weight: .light))
                    .focused($isFocused)
                    .onSubmit { addCurrentTag() }

                if !inputText.isEmpty {
                    Button(action: addCurrentTag) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(AppTheme.Colors.accent)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(AppTheme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))

            if !suggestions.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(suggestions.prefix(10), id: \.self) { suggestion in
                            Button(action: { addTag(suggestion) }) {
                                TagChip(text: suggestion)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private func addCurrentTag() {
        addTag(inputText)
    }

    private func addTag(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !tags.contains(trimmed) else {
            inputText = ""
            return
        }
        tags.append(trimmed)
        inputText = ""
    }
}
