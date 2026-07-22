import SwiftUI

/// 浮层图片卡片 — 图片撑满，日期左对齐悬浮
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
        if let uiImage = UIImage(data: imageData) {
            ZStack(alignment: .bottomLeading) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                            .stroke(showGoldGlow ? AppTheme.Colors.goldGlow : .clear, lineWidth: 2)
                    )
                    .shadow(color: showGoldGlow ? AppTheme.Colors.goldGlow.opacity(0.25) : .clear, radius: 6)
                    .onLongPressGesture {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        onLongPress?()
                    }

                Text(capturedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(AppTheme.Fonts.serif(AppTheme.FontSize.footnote, weight: .light))
                    .tracking(0.6)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)
                    .padding(AppTheme.Spacing.sm)
            }
        }
    }
}
