import SwiftUI

/// 浮层卡片 — 极淡阴影 + 细边框
struct FloatingCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppTheme.Colors.background)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.card))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.card)
                    .stroke(AppTheme.Colors.primaryText.opacity(0.06), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.04), radius: AppTheme.Shadow.medium, y: 2)
    }
}

/// 瀑布流卡片 — 极淡阴影 + 细边框
struct WaterfallCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppTheme.Colors.background)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(AppTheme.Colors.primaryText.opacity(0.06), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.03), radius: AppTheme.Shadow.light, y: 1)
    }
}

extension View {
    func floatingCardStyle() -> some View {
        modifier(FloatingCardModifier())
    }

    func waterfallCardStyle() -> some View {
        modifier(WaterfallCardModifier())
    }
}
