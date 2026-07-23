import Foundation

/// 豆包（字节跳动）API 适配器
final class DoubaoService: OpenAICompatibleService {
    init() {
        super.init(
            providerID: "doubao",
            displayName: "豆包",
            model: "doubao-vision-pro-32k",
            baseURL: URL(string: "https://ark.cn-beijing.volces.com/api/v3/chat/completions")!
        )
    }
}
