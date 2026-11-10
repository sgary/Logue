import Foundation

/// Builds the sanitised diagnostics block attached to bug reports.
///
/// The output is pasted into **public** GitHub issues, so it carries only
/// environment facts. It deliberately excludes filesystem paths, the account name,
/// URLs, API keys, and any document, meeting, or space content. Every interpolated
/// value goes through `sanitise` so an attacker-controlled or malformed model name
/// cannot inject newlines and forge extra diagnostic lines.
@MainActor
enum DiagnosticsReport {
    /// Maximum characters kept for any single interpolated value.
    static let maxValueLength = 120

    static func generate() -> String {
        let lines: [String] = [
            "- 应用：\(sanitise(BugReportInfo.appVersion)) (\(sanitise(BugReportInfo.buildNumber)))",
            "- macOS：\(sanitise(BugReportInfo.macOSVersion))",
            "- 设备：\(sanitise(BugReportInfo.deviceModel))",
            "- 架构：\(architecture)",
            "- 物理内存：\(physicalMemoryGB) GB",
            "- 当前模型：\(activeModelDescription)",
            "- 外部提供商：\(externalProviderSummary)",
        ]
        return lines.joined(separator: "\n")
    }

    /// Collapses a value to a single safe line.
    ///
    /// Strips control characters and newlines, trims whitespace, clamps length, and
    /// substitutes a placeholder for empty input.
    static func sanitise(_ raw: String) -> String {
        let collapsed = raw.filter { character in
            !character.isNewline && character.unicodeScalars.allSatisfy { scalar in
                !CharacterSet.controlCharacters.contains(scalar)
            }
        }
        let trimmed = collapsed.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return "未知" }
        return String(trimmed.prefix(maxValueLength))
    }

    // MARK: - Environment Facts

    private static var architecture: String {
        #if arch(arm64)
        "arm64"
        #elseif arch(x86_64)
        "x86_64"
        #else
        "未知"
        #endif
    }

    private static var physicalMemoryGB: String {
        let bytes = ProcessInfo.processInfo.physicalMemory
        let gigabytes = Double(bytes) / 1_073_741_824
        return String(format: "%.0f", gigabytes)
    }

    /// The active model's identifier only — never an endpoint URL or key.
    private static var activeModelDescription: String {
        guard let identifier = ModelManager.shared.activeModelID else { return "无" }
        return sanitise(identifier)
    }

    /// Whether any cloud/API model is configured, as a count — never the endpoints
    /// themselves and never the keys, which live in the Keychain.
    private static var externalProviderSummary: String {
        let count = ModelManager.shared.customModels.filter { $0.type == .api }.count
        return count == 0 ? "未配置" : "已配置 \(count) 个"
    }
}
