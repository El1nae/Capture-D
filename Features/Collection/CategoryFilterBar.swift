import SwiftUI

/// 分类筛选 tab 栏 — 带 Safari 弹性动画
struct CategoryFilterBar: View {
    @Binding var selectedCategory: CategoryType?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.sm) {
                ForEach(CategoryType.allCases) { category in
                    Button(action: { toggleCategory(category) }) {
                        HStack(spacing: 4) {
                            Image(systemName: category.iconName)
                                .font(.system(size: 12, weight: .light))
                            Text(category.rawValue)
                                .tracking(0.5)
                        }
                    }
                    .buttonStyle(CategoryButtonStyle(isSelected: selectedCategory == category))
                    .scaleEffect(selectedCategory == category ? 1.05 : 1.0)
                    .animation(AppTheme.Animation.standard, value: selectedCategory)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
        }
        .background(AppTheme.Colors.background)
    }

    private func toggleCategory(_ category: CategoryType) {
        withAnimation(AppTheme.Animation.standard) {
            if selectedCategory == category {
                selectedCategory = nil
            } else {
                selectedCategory = category
            }
        }
    }
}
