import SwiftUI

/// 导出备份页面
struct ExportView: View {
    @Environment(DatabaseManager.self) private var database
    @Environment(PhotoStorageManager.self) private var storage
    @State private var isExporting = false
    @State private var exportError: String?
    @State private var exportSuccess = false

    private var fileCount: Int {
        database.allSortedFiles().count + database.murmurFiles().count
    }

    var body: some View {
        List {
            Section {
                statRow(icon: "doc.text", title: "文件数量", value: "\(fileCount)")
            } header: {
                Text("数据概览")
                    .font(AppTheme.Fonts.sans(AppTheme.FontSize.footnote, weight: .regular))
                    .tracking(1.5)
            }

            Section {
                Button(action: performExport) {
                    HStack {
                        if isExporting {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        Text(isExporting ? "导出中..." : "导出完整备份")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(isExporting)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
            } footer: {
                Text("导出所有文件、图片和标签为 ZIP 压缩包")
                    .font(AppTheme.Fonts.sans(AppTheme.FontSize.footnote, weight: .light))
            }

            if let error = exportError {
                Section {
                    Text(error)
                        .font(AppTheme.Fonts.sans(AppTheme.FontSize.caption, weight: .light))
                        .foregroundStyle(AppTheme.Colors.destructive)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("导出备份")
        .navigationBarTitleDisplayMode(.inline)
        .alert("导出成功", isPresented: $exportSuccess) {
            Button("好") { }
        } message: {
            Text("备份文件已准备好，请选择保存位置")
        }
    }

    private func statRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .light))
                .foregroundStyle(AppTheme.Colors.accent)
                .frame(width: 24)
            Text(title)
                .font(AppTheme.Fonts.serif(AppTheme.FontSize.body, weight: .light))
                .foregroundStyle(AppTheme.Colors.primaryText)
            Spacer()
            Text(value)
                .font(AppTheme.Fonts.sans(AppTheme.FontSize.body, weight: .light))
                .foregroundStyle(AppTheme.Colors.secondaryText)
        }
    }

    private func performExport() {
        isExporting = true
        exportError = nil

        Task {
            do {
                let manager = ExportManager(database: database, storage: storage)
                let zipURL = try manager.exportAll()

                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let rootVC = windowScene.windows.first?.rootViewController else { return }

                manager.share(zipURL: zipURL, from: rootVC)
                exportSuccess = true
            } catch {
                exportError = "导出失败：\(error.localizedDescription)"
            }
            isExporting = false
        }
    }
}
