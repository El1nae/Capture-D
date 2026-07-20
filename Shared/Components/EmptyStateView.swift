import SwiftUI

/// 首页空白时的引导提示
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 44))
                .foregroundStyle(AppTheme.Colors.tertiaryText)

            Text("还没有收藏")
                .font(AppTheme.Fonts.serif(AppTheme.FontSize.title, weight: .light))
                .tracking(0.8)
                .foregroundStyle(AppTheme.Colors.secondaryText)

            VStack(spacing: AppTheme.Spacing.sm) {
                Text("截屏或看到喜欢的图片时")
                Text("点击分享 → 选择 Capture:D → 选分类")
                Text("图片就会保存在这里")
            }
            .font(AppTheme.Fonts.sans(AppTheme.FontSize.body, weight: .light))
            .foregroundStyle(AppTheme.Colors.tertiaryText)
            .multilineTextAlignment(.center)

            Image(systemName: "arrow.down")
                .font(.system(size: 24))
                .foregroundStyle(AppTheme.Colors.tertiaryText)
                .padding(.top, AppTheme.Spacing.sm)
        }
        .padding(AppTheme.Spacing.xl)
    }
}
