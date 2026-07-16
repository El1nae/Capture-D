import Foundation

/// 四大分类类型
enum CategoryType: String, CaseIterable, Identifiable, Codable {
    case novel = "小说"
    case poetry = "诗词"
    case artStyle = "画风"
    case music = "歌曲"

    var id: String { rawValue }

    /// 分类的显示图标（SF Symbol）
    var iconName: String {
        switch self {
        case .novel: return "book.fill"
        case .poetry: return "scroll.fill"
        case .artStyle: return "paintpalette.fill"
        case .music: return "music.note"
        }
    }
}
