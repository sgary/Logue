import SwiftUI

// MARK: - VerifyTab

enum VerifyTab: String, CaseIterable {
    case facts = "事实"
    case privacy = "隐私"
    case aiDetection = "AI 检测"

    var icon: String {
        switch self {
        case .facts: "scalemass.fill"
        case .privacy: "eye.slash.fill"
        case .aiDetection: "waveform.badge.magnifyingglass"
        }
    }
}

// MARK: - FactStatus

enum FactStatus: String, Codable {
    case verified = "Verified"
    case unverified = "Unverified"
    case uncertain = "Uncertain"
    case misleading = "Misleading"

    /// Localized status name shown in fact-check chips and cards.
    var displayName: String {
        switch self {
        case .verified: "已核实"
        case .unverified: "未核实"
        case .uncertain: "不确定"
        case .misleading: "有误导性"
        }
    }

    var icon: String {
        switch self {
        case .verified: "checkmark.circle.fill"
        case .unverified: "xmark.circle.fill"
        case .uncertain: "questionmark.circle.fill"
        case .misleading: "exclamationmark.triangle.fill"
        }
    }

    var color: Color {
        switch self {
        case .verified: AppThemeConstants.success
        case .unverified: AppThemeConstants.error
        case .uncertain: AppThemeConstants.warning
        case .misleading: AppThemeConstants.categoryPurple
        }
    }
}

// MARK: - FactCheck

struct FactCheck: Identifiable, Codable {
    let id: UUID
    let claim: String
    let status: FactStatus
    let explanation: String
    let sources: [String]
    let confidence: Int

    init(id: UUID = UUID(), claim: String, status: FactStatus, explanation: String, sources: [String], confidence: Int) {
        self.id = id
        self.claim = claim
        self.status = status
        self.explanation = explanation
        self.sources = sources
        self.confidence = confidence
    }
}

// MARK: - PIIScanResponse

struct PIIScanResponse: Codable {
    let findings: [PIIFinding]
}
