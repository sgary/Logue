import SwiftUI

// MARK: - Space Item

/// A unified item type for mixed display in a space.
enum SpaceItem: Identifiable {
    case document(WritingDocument)
    case meeting(MeetingNote)
    case space(Space)

    var id: UUID {
        switch self {
        case let .document(doc): doc.id
        case let .meeting(meeting): meeting.id
        case let .space(space): space.id
        }
    }

    var title: String {
        switch self {
        case let .document(doc): doc.title
        case let .meeting(meeting): meeting.title
        case let .space(space): space.name
        }
    }

    var modifiedAt: Date {
        switch self {
        case let .document(doc): doc.modifiedAt
        case let .meeting(meeting): meeting.modifiedAt
        case let .space(space): space.createdAt
        }
    }

    var createdAt: Date {
        switch self {
        case let .document(doc): doc.createdAt
        case let .meeting(meeting): meeting.createdAt
        case let .space(space): space.createdAt
        }
    }
}

// MARK: - Filter & Sort

enum SpaceFilterType: CaseIterable {
    case all, documents, meetings

    var label: String {
        switch self {
        case .all: "全部"
        case .documents: "文档"
        case .meetings: "会议"
        }
    }

    var icon: String {
        switch self {
        case .all: "square.grid.2x2"
        case .documents: "doc.text"
        case .meetings: "waveform"
        }
    }
}

enum SpaceSortOrder: CaseIterable {
    case modifiedNewest, modifiedOldest, titleAZ, titleZA, createdNewest, createdOldest

    var label: String {
        switch self {
        case .modifiedNewest: "修改时间（最新）"
        case .modifiedOldest: "修改时间（最早）"
        case .titleAZ: "标题（A-Z）"
        case .titleZA: "标题（Z-A）"
        case .createdNewest: "创建时间（最新）"
        case .createdOldest: "创建时间（最早）"
        }
    }
}

// MARK: - Sidebar Space Sort

enum SidebarSpaceSortOrder: String, CaseIterable {
    case custom
    case nameAZ
    case nameZA
    case createdNewest
    case createdOldest

    var label: String {
        switch self {
        case .custom: "自定义"
        case .nameAZ: "名称（A–Z）"
        case .nameZA: "名称（Z–A）"
        case .createdNewest: "创建日期（最新）"
        case .createdOldest: "创建日期（最早）"
        }
    }
}
