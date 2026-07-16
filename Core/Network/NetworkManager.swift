import Foundation

/// 网络请求管理器
final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}

    /// 发送 AI 分析请求
    func sendAIRequest(
        url: URL,
        headers: [String: String],
        body: Data,
        timeout: TimeInterval = 60
    ) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        request.timeoutInterval = timeout
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
        }

        return data
    }
}

enum NetworkError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int, data: Data)
    case noNetwork

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "服务器响应异常"
        case .httpError(let code, _):
            switch code {
            case 401: return "API Key 无效，请检查设置"
            case 429: return "请求过于频繁，请稍后再试"
            case 500...599: return "AI 服务暂时不可用"
            default: return "网络错误（\(code)）"
            }
        case .noNetwork:
            return "网络连接不可用"
        }
    }
}
