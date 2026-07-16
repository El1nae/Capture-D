import SwiftUI

/// 浮层卡片样式修饰符
struct FloatingCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppTheme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.card))
            .shadow(color: .black.opacity(0.1), radius: AppTheme.Shadow.medium, y: 2)
    }
}

/// 瀑布流卡片样式修饰符
struct WaterfallCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppTheme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
            .shadow(color: .black.opacity(0.06), radius: AppTheme.Shadow.light, y: 1)
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
