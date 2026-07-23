import SwiftUI

/// 首页 — 双列瀑布流 + 分类筛选 tab + 内嵌搜索
struct CollectionView: View {
    @Environment(DatabaseManager.self) private var database
    @Environment(PhotoStorageManager.self) private var storage
    @State private var selectedCategory: CategoryType?
    @State private var showSidebar = false
    @State private var searchQuery = ""
    @State private var isSearching = false

    var body: some View {
        ZStack {
            NavigationStack {
                VStack(spacing: 0) {
                    if isSearching {
                        searchBar
                    }

                    CategoryFilterBar(selectedCategory: $selectedCategory)

                    contentArea
                }
                .navigationTitle("Capture:D")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: { withAnimation { showSidebar = true } }) {
                            Image(systemName: "line.3.horizontal")
                                .font(.system(size: AppTheme.FontSize.headline, weight: .light))
                                .foregroundStyle(AppTheme.Colors.accent)
                                .opacity(0.7)
                        }
                    }
                    ToolbarItem(placement: .principal) {
                        Button(action: {
                            withAnimation(AppTheme.Animation.standard) {
                                selectedCategory = nil
                                searchQuery = ""
                                isSearching = false
                            }
                        }) {
                            Text("Capture:D")
                                .font(AppTheme.Fonts.serif(AppTheme.FontSize.headline, weight: .light))
                                .tracking(1.0)
                                .foregroundStyle(AppTheme.Colors.primaryText)
                        }
                        .buttonStyle(.plain)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            withAnimation(AppTheme.Animation.standard) {
                                isSearching.toggle()
                                if !isSearching { searchQuery = "" }
                            }
                        }) {
                            Image(systemName: isSearching ? "xmark" : "magnifyingglass")
                                .font(.system(size: AppTheme.FontSize.headline, weight: .light))
                                .foregroundStyle(AppTheme.Colors.accent)
                                .opacity(0.7)
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape")
                                .font(.system(size: AppTheme.FontSize.headline, weight: .light))
                                .foregroundStyle(AppTheme.Colors.accent)
                                .opacity(0.7)
                        }
                    }
                }
            }

            if showSidebar {
                SidebarView(isPresented: $showSidebar)
                    .ignoresSafeArea()
                    .zIndex(10)
            }
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .light))
                .foregroundStyle(AppTheme.Colors.tertiaryText)

            TextField("搜索文件名或标签", text: $searchQuery)
                .font(AppTheme.Fonts.serif(AppTheme.FontSize.body, weight: .light))
                .textFieldStyle(.plain)
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(AppTheme.Colors.cardBackground)
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    @ViewBuilder
    private var contentArea: some View {
        let hasSearch = !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty

        if let category = selectedCategory {
            if category == .murmur && !hasSearch {
                MurmurTimelineView()
            } else if hasSearch {
                let files = database.search(query: searchQuery, category: category)
                filteredResultView(files)
            } else {
                filteredCategoryView(category)
            }
        } else if hasSearch {
            let files = database.search(query: searchQuery)
            filteredResultView(files)
        } else {
            allFilesView
        }
    }

    private func filteredResultView(_ files: [CollectionFile]) -> some View {
        Group {
            if files.isEmpty {
                VStack(spacing: AppTheme.Spacing.md) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 36, weight: .thin))
                        .foregroundStyle(AppTheme.Colors.tertiaryText)
                        .opacity(0.35)
                    Text("没有找到相关内容")
                        .font(AppTheme.Fonts.serif(AppTheme.FontSize.body, weight: .light))
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                fileGrid(files)
            }
        }
    }

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
        .padding(.horizontal, AppTheme.Spacing.xs)
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
                if !file.tags.isEmpty {
                    TagFlowView(tags: file.tags, limit: 2)
                        .padding(.bottom, 2)
                }

                if file.category == .murmur {
                    Text(file.createdAt.timelineBrief)
                        .font(AppTheme.Fonts.sans(AppTheme.FontSize.footnote, weight: .light))
                        .tracking(0.4)
                        .foregroundStyle(AppTheme.Colors.tertiaryText)
                        .padding(.bottom, 1)

                    Text(file.title)
                        .font(AppTheme.Fonts.serif(AppTheme.FontSize.caption, weight: .regular))
                        .foregroundStyle(AppTheme.Colors.primaryText)
                        .lineLimit(3)
                } else {
                    Text(file.title)
                        .font(AppTheme.Fonts.serif(AppTheme.FontSize.caption, weight: .regular))
                        .foregroundStyle(AppTheme.Colors.primaryText)
                        .lineLimit(2)

                    Text(file.category.rawValue)
                        .font(AppTheme.Fonts.sans(AppTheme.FontSize.footnote, weight: .light))
                        .tracking(0.6)
                        .foregroundStyle(AppTheme.Colors.tertiaryText)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.sm)
            .padding(.bottom, AppTheme.Spacing.sm)
        }
        .waterfallCardStyle()
    }
}
