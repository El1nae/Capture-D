import SwiftUI

/// 全局悬浮按钮 — 右下角 + 号，点击弹出碎碎念输入
struct FABButton: View {
    @Binding var showCompose: Bool

    var body: some View {
        Button(action: { showCompose = true }) {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 54, height: 54)
                .background(AppTheme.Colors.accent)
                .clipShape(Circle())
                .shadow(color: AppTheme.Colors.accent.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .scaleEffect(showCompose ? 0.9 : 1.0)
        .animation(AppTheme.Animation.quick, value: showCompose)
    }
}
