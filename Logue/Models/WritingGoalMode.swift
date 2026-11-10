import Foundation

/// Writing goal that shapes the LLM's grammar and style analysis.
enum WritingGoalMode: String, CaseIterable, Codable, Sendable {
    case academic
    case business
    case casual
    case creative
    case technical

    var displayName: String {
        switch self {
        case .academic: "学术"
        case .business: "商务"
        case .casual: "随性"
        case .creative: "创意"
        case .technical: "技术"
        }
    }

    /// SF Symbol name for the goal mode card icon.
    var icon: String {
        switch self {
        case .academic: "graduationcap.fill"
        case .business: "briefcase.fill"
        case .casual: "bubble.left.fill"
        case .creative: "paintbrush.fill"
        case .technical: "terminal.fill"
        }
    }

    /// Short one-liner shown in the goals card.
    var shortDescription: String {
        switch self {
        case .academic: "论文、研究报告与正式写作"
        case .business: "邮件、报告与专业文档"
        case .casual: "聊天、博客与个人笔记"
        case .creative: "故事、诗歌与想象性写作"
        case .technical: "文档、代码注释与规格说明"
        }
    }

    /// Full description passed to the LLM system prompt.
    var systemDescription: String {
        switch self {
        case .academic:
            "formal academic writing — enforce grammar rules strictly, flag passive voice, prefer precise vocabulary"
        case .business:
            "professional business writing — clear, concise, direct; avoid jargon and filler words"
        case .casual:
            "everyday conversational writing — light touch, preserve voice, fix clear errors only"
        case .creative:
            "creative or narrative writing — minimal interference, fix spelling/punctuation only, preserve stylistic choices"
        case .technical:
            "technical documentation — precise terminology, imperative voice preferred, skip creative style suggestions"
        }
    }
}
