import Foundation

/// DeepSeek API 适配器
final class DeepSeekService: AIServiceProtocol {
    let providerID = "deepseek"
    let displayName = "DeepSeek"

    func analyze(imageData: Data, categories: [CategoryType], apiKey: String) async throws -> [CategoryType: AIAnalysisResult] {
        let base64Image = imageData.base64EncodedString()
        let prompt = PromptTemplates.buildPrompt(categories: categories)

        let requestBody: [String: Any] = [
            "model": "deepseek-chat",
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
        let url = URL(string: "https://api.deepseek.com/chat/completions")!
        let headers = ["Authorization": "Bearer \(apiKey)"]

        let responseData = try await NetworkManager.shared.sendAIRequest(url: url, headers: headers, body: body)
        return try parseOpenAIFormat(responseData, categories: categories)
    }

    private func parseOpenAIFormat(_ data: Data, categories: [CategoryType]) throws -> [CategoryType: AIAnalysisResult] {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let message = choices.first?["message"] as? [String: Any],
              let text = message["content"] as? String else {
            throw AIError.invalidResponse
        }
        return AIResponseParser.parse(text, categories: categories)
    }
}
