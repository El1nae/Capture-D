import Foundation
import NaturalLanguage

/// 关键词分析器 — 中文分词 + 词频统计
enum KeywordAnalyzer {
    private static let stopWords: Set<String> = [
        "的", "了", "在", "是", "我", "有", "和", "就", "不", "人",
        "都", "一", "一个", "上", "也", "很", "到", "说", "要", "去",
        "你", "会", "着", "没有", "看", "好", "自己", "这", "他", "她",
        "吗", "什么", "这个", "那个", "可以", "但", "而", "还", "让",
        "被", "把", "从", "对", "能", "与", "或", "如果", "因为", "所以"
    ]

    /// 从所有内容中提取关键词及频率
    static func analyze(database: DatabaseManager, topN: Int = 50) -> [(word: String, count: Int)] {
        var allText = ""

        let files = database.allSortedFiles()
        for file in files {
            allText += " " + file.title
            allText += " " + file.tags.joined(separator: " ")
            for block in file.contentBlocks {
                allText += " " + block.text
            }
        }

        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = allText
        tokenizer.setLanguage(.simplifiedChinese)

        var counts: [String: Int] = [:]
        tokenizer.enumerateTokens(in: allText.startIndex..<allText.endIndex) { range, _ in
            let word = String(allText[range])
            if word.count >= 2, !stopWords.contains(word) {
                counts[word, default: 0] += 1
            }
            return true
        }

        return counts
            .sorted { $0.value > $1.value }
            .prefix(topN)
            .map { (word: $0.key, count: $0.value) }
    }
}
