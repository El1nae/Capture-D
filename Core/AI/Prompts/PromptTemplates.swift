import Foundation

/// 各分类的 AI 提示词模板
enum PromptTemplates {
    /// 生成完整 Prompt（一次调用覆盖所有选中分类）
    static func buildPrompt(categories: [CategoryType]) -> String {
        var prompt = """
        你是一个图片内容识别助手。请分析这张图片，按以下要求返回结果。

        重要格式要求：
        - 出处名必须使用"作品名|作者"格式，用竖线|分隔
        - 禁止使用书名号《》
        - 只返回纯文本，不要使用 Markdown 格式
        - 如果无法识别出处，出处名写"未知"

        请按以下 JSON 格式返回（不要添加其他内容）：
        {
          "results": [
            {
              "category": "分类名",
              "sourceName": "作品名|作者",
              "content": "分析内容"
            }
          ]
        }

        需要分析的分类：
        """

        for category in categories {
            prompt += "\n\n--- \(category.rawValue) ---\n"
            prompt += categoryPrompt(for: category)
        }

        return prompt
    }

    private static func categoryPrompt(for category: CategoryType) -> String {
        switch category {
        case .novel:
            return """
            如果这是小说相关截图：
            - 出处名格式：小说名|作者名
            - 内容：作品简介、作者信息
            - 如果截图包含多部作品（书单），出处名写"日期+书单"，内容只列书名
            - 如果能找到官网链接，附在内容末尾
            """

        case .poetry:
            return """
            如果这是诗词相关截图：
            - 出处名格式：诗词名|作者名
            - 内容：完整的诗词原文（全文，不要节选）
            """

        case .artStyle:
            return """
            如果这是画风/插画相关截图：
            - 如能识别作品：出处名格式为 作品名|作者名
            - 如能识别画师：出处名格式为 画师名|平台名
            - 如都不能识别：出处名写"未知"
            - 内容：描述画面色彩运用、线条特征、风格分析
            - 如截图中可见平台和发布者信息，默认该发布者为原画师
            """

        case .music:
            return """
            如果这是歌曲相关截图：
            - 出处名格式：歌名|歌手名
            - 内容：完整歌词（全部歌词，不要节选）
            - 如果截图包含多首歌（歌单），出处名写"日期+歌单"，内容只列歌名
            """
        }
    }
}
