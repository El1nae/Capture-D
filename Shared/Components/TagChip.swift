import SwiftUI

/// 单个 Tag 胶囊标签
struct TagChip: View {
    let text: String
    var onRemove: (() -> Void)?

    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(AppTheme.Fonts.sans(AppTheme.FontSize.footnote, weight: .regular))
                .foregroundStyle(AppTheme.Colors.accent)

            if let onRemove {
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundStyle(AppTheme.Colors.accent.opacity(0.6))
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(AppTheme.Colors.accentLight)
        .overlay(
            Capsule().stroke(AppTheme.Colors.accentMid, lineWidth: 0.5)
        )
        .clipShape(Capsule())
    }
}
