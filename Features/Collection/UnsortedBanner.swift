import SwiftUI

/// 未整理文件入口白条 — 固定在分类瀑布流顶部
struct UnsortedBanner: View {
    let category: CategoryType
    let count: Int

    var body: some View {
        NavigationLink(destination: UnsortedFilesView(category: category)) {
            HStack {
                Image(systemName: "tray.full")
                    .foregroundStyle(AppTheme.Colors.accent)
                Text("未整理文件")
                    .font(.system(size: AppTheme.FontSize.body, weight: .medium))
                    .foregroundStyle(AppTheme.Colors.primaryText)
                Spacer()
                Text("\(count)")
                    .font(.system(size: AppTheme.FontSize.body))
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundStyle(AppTheme.Colors.tertiaryText)
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(AppTheme.Colors.unsortedBanner)
        }
        .buttonStyle(.plain)
    }
}
