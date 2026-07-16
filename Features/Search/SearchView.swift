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
                            .font(.system(size: 36))
                            .foregroundStyle(AppTheme.Colors.tertiaryText)
                        Text("搜索收藏内容")
                            .foregroundStyle(AppTheme.Colors.secondaryText)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if results.isEmpty {
                    Text("没有找到相关内容")
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(results, id: \.persistentModelID) { file in
                        NavigationLink(destination: FileDetailView(file: file)) {
                            HStack {
                                Image(systemName: file.category.iconName)
                                    .foregroundStyle(AppTheme.Colors.accent)
                                VStack(alignment: .leading) {
                                    Text(file.title)
                                        .font(.system(size: AppTheme.FontSize.body, weight: .medium))
                                    Text(file.category.rawValue)
                                        .font(.system(size: AppTheme.FontSize.caption))
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
                }
            }
        }
    }
}
