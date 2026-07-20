import SwiftUI

/// 浮层图片卡片 — 比屏幕小一圈，轻盈灵动
struct FloatingImageCard: View {
    let imageData: Data
    let capturedAt: Date
    let showGoldGlow: Bool
    let onLongPress: (() -> Void)?

    init(
        imageData: Data,
        capturedAt: Date,
        showGoldGlow: Bool = false,
        onLongPress: (() -> Void)? = nil
    ) {
        self.imageData = imageData
        self.capturedAt = capturedAt
        self.showGoldGlow = showGoldGlow
        self.onLongPress = onLongPress
    }

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Text(capturedAt.formatted(date: .abbreviated, time: .shortened))
                .font(AppTheme.Fonts.serif(AppTheme.FontSize.footnote, weight: .light))
                .tracking(0.6)
                .foregroundStyle(AppTheme.Colors.tertiaryText)

            if let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                            .stroke(showGoldGlow ? AppTheme.Colors.goldGlow : .clear, lineWidth: 2)
                    )
                    .shadow(color: showGoldGlow ? AppTheme.Colors.goldGlow.opacity(0.25) : .clear, radius: 6)
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .onLongPressGesture {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        onLongPress?()
                    }
            }
        }
    }
}
