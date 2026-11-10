import SwiftUI

// MARK: - PII Category

enum PIICategory: String, CaseIterable, Identifiable, Codable {
    case identity = "Identity"
    case contact = "Contact"
    case governmentIDs = "Government IDs"
    case financial = "Financial"
    case credentials = "Credentials"
    case health = "Health"
    case employmentEducation = "Employment/Education"
    case biometric = "Biometric"
    case locationDevice = "Location/Device"
    case metadata = "Metadata"

    var id: String {
        rawValue
    }

    /// Localized category name for the privacy panel.
    var displayName: String {
        switch self {
        case .identity: "身份信息"
        case .contact: "联系方式"
        case .governmentIDs: "政府证件"
        case .financial: "财务信息"
        case .credentials: "登录凭证"
        case .health: "健康信息"
        case .employmentEducation: "就业与教育"
        case .biometric: "生物识别"
        case .locationDevice: "位置与设备"
        case .metadata: "元数据"
        }
    }

    var icon: String {
        switch self {
        case .identity: "person.text.rectangle"
        case .contact: "envelope.fill"
        case .governmentIDs: "creditcard.fill"
        case .financial: "banknote.fill"
        case .credentials: "key.fill"
        case .health: "heart.text.square.fill"
        case .employmentEducation: "graduationcap.fill"
        case .biometric: "faceid"
        case .locationDevice: "location.fill"
        case .metadata: "server.rack"
        }
    }

    var examples: String {
        switch self {
        case .identity: "姓名、出生日期、性别"
        case .contact: "邮箱、电话、地址、社交账号"
        case .governmentIDs: "SSN、护照、驾照、税号"
        case .financial: "银行账户、银行卡、支付账户、加密货币"
        case .credentials: "密码、动态验证码、PIN、API 密钥"
        case .health: "保险、病历、处方"
        case .employmentEducation: "员工编号、学号、成绩单"
        case .biometric: "指纹、人脸、声音、虹膜"
        case .locationDevice: "GPS、IP、设备标识"
        case .metadata: "Cookie、会话 ID、用户名"
        }
    }

    var risk: PIIRisk {
        switch self {
        case .identity: .medium
        case .contact: .medium
        case .governmentIDs: .high
        case .financial: .high
        case .credentials: .critical
        case .health: .high
        case .employmentEducation: .medium
        case .biometric: .high
        case .locationDevice: .medium
        case .metadata: .medium
        }
    }
}

// MARK: - PII Risk Level

enum PIIRisk: String, Codable, Comparable {
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"

    var color: Color {
        switch self {
        case .medium: AppThemeConstants.warning
        case .high: AppThemeConstants.error
        case .critical: AppThemeConstants.error
        }
    }

    /// Localized risk name shown in badges.
    var displayName: String {
        switch self {
        case .medium: "中"
        case .high: "高"
        case .critical: "严重"
        }
    }

    var badgeColor: Color {
        switch self {
        case .medium: AppThemeConstants.warning
        case .high: AppThemeConstants.error
        case .critical: AppThemeConstants.error
        }
    }

    private var sortOrder: Int {
        switch self {
        case .critical: 3
        case .high: 2
        case .medium: 1
        }
    }

    static func < (lhs: PIIRisk, rhs: PIIRisk) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }
}

// MARK: - PII Finding

struct PIIFinding: Identifiable, Codable {
    var id: String {
        "\(category.rawValue)-\(text)"
    }

    let category: PIICategory
    let text: String
    let detail: String

    enum CodingKeys: String, CodingKey {
        case category, text, detail
    }
}
