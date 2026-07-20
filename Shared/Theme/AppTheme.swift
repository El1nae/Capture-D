import SwiftUI

/// 全局主题配置 — 日系极简 · 浅绿
enum AppTheme {
    // MARK: - 颜色
    enum Colors {
        static let background = Color(red: 0.98, green: 0.98, blue: 0.965)        // #FAFAF6 米白
        static let cardBackground = Color(red: 0.941, green: 0.937, blue: 0.918)   // #F0EFEA 暖灰
        static let primaryText = Color(red: 0.176, green: 0.176, blue: 0.165)      // #2D2D2A 墨黑
        static let secondaryText = Color(red: 0.549, green: 0.549, blue: 0.518)    // #8C8C84
        static let tertiaryText = Color(red: 0.722, green: 0.718, blue: 0.69)      // #B8B7B0
        static let accent = Color(red: 0.49, green: 0.569, blue: 0.447)            // #7D9172 鼠尾草绿
        static let separator = Color(red: 0.176, green: 0.176, blue: 0.165).opacity(0.06)
        static let goldGlow = Color(red: 0.49, green: 0.569, blue: 0.447).opacity(0.45)
        static let unsortedBanner = Color(red: 0.941, green: 0.937, blue: 0.918)   // #F0EFEA
        static let destructive = Color(red: 0.761, green: 0.443, blue: 0.42)       // #C2716B 柔和红
        static let accentLight = Color(red: 0.49, green: 0.569, blue: 0.447).opacity(0.07)
        static let accentMid = Color(red: 0.49, green: 0.569, blue: 0.447).opacity(0.14)
    }

    // MARK: - 字号
    enum FontSize {
        static let largeTitle: CGFloat = 26
        static let title: CGFloat = 19
        static let headline: CGFloat = 16
        static let body: CGFloat = 14
        static let caption: CGFloat = 12
        static let footnote: CGFloat = 10
    }

    // MARK: - 间距（加大留白）
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 10
        static let md: CGFloat = 20
        static let lg: CGFloat = 32
        static let xl: CGFloat = 44
    }

    // MARK: - 圆角
    enum CornerRadius {
        static let small: CGFloat = 6
        static let medium: CGFloat = 10
        static let large: CGFloat = 14
        static let card: CGFloat = 16
        static let capsule: CGFloat = 20
    }

    // MARK: - 阴影（极淡）
    enum Shadow {
        static let light: CGFloat = 1
        static let medium: CGFloat = 3
        static let heavy: CGFloat = 6
    }

    // MARK: - 动画
    enum Animation {
        static let springResponse: Double = 0.5
        static let springDamping: Double = 0.7
        static let standard = SwiftUI.Animation.spring(response: springResponse, dampingFraction: springDamping)
        static let quick = SwiftUI.Animation.spring(response: 0.35, dampingFraction: 0.8)
    }

    // MARK: - 字体
    enum Fonts {
        static func serif(_ size: CGFloat, weight: Font.Weight = .light) -> Font {
            .system(size: size, weight: weight, design: .serif)
        }
        static func sans(_ size: CGFloat, weight: Font.Weight = .light) -> Font {
            .system(size: size, weight: weight, design: .default)
        }
    }
}
