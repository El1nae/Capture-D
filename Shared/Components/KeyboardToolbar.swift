import SwiftUI

/// 键盘上方工具栏 — 撤回 / 重做 / 收起键盘
struct KeyboardToolbar: ToolbarContent {
    @Environment(\.undoManager) private var undoManager

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Button(action: { undoManager?.undo() }) {
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 16, weight: .light))
                    .foregroundStyle(
                        undoManager?.canUndo == true
                            ? AppTheme.Colors.accent
                            : AppTheme.Colors.tertiaryText
                    )
            }
            .disabled(undoManager?.canUndo != true)

            Button(action: { undoManager?.redo() }) {
                Image(systemName: "arrow.uturn.forward")
                    .font(.system(size: 16, weight: .light))
                    .foregroundStyle(
                        undoManager?.canRedo == true
                            ? AppTheme.Colors.accent
                            : AppTheme.Colors.tertiaryText
                    )
            }
            .disabled(undoManager?.canRedo != true)

            Spacer()

            Button(action: {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }) {
                Image(systemName: "keyboard.chevron.compact.down")
                    .font(.system(size: 16, weight: .light))
                    .foregroundStyle(AppTheme.Colors.accent)
            }
        }
    }
}
