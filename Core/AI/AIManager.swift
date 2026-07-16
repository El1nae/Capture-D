import Foundation
import SwiftUI

/// AI 错误类型
enum AIError: LocalizedError {
    case noAPIKey
    case invalidResponse
    case budgetExceeded
    case analysisFailedForCategory(CategoryType)

    var errorDescription: String? {
        switch self {
        case .noAPIKey: return "未配置 API Key，请在设置中填写"
        case .invalidResponse: return "AI 返回格式异常"
        case .budgetExceeded: return "本月分析次数已达上限"
        case .analysisFailedForCategory(let cat): return "\(cat.rawValue)分析失败"
        }
    }
}

/// AI 响应解析器
enum AIResponseParser {
    /// 从 AI 返回的文本中解析结果
    static func parse(_ text: String, categories: [CategoryType]) -> [CategoryType: AIAnalysisResult] {
        var results: [CategoryType: AIAnalysisResult] = [:]

        // 尝试解析 JSON 格式
        if let jsonData = extractJSON(from: text),
           let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
           let items = json["results"] as? [[String: Any]] {
            for item in items {
                guard let categoryName = item["category"] as? String,
                      let sourceName = item["sourceName"] as? String,
                      let content = item["content"] as? String,
                      let category = CategoryType(rawValue: categoryName) else { continue }
                if categories.contains(category) && AppConstants.isValidFileName(sourceName) {
                    results[category] = AIAnalysisResult(sourceName: sourceName, content: content)
                }
            }
        }

        return results
    }

    /// 从文本中提取 JSON 部分（AI 可能在 JSON 前后加说明文字）
    private static func extractJSON(from text: String) -> Data? {
        guard let start = text.firstIndex(of: "{"),
              let end = text.lastIndex(of: "}") else { return nil }
        let jsonString = String(text[start...end])
        return jsonString.data(using: .utf8)
    }
}

/// AI 管理器 — 队列化调用、费用计数、平台切换
@MainActor
@Observable
final class AIManager {
    private let keychain = KeychainManager()
    private var isProcessing = false

    /// 当前选择的 AI 平台
    var currentProvider: String {
        get { UserDefaults.standard.string(forKey: "ai_provider") ?? "deepseek" }
        set { UserDefaults.standard.set(newValue, forKey: "ai_provider") }
    }

    /// 本月已分析次数
    var monthlyAnalysisCount: Int {
        get { UserDefaults.standard.integer(forKey: monthlyCountKey) }
        set { UserDefaults.standard.set(newValue, forKey: monthlyCountKey) }
    }

    /// 月度分析上限（0 = 不限制）
    var monthlyLimit: Int {
        get { UserDefaults.standard.integer(forKey: "ai_monthly_limit") }
        set { UserDefaults.standard.set(newValue, forKey: "ai_monthly_limit") }
    }

    /// 是否正在分析中
    var analyzing: Bool { isProcessing }

    /// 所有可用的 AI 服务
    let availableServices: [AIServiceProtocol] = [
        DeepSeekService(),
        DoubaoService(),
        ClaudeService()
    ]

    /// 当前服务
    var currentService: AIServiceProtocol {
        availableServices.first { $0.providerID == currentProvider } ?? availableServices[0]
    }

    /// 是否超过月度上限
    var isBudgetExceeded: Bool {
        monthlyLimit > 0 && monthlyAnalysisCount >= monthlyLimit
    }

    /// 分析单张图片（跨分类一次调用）
    func analyzeImage(
        imageData: Data,
        categories: [CategoryType],
        database: DatabaseManager,
        imageRecord: ImageRecord,
        files: [CollectionFile]
    ) async throws {
        guard !isBudgetExceeded else { throw AIError.budgetExceeded }
        guard let apiKey = keychain.load(for: currentProvider) else { throw AIError.noAPIKey }

        isProcessing = true
        defer { isProcessing = false }

        let results = try await currentService.analyze(imageData: imageData, categories: categories, apiKey: apiKey)

        monthlyAnalysisCount += 1

        for file in files {
            if let result = results[file.category] {
                database.promoteFile(file, newTitle: result.sourceName, content: result.content)
            }
            // 格式不合规或该分类没有结果 → 留在未整理
        }
    }

    /// 本月计数 key（按年月）
    private var monthlyCountKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return "ai_count_\(formatter.string(from: Date()))"
    }

    /// 估算费用（基于历史调用次数和平台）
    var estimatedCost: String {
        let count = monthlyAnalysisCount
        let costPerCall: Double
        switch currentProvider {
        case "claude": costPerCall = 0.10
        case "deepseek": costPerCall = 0.02
        case "doubao": costPerCall = 0.03
        default: costPerCall = 0.05
        }
        let total = Double(count) * costPerCall
        return String(format: "约 ¥%.2f", total)
    }
}
