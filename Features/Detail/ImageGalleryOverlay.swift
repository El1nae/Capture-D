import SwiftUI

/// 左滑图片浮层 — 含跨分类金色光晕和 tag 跳转
struct ImageGalleryOverlay: View {
    let file: CollectionFile
    @Binding var isPresented: Bool
    @Environment(DatabaseManager.self) private var database
    @Environment(PhotoStorageManager.self) private var storage
    @State private var currentPage = 0
    @State private var showCrossTags = false
    @State private var crossFiles: [CollectionFile] = []
    @State private var selectedImage: ImageRecord?

    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(AppTheme.Animation.standard) {
                        isPresented = false
                    }
                }

            VStack {
                TabView(selection: $currentPage) {
                    ForEach(Array(file.images.enumerated()), id: \.element.imageID) { index, image in
                        imageCard(image: image)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(height: UIScreen.main.bounds.height * 0.6)
                .padding(.horizontal, AppTheme.Spacing.lg)
            }

            // 跨分类 tag 弹出
            if showCrossTags, let image = selectedImage {
                crossCategoryTags(for: image)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    if value.translation.width > 50 {
                        withAnimation(AppTheme.Animation.standard) {
                            isPresented = false
                        }
                    }
                }
        )
    }

    private func imageCard(image: ImageRecord) -> some View {
        let hasCrossRef = database.crossCategoryFiles(for: image, excluding: file).count > 0

        return VStack(spacing: AppTheme.Spacing.xs) {
            if let data = storage.loadImage(id: image.imageID) {
                FloatingImageCard(
                    imageData: data,
                    capturedAt: image.capturedAt,
                    showGoldGlow: hasCrossRef,
                    onLongPress: {
                        selectedImage = image
                        crossFiles = database.crossCategoryFiles(for: image, excluding: file)
                        if !crossFiles.isEmpty {
                            withAnimation(AppTheme.Animation.standard) {
                                showCrossTags = true
                            }
                        }
                    }
                )
            }
        }
        .floatingCardStyle()
    }

    private func crossCategoryTags(for image: ImageRecord) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            ForEach(crossFiles, id: \.persistentModelID) { crossFile in
                NavigationLink(destination: FileDetailView(file: crossFile)) {
                    HStack(spacing: 5) {
                        Image(systemName: crossFile.category.iconName)
                            .font(.system(size: AppTheme.FontSize.caption, weight: .light))
                        Text(crossFile.category.rawValue)
                        Text("·")
                        Text(crossFile.title)
                            .lineLimit(1)
                    }
                    .font(AppTheme.Fonts.serif(AppTheme.FontSize.caption, weight: .light))
                    .tracking(0.5)
                    .foregroundStyle(AppTheme.Colors.accent)
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.vertical, 7)
                    .background(AppTheme.Colors.accentLight)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(AppTheme.Colors.accentMid, lineWidth: 0.5)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(AppTheme.Spacing.md)
        .transition(.move(edge: .leading))
        .onTapGesture {
            withAnimation { showCrossTags = false }
        }
    }
}
