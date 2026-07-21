import SwiftUI

/// 左侧边栏 — 宽度 75% 屏幕，含热力图和关键词云图
struct SidebarView: View {
    @Binding var isPresented: Bool
    @Environment(DatabaseManager.self) private var database

    private var dailyCounts: [Date: Int] {
        ActivityTracker.dailyCounts(database: database)
    }

    private var keywords: [(word: String, count: Int)] {
        KeywordAnalyzer.analyze(database: database, topN: 30)
    }

    var body: some View {
        ZStack(alignment: .leading) {
            Color.black.opacity(isPresented ? 0.3 : 0)
                .ignoresSafeArea()
                .onTapGesture { close() }
                .animation(.easeOut(duration: 0.25), value: isPresented)

            HStack(spacing: 0) {
                sidebar
                Spacer()
            }
            .offset(x: isPresented ? 0 : -UIScreen.main.bounds.width * 0.75)
            .animation(AppTheme.Animation.standard, value: isPresented)
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width < -50 { close() }
                }
        )
    }

    private var sidebar: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                // App logo
                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 24, weight: .light))
                        .foregroundStyle(AppTheme.Colors.accent)
                    Text("Capture:D")
                        .font(AppTheme.Fonts.serif(AppTheme.FontSize.title, weight: .regular))
                        .foregroundStyle(AppTheme.Colors.primaryText)
                        .tracking(1.0)
                }
                .padding(.top, AppTheme.Spacing.xl)

                Divider().foregroundStyle(AppTheme.Colors.separator)

                HeatmapView(dailyCounts: dailyCounts)

                Divider().foregroundStyle(AppTheme.Colors.separator)

                KeywordCloudView(keywords: keywords)

                Spacer()
            }
            .padding(.horizontal, AppTheme.Spacing.md)
        }
        .frame(width: UIScreen.main.bounds.width * 0.75)
        .background(AppTheme.Colors.background)
    }

    private func close() {
        withAnimation { isPresented = false }
    }
}
