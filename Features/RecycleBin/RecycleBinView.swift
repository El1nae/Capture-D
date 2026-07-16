import SwiftUI

/// 回收站
struct RecycleBinView: View {
    @Environment(DatabaseManager.self) private var database
    @Environment(PhotoStorageManager.self) private var storage
    @State private var showClearAlert = false

    private var files: [CollectionFile] {
        database.deletedFiles()
    }

    var body: some View {
        VStack {
            if files.isEmpty {
                VStack(spacing: AppTheme.Spacing.md) {
                    Image(systemName: "trash")
                        .font(.system(size: 48))
                        .foregroundStyle(AppTheme.Colors.tertiaryText)
                    Text("回收站是空的")
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(files, id: \.persistentModelID) { file in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(file.title)
                                    .font(.system(size: AppTheme.FontSize.body, weight: .medium))
                                HStack {
                                    Text(file.category.rawValue)
                                    if let deletedAt = file.deletedAt {
                                        let daysLeft = AppConstants.recycleBinRetentionDays - deletedAt.daysFromNow()
                                        Text("· \(max(daysLeft, 0)) 天后永久删除")
                                    }
                                }
                                .font(.system(size: AppTheme.FontSize.caption))
                                .foregroundStyle(AppTheme.Colors.tertiaryText)
                            }

                            Spacer()

                            Button("恢复") {
                                database.restore(file)
                            }
                            .font(.system(size: AppTheme.FontSize.caption))
                            .foregroundStyle(AppTheme.Colors.accent)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("回收站")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !files.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("清空", role: .destructive) { showClearAlert = true }
                        .foregroundStyle(AppTheme.Colors.destructive)
                }
            }
        }
        .alert("确定清空回收站？", isPresented: $showClearAlert) {
            Button("清空", role: .destructive) {
                for file in files {
                    database.permanentlyDelete(file, storage: storage)
                }
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("此操作不可撤销，所有内容将被永久删除")
        }
        .onAppear {
            database.cleanExpiredRecycleBin(storage: storage)
        }
    }
}
