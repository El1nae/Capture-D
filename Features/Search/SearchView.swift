import SwiftUI

/// 全局搜索（只搜已整理文件）
struct SearchView: View {
    @Environment(DatabaseManager.self) private var database
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    private var results: [CollectionFile] {
        guard !query.isEmpty else { return [] }
        return database.search(query: query)
    }

    var body: some View {
        NavigationStack {
            VStack {
                if query.isEmpty {
                    VStack(spacing: AppTheme.Spacing.md) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 36, weight: .thin))
                            .foregroundStyle(AppTheme.Colors.tertiaryText)
                            .opacity(0.35)
                        Text("搜索收藏内容")
                            .font(AppTheme.Fonts.serif(AppTheme.FontSize.body, weight: .light))
                            .foregroundStyle(AppTheme.Colors.secondaryText)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if results.isEmpty {
                    Text("没有找到相关内容")
                        .font(AppTheme.Fonts.serif(AppTheme.FontSize.body, weight: .light))
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(results, id: \.persistentModelID) { file in
                        NavigationLink(destination: FileDetailView(file: file)) {
                            HStack {
                                Image(systemName: file.category.iconName)
                                    .font(.system(size: AppTheme.FontSize.body, weight: .light))
                                    .foregroundStyle(AppTheme.Colors.accent)
                                VStack(alignment: .leading) {
                                    Text(file.title)
                                        .font(AppTheme.Fonts.serif(AppTheme.FontSize.body, weight: .regular))
                                        .foregroundStyle(AppTheme.Colors.primaryText)
                                    Text(file.category.rawValue)
                                        .font(AppTheme.Fonts.sans(AppTheme.FontSize.caption, weight: .light))
                                        .foregroundStyle(AppTheme.Colors.tertiaryText)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .searchable(text: $query, prompt: "搜索文件名或内容")
            .navigationTitle("搜索")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("关闭") { dismiss() }
                        .font(AppTheme.Fonts.serif(AppTheme.FontSize.body, weight: .light))
                }
            }
        }
    }
}
