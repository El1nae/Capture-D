import SwiftUI

/// 文字样式 — 日系极简：宋体标题 + 细黑体正文
enum TextStyles {
    /// AI 生成的注释 — 淡灰小字
    struct AIAnnotation: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(AppTheme.Fonts.sans(AppTheme.FontSize.caption, weight: .light))
                .foregroundStyle(AppTheme.Colors.tertiaryText)
        }
    }

    /// 文件标题 — 宋体衬线
    struct FileTitle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(AppTheme.Fonts.serif(AppTheme.FontSize.headline, weight: .regular))
                .tracking(0.5)
                .foregroundStyle(AppTheme.Colors.primaryText)
        }
    }

    /// 正文内容 — 纤细宋体
    struct BodyText: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(AppTheme.Fonts.serif(AppTheme.FontSize.body, weight: .light))
                .foregroundStyle(AppTheme.Colors.primaryText)
                .lineSpacing(6)
        }
    }

    /// 时间标注 — 无衬线小字
    struct TimeLabel: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(AppTheme.Fonts.sans(AppTheme.FontSize.footnote, weight: .light))
                .tracking(0.6)
                .foregroundStyle(AppTheme.Colors.tertiaryText)
        }
    }
}

extension View {
    func aiAnnotationStyle() -> some View { modifier(TextStyles.AIAnnotation()) }
    func fileTitleStyle() -> some View { modifier(TextStyles.FileTitle()) }
    func bodyTextStyle() -> some View { modifier(TextStyles.BodyText()) }
    func timeLabelStyle() -> some View { modifier(TextStyles.TimeLabel()) }
}
