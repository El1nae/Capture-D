import Foundation

/// Claude API 适配器
final class ClaudeService: AIServiceProtocol {
    let providerID = "claude"
    let displayName = "Claude"

    func analyze(imageData: Data, categories: [CategoryType], apiKey: String) async throws -> [CategoryType: AIAnalysisResult] {
        let base64Image = imageData.base64EncodedString()
        let prompt = PromptTemplates.buildPrompt(categories: categories)

        let requestBody: [String: Any] = [
            "model": "claude-sonnet-4-20250514",
            "max_tokens": 4096,
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "image",
                            "source": [
                                "type": "base64",
                                "media_type": "image/jpeg",
                                "data": base64Image
                            ]
                        ],
                        [
                            "type": "text",
                            "text": prompt
                        ]
                    ]
                ]
            ]
        ]

        let body = try JSONSerialization.data(withJSONObject: requestBody)
        let url = URL(string: "https://api.anthropic.com/v1/messages")!
        let headers = [
            "x-api-key": apiKey,
            "anthropic-version": "2023-06-01"
        ]

        let responseData = try await NetworkManager.shared.sendAIRequest(url: url, headers: headers, body: body)
        return try parseResponse(responseData, categories: categories)
    }

    private func parseResponse(_ data: Data, categories: [CategoryType]) throws -> [CategoryType: AIAnalysisResult] {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let textBlock = content.first(where: { $0["type"] as? String == "text" }),
              let text = textBlock["text"] as? String else {
            throw AIError.invalidResponse
        }
        return AIResponseParser.parse(text, categories: categories)
    }
}
