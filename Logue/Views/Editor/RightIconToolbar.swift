import SwiftUI

// MARK: - EditorTool

/// All tool panels available in the right sidebar of the document editor.
enum EditorTool: String, CaseIterable, Identifiable, ToolbarTool {
    // Write group
    case aiChat = "AI Assistant"
    case proofreader = "Proofreader"
    case review = "Review"
    // Refine group
    case rewrite = "Rewrite"
    case vocabularyEnhancement = "Vocabulary"
    case verify = "Verify"
    // Connect group
    case links = "Links"
    case properties = "Properties"

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .aiChat: "AI 助手"
        case .proofreader: "校对"
        case .review: "审阅"
        case .rewrite: "重写"
        case .vocabularyEnhancement: "词汇增强"
        case .verify: "校验"
        case .links: "链接"
        case .properties: "属性"
        }
    }

    var icon: String {
        switch self {
        case .aiChat: "sparkles.rectangle.stack"
        case .proofreader: "checkmark.shield"
        case .review: "checkmark.seal"
        case .rewrite: "arrow.clockwise.circle"
        case .vocabularyEnhancement: "textformat.alt"
        case .verify: "shield.lefthalf.filled"
        case .links: "link"
        case .properties: "list.bullet.rectangle"
        }
    }

    var toolGroup: String {
        switch self {
        case .aiChat, .proofreader, .review:
            "写作"
        case .rewrite, .vocabularyEnhancement, .verify:
            "润色"
        case .links, .properties:
            "关联"
        }
    }

    static var groupOrder: [String] {
        ["写作", "润色", "关联"]
    }

    var preferredPanelWidth: CGFloat {
        switch self {
        case .aiChat: 360
        case .review: 340
        case .rewrite, .proofreader, .verify: 320
        case .vocabularyEnhancement: 300
        case .links: 300
        case .properties: 300
        }
    }
}
