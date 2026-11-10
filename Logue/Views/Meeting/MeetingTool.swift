import Foundation

/// Tools available in the meeting workspace right panel.
enum MeetingTool: String, CaseIterable, Identifiable, ToolbarTool {
    // Review group
    case aiChat = "AI Chat"
    case summary = "Summary"
    case actionItems = "Action Items"
    // Details group
    case speakers = "Speakers"
    case bookmarks = "Bookmarks"
    case recording = "Recording"

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .aiChat: "AI 聊天"
        case .summary: "摘要"
        case .actionItems: "待办事项"
        case .speakers: "发言人"
        case .bookmarks: "书签"
        case .recording: "录音"
        }
    }

    var icon: String {
        switch self {
        case .summary: "doc.plaintext"
        case .bookmarks: "bookmark"
        case .actionItems: "checklist"
        case .aiChat: "sparkles.rectangle.stack"
        case .speakers: "person.2"
        case .recording: "waveform"
        }
    }

    var toolGroup: String {
        switch self {
        case .aiChat, .summary, .actionItems:
            "回顾"
        case .speakers, .bookmarks, .recording:
            "详情"
        }
    }

    static var groupOrder: [String] {
        ["回顾", "详情"]
    }

    var preferredPanelWidth: CGFloat {
        switch self {
        case .aiChat: 360
        case .summary: 340
        case .actionItems, .speakers, .bookmarks, .recording: 300
        }
    }
}
