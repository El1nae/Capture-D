import SwiftUI

/// 全局主题配置
enum AppTheme {
    // MARK: - 颜色
    enum Colors {
        static let background = Color(.systemBackground)
        static let cardBackground = Color(.secondarySystemBackground)
        static let primaryText = Color(.label)
        static let secondaryText = Color(.secondaryLabel)
        static let tertiaryText = Color(.tertiaryLabel)
        static let accent = Color.blue
        static let separator = Color(.separator)
        static let goldGlow = Color.yellow.opacity(0.6)
        static let unsortedBanner = Color(.systemGray6)
        static let destructive = Color.red
    }

    // MARK: - 字号
    enum FontSize {
        static let largeTitle: CGFloat = 28
        static let title: CGFloat = 20
        static let headline: CGFloat = 17
        static let body: CGFloat = 15
        static let caption: CGFloat = 13
        static let footnote: CGFloat = 11
    }

    // MARK: - 间距
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    // MARK: - 圆角
    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let card: CGFloat = 20
    }

    // MARK: - 阴影
    enum Shadow {
        static let light: CGFloat = 2
        static let medium: CGFloat = 4
        static let heavy: CGFloat = 8
    }

    // MARK: - 动画
    enum Animation {
        static let springResponse: Double = 0.5
        static let springDamping: Double = 0.7
        static let standard = SwiftUI.Animation.spring(response: springResponse, dampingFraction: springDamping)
        static let quick = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.8)
    }
}
