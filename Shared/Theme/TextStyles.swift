import SwiftUI

/// 文字样式统一定义
enum TextStyles {
    /// AI 生成的注释 — 淡灰小字，像手写备注
    struct AIAnnotation: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.system(size: AppTheme.FontSize.caption))
                .foregroundStyle(AppTheme.Colors.tertiaryText)
        }
    }

    /// 文件标题
    struct FileTitle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.system(size: AppTheme.FontSize.headline, weight: .medium))
                .foregroundStyle(AppTheme.Colors.primaryText)
        }
    }

    /// 正文内容
    struct BodyText: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.system(size: AppTheme.FontSize.body))
                .foregroundStyle(AppTheme.Colors.primaryText)
                .lineSpacing(4)
        }
    }

    /// 时间标注
    struct TimeLabel: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.system(size: AppTheme.FontSize.footnote))
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
