import SwiftUI

/// 横向流式 Tag 布局，超出 limit 时显示 +N
struct TagFlowView: View {
    let tags: [String]
    var limit: Int = 0
    var onRemove: ((String) -> Void)?

    private var visibleTags: [String] {
        guard limit > 0, tags.count > limit else { return tags }
        return Array(tags.prefix(limit))
    }

    private var overflowCount: Int {
        guard limit > 0 else { return 0 }
        return max(0, tags.count - limit)
    }

    var body: some View {
        if tags.isEmpty { EmptyView() }
        else {
            FlowLayout(spacing: 6) {
                ForEach(visibleTags, id: \.self) { tag in
                    TagChip(text: tag, onRemove: onRemove != nil ? { onRemove?(tag) } : nil)
                }
                if overflowCount > 0 {
                    Text("+\(overflowCount)")
                        .font(AppTheme.Fonts.sans(AppTheme.FontSize.footnote, weight: .light))
                        .foregroundStyle(AppTheme.Colors.tertiaryText)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                }
            }
        }
    }
}

/// 简单的横向自动换行布局
struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            totalHeight = y + rowHeight
        }

        return (CGSize(width: maxWidth, height: totalHeight), positions)
    }
}
