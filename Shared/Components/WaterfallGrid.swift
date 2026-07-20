import SwiftUI

/// 双列瀑布流布局
struct WaterfallGrid<Data: RandomAccessCollection, Content: View>: View where Data.Element: Identifiable {
    let data: Data
    let spacing: CGFloat
    let content: (Data.Element) -> Content

    init(
        data: Data,
        spacing: CGFloat = AppTheme.Spacing.sm,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            let columnWidth = (geometry.size.width - spacing) / 2

            ScrollView {
                HStack(alignment: .top, spacing: spacing) {
                    LazyVStack(spacing: spacing) {
                        ForEach(Array(data.enumerated()).filter { $0.offset % 2 == 0 }, id: \.element.id) { _, item in
                            content(item)
                                .frame(width: columnWidth)
                        }
                    }

                    LazyVStack(spacing: spacing) {
                        ForEach(Array(data.enumerated()).filter { $0.offset % 2 == 1 }, id: \.element.id) { _, item in
                            content(item)
                                .frame(width: columnWidth)
                        }
                    }
                }
                .padding(.horizontal, 14)
            }
        }
    }
}
