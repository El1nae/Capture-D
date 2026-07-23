import Foundation

/// DeepSeek API 适配器
final class DeepSeekService: OpenAICompatibleService {
    init() {
        super.init(
            providerID: "deepseek",
            displayName: "DeepSeek",
            model: "deepseek-chat",
            baseURL: URL(string: "https://api.deepseek.com/chat/completions")!
        )
    }
}
