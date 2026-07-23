import SwiftUI

/// 碎碎念时间线 — Threads 式紧凑单列布局，每条可点击进入详情
struct MurmurTimelineView: View {
    @Environment(DatabaseManager.self) private var database

    private var files: [CollectionFile] {
        database.murmurFiles()
    }

    var body: some View {
        if files.isEmpty {
            murmurEmptyState
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(files, id: \.persistentModelID) { file in
                        NavigationLink(destination: FileDetailView(file: file)) {
                            VStack(spacing: 0) {
                                TimelineSeparator(date: file.createdAt)
                                MurmurCard(file: file)
                                Divider()
                                    .padding(.leading, AppTheme.Spacing.md)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.bottom, 80)
            }
        }
    }

    private var murmurEmptyState: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "bubble.left")
                .font(.system(size: 44, weight: .thin))
                .foregroundStyle(AppTheme.Colors.tertiaryText)

            Text("还没有碎碎念")
                .font(AppTheme.Fonts.serif(AppTheme.FontSize.title, weight: .regular))
                .foregroundStyle(AppTheme.Colors.primaryText)
                .tracking(1.0)

            Text("点击右下角 + 号\n记录此刻的想法")
                .font(AppTheme.Fonts.serif(AppTheme.FontSize.body, weight: .light))
                .foregroundStyle(AppTheme.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
