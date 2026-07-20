import SwiftUI

/// 未整理文件入口白条 — 固定在分类瀑布流顶部
struct UnsortedBanner: View {
    let category: CategoryType
    let count: Int

    var body: some View {
        NavigationLink(destination: UnsortedFilesView(category: category)) {
            HStack {
                Image(systemName: "tray.full")
                    .font(.system(size: AppTheme.FontSize.body, weight: .light))
                    .foregroundStyle(AppTheme.Colors.accent)
                    .opacity(0.7)
                Text("未整理文件")
                    .font(AppTheme.Fonts.serif(AppTheme.FontSize.body, weight: .regular))
                    .foregroundStyle(AppTheme.Colors.primaryText)
                Spacer()
                Text("\(count)")
                    .font(AppTheme.Fonts.sans(AppTheme.FontSize.body, weight: .light))
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .light))
                    .foregroundStyle(AppTheme.Colors.tertiaryText)
                    .opacity(0.6)
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(AppTheme.Colors.unsortedBanner)
        }
        .buttonStyle(.plain)
    }
}
