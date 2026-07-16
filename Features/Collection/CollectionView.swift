import SwiftUI

/// 首页 — 双列瀑布流 + 分类筛选 tab
struct CollectionView: View {
    @Environment(DatabaseManager.self) private var database
    @Environment(PhotoStorageManager.self) private var storage
    @State private var selectedCategory: CategoryType?
    @State private var showSearch = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                CategoryFilterBar(selectedCategory: $selectedCategory)

                if let category = selectedCategory {
                    filteredCategoryView(category)
                } else {
                    allFilesView
                }
            }
            .navigationTitle("Capture:D")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showSearch = true }) {
                        Image(systemName: "magnifyingglass")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showSearch) {
                SearchView()
            }
        }
    }

    /// 混合所有分类的瀑布流
    private var allFilesView: some View {
        let files = database.allSortedFiles()
        return Group {
            if files.isEmpty {
                EmptyStateView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                fileGrid(files)
            }
        }
    }

    /// 某个分类下的瀑布流 + 未整理白条
    private func filteredCategoryView(_ category: CategoryType) -> some View {
        let files = database.sortedFiles(for: category)
        let unsortedCount = database.unsortedCount(for: category)

        return VStack(spacing: 0) {
            if unsortedCount > 0 {
                UnsortedBanner(category: category, count: unsortedCount)
            }

            if files.isEmpty && unsortedCount == 0 {
                EmptyStateView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                fileGrid(files)
            }
        }
    }

    private func fileGrid(_ files: [CollectionFile]) -> some View {
        WaterfallGrid(data: files) { file in
            NavigationLink(destination: FileDetailView(file: file)) {
                fileCard(file)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, AppTheme.Spacing.sm)
    }

    private func fileCard(_ file: CollectionFile) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            if let firstImage = file.images.first,
               let thumbData = storage.loadThumbnail(id: firstImage.imageID),
               let uiImage = UIImage(data: thumbData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 120, maxHeight: 200)
                    .clipped()
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(file.title)
                    .font(.system(size: AppTheme.FontSize.caption, weight: .medium))
                    .foregroundStyle(AppTheme.Colors.primaryText)
                    .lineLimit(2)

                Text(file.category.rawValue)
                    .font(.system(size: AppTheme.FontSize.footnote))
                    .foregroundStyle(AppTheme.Colors.tertiaryText)
            }
            .padding(.horizontal, AppTheme.Spacing.sm)
            .padding(.bottom, AppTheme.Spacing.sm)
        }
        .waterfallCardStyle()
    }
}
