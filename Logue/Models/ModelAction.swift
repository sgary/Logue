import Foundation

// MARK: - ModelAction

/// Every logical AI action in the app. Used as the key for the centralized
/// action-to-model mapping in `ModelManager`.
///
/// Today every action resolves to the single active model, but this enum
/// lets us assign different models per action in the future by editing
/// the central map in one place.
enum ModelAction: String, CaseIterable, Codable, Identifiable {
    // Document analysis
    case grammarCheck
    case clarityCheck
    case toneDetect

    // Editor panels
    case chat
    case rephrase
    case generate
    case rewrite
    case vocabularyEnhancement

    // Verification panels
    case factCheck
    case plagiarismCheck
    case aiGrader
    case piiDetection
    case aiContentDetect
    case citationFinder
    case readerReactions

    /// Meeting
    case meetingSummary

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .grammarCheck: "语法检查"
        case .clarityCheck: "清晰度检查"
        case .toneDetect: "语气检测"
        case .chat: "AI 聊天"
        case .rephrase: "改写"
        case .generate: "生成"
        case .rewrite: "重写"
        case .vocabularyEnhancement: "词汇提升"
        case .factCheck: "事实核查"
        case .plagiarismCheck: "抄袭检测"
        case .aiGrader: "写作评分"
        case .piiDetection: "隐私扫描"
        case .aiContentDetect: "AI 内容检测"
        case .citationFinder: "引用查找"
        case .readerReactions: "读者反响"
        case .meetingSummary: "会议摘要"
        }
    }
}
