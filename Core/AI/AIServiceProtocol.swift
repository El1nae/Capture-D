import Foundation

/// AI 分析结果
struct AIAnalysisResult {
    /// 出处名（格式：作品名|作者）
    let sourceName: String
    /// 分析内容（纯文本）
    let content: String
}

/// AI 服务统一接口 — 每个 AI 平台实现此协议
protocol AIServiceProtocol {
    /// 平台标识（用于 Keychain 存取）
    var providerID: String { get }
    /// 显示名称
    var displayName: String { get }
    /// 分析图片
    func analyze(imageData: Data, categories: [CategoryType], apiKey: String) async throws -> [CategoryType: AIAnalysisResult]
}
