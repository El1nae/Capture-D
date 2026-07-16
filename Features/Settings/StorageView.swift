import SwiftUI

/// 存储空间管理页面
struct StorageView: View {
    @Environment(PhotoStorageManager.self) private var storage

    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: "internaldrive")
                        .font(.system(size: 36))
                        .foregroundStyle(AppTheme.Colors.accent)

                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                        Text(storage.formattedStorageUsed())
                            .font(.system(size: AppTheme.FontSize.title, weight: .bold))
                        Text("已使用空间")
                            .font(.system(size: AppTheme.FontSize.caption))
                            .foregroundStyle(AppTheme.Colors.secondaryText)
                    }
                }
                .padding(.vertical, AppTheme.Spacing.sm)

                if storage.isStorageWarning {
                    Label("存储空间较大，建议清理不需要的收藏", systemImage: "exclamationmark.triangle")
                        .font(.system(size: AppTheme.FontSize.caption))
                        .foregroundStyle(.orange)
                }
            } header: {
                Text("存储概览")
            }

            Section {
                Text("图片以独立副本存储在 app 内，不占用系统相册空间。删除相册中的原图不影响 app 中的收藏。")
                    .font(.system(size: AppTheme.FontSize.caption))
                    .foregroundStyle(AppTheme.Colors.secondaryText)

                Text("可通过删除不需要的收藏文件来释放空间，删除的文件会先进入回收站，30 天后永久清除。")
                    .font(.system(size: AppTheme.FontSize.caption))
                    .foregroundStyle(AppTheme.Colors.secondaryText)
            } header: {
                Text("说明")
            }
        }
        .navigationTitle("存储空间")
        .navigationBarTitleDisplayMode(.inline)
    }
}
