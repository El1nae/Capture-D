import SwiftUI

/// 分类按钮 — 胶囊形，细描边
struct CategoryButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Fonts.serif(AppTheme.FontSize.caption, weight: .regular))
            .tracking(0.5)
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, 7)
            .background(isSelected ? AppTheme.Colors.accent : .clear)
            .foregroundStyle(isSelected ? AppTheme.Colors.background : AppTheme.Colors.secondaryText)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.primaryText.opacity(0.1), lineWidth: 0.5)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : (isSelected ? 1.03 : 1.0))
            .animation(AppTheme.Animation.quick, value: configuration.isPressed)
    }
}

/// 主要操作按钮 — 胶囊形，浅绿填充
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Fonts.serif(AppTheme.FontSize.body, weight: .regular))
            .tracking(1.2)
            .foregroundStyle(AppTheme.Colors.background)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(AppTheme.Colors.accent)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(AppTheme.Animation.quick, value: configuration.isPressed)
    }
}

/// 次要操作按钮 — 胶囊形，透明底
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Fonts.serif(AppTheme.FontSize.body))
            .tracking(0.8)
            .foregroundStyle(AppTheme.Colors.accent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(.clear)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(AppTheme.Colors.primaryText.opacity(0.1), lineWidth: 0.5)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(AppTheme.Animation.quick, value: configuration.isPressed)
    }
}
