import Foundation

/// 五大分类类型
enum CategoryType: String, CaseIterable, Identifiable, Codable {
    case literature = "找书"
    case poetry = "找诗"
    case paint = "找画"
    case lyrics = "找歌"
    case murmur = "碎碎念"

    var id: String { rawValue }

    /// 分类的显示图标（SF Symbol）
    var iconName: String {
        switch self {
        case .literature: return "book.fill"
        case .poetry: return "scroll.fill"
        case .paint: return "paintpalette.fill"
        case .lyrics: return "music.note"
        case .murmur: return "bubble.left.fill"
        }
    }

    /// 可通过 Share Extension 分享的分类（碎碎念不支持）
    static var shareableCategories: [CategoryType] {
        allCases.filter { $0 != .murmur }
    }
}
