import Foundation

/// AI 分析结果
struct AIAnalysisResult {
    let sourceName: String
    let content: String
}

/// AI 服务统一接口
protocol AIServiceProtocol {
    var providerID: String { get }
    var displayName: String { get }
    func analyze(imageData: Data, categories: [CategoryType], apiKey: String) async throws -> [CategoryType: AIAnalysisResult]
}

/// OpenAI 兼容 API 的通用基类（DeepSeek、豆包等）
class OpenAICompatibleService: AIServiceProtocol {
    let providerID: String
    let displayName: String
    let model: String
    let baseURL: URL

    init(providerID: String, displayName: String, model: String, baseURL: URL) {
        self.providerID = providerID
        self.displayName = displayName
        self.model = model
        self.baseURL = baseURL
    }

    func analyze(imageData: Data, categories: [CategoryType], apiKey: String) async throws -> [CategoryType: AIAnalysisResult] {
        let base64Image = imageData.base64EncodedString()
        let prompt = PromptTemplates.buildPrompt(categories: categories)

        let requestBody: [String: Any] = [
            "model": model,
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "image_url",
                            "image_url": ["url": "data:image/jpeg;base64,\(base64Image)"]
                        ],
                        [
                            "type": "text",
                            "text": prompt
                        ]
                    ]
                ]
            ],
            "max_tokens": 4096
        ]

        let body = try JSONSerialization.data(withJSONObject: requestBody)
        let headers = ["Authorization": "Bearer \(apiKey)"]
        let responseData = try await NetworkManager.shared.sendAIRequest(url: baseURL, headers: headers, body: body)

        guard let json = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let message = choices.first?["message"] as? [String: Any],
              let text = message["content"] as? String else {
            throw AIError.invalidResponse
        }
        return AIResponseParser.parse(text, categories: categories)
    }
}
