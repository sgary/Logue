import AppKit
import os
import SwiftUI
import UniformTypeIdentifiers

/// A sheet that lets users submit a bug report with auto-attached diagnostics
/// and up to 3 optional screenshot attachments.
struct BugReportView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var description = ""
    @State private var screenshots: [URL] = []
    @State private var isSubmitting = false
    @State private var submitResult: SubmitResult?

    static let maxScreenshots = 3
    static let maxScreenshotBytes = 10 * 1024 * 1024 // 10 MB

    private enum SubmitResult {
        case success
        case error(String)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 4) {
                Image(systemName: "ladybug")
                    .font(.system(size: 28))
                    .foregroundStyle(AppThemeConstants.accent)
                Text("报告问题")
                    .font(.headline)
                Text("描述发生了什么，设备信息会自动附加。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 20)
            .padding(.bottom, 16)

            Divider()

            // Form
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("标题")
                        .font(.subheadline.weight(.medium))
                    TextField("简要描述问题", text: $title)
                        .textFieldStyle(.roundedBorder)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("描述")
                        .font(.subheadline.weight(.medium))
                    TextEditor(text: $description)
                        .font(.body)
                        .frame(minHeight: 120)
                        .padding(4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.secondary.opacity(0.3))
                        )
                }

                screenshotsSection

                // Auto-attached info hint
                DisclosureGroup {
                    VStack(alignment: .leading, spacing: 4) {
                        infoRow("应用版本", BugReportInfo.appVersion)
                        infoRow("构建号", BugReportInfo.buildNumber)
                        infoRow("macOS", BugReportInfo.macOSVersion)
                        infoRow("设备", BugReportInfo.deviceModel)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                } label: {
                    Label("附加的设备信息", systemImage: "info.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(20)

            Divider()

            // Result message
            if let result = submitResult {
                Group {
                    switch result {
                    case .success:
                        Label("正在打开 GitHub 提交报告，谢谢！", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(AppThemeConstants.success)
                    case let .error(message):
                        Label(message, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                    }
                }
                .font(.caption)
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }

            // Buttons
            HStack {
                Button("取消") { dismiss() }
                    .keyboardShortcut(.cancelAction)

                Spacer()

                Button(action: submit) {
                    if isSubmitting {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Text("提交报告")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty
                    || description.trimmingCharacters(in: .whitespaces).isEmpty
                    || isSubmitting)
                .keyboardShortcut(.defaultAction)
            }
            .padding(20)
        }
        .frame(width: 480)
    }

    // MARK: - Screenshots section

    private var screenshotsSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Text("截图")
                    .font(.subheadline.weight(.medium))
                Text("（可选，最多 \(Self.maxScreenshots) 张）")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    pickScreenshots()
                } label: {
                    Label("添加", systemImage: "plus")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .disabled(screenshots.count >= Self.maxScreenshots || isSubmitting)
            }

            if !screenshots.isEmpty {
                HStack(spacing: 8) {
                    ForEach(Array(screenshots.enumerated()), id: \.element) { index, url in
                        ScreenshotThumbnail(url: url) {
                            screenshots.remove(at: index)
                        }
                    }
                    Spacer(minLength: 0)
                }
            }
        }
    }

    private func pickScreenshots() {
        let remaining = Self.maxScreenshots - screenshots.count
        guard remaining > 0 else { return }

        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.png, .jpeg, .heic, .webP, .gif]
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.title = "选择截图"
        panel.message = "最多选择 \(remaining) 张图片附加"

        panel.begin { @MainActor response in
            guard response == .OK else { return }
            var added = 0
            for url in panel.urls {
                if added >= remaining {
                    break
                }
                guard let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
                      let size = attrs[.size] as? Int
                else {
                    submitResult = .error("无法读取 \(url.lastPathComponent)。")
                    continue
                }
                if size > Self.maxScreenshotBytes {
                    submitResult = .error("\(url.lastPathComponent) 超过 10 MB，已跳过。")
                    continue
                }
                screenshots.append(url)
                added += 1
            }
            // Clear any prior error if at least one file was added successfully
            if added > 0, case .error = submitResult {
                submitResult = nil
            }
        }
    }

    // MARK: - Helpers

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label + "：")
                .foregroundStyle(.tertiary)
            Text(value)
        }
    }

    private func submit() {
        isSubmitting = true
        submitResult = nil

        Task { @MainActor in
            do {
                try await BugReportService.submit(
                    title: title.trimmingCharacters(in: .whitespaces),
                    description: description.trimmingCharacters(in: .whitespaces),
                    screenshots: screenshots
                )
                submitResult = .success
                // Auto-dismiss after brief delay
                try? await Task.sleep(for: .seconds(1.5))
                isSubmitting = false
                dismiss()
            } catch {
                submitResult = .error("提交失败：\(error.localizedDescription)")
                isSubmitting = false
            }
        }
    }
}

// MARK: - Screenshot Thumbnail

private struct ScreenshotThumbnail: View {
    let url: URL
    let onRemove: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if let image = NSImage(contentsOf: url) {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.secondary.opacity(0.3))
            )

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.white, .black.opacity(0.7))
            }
            .buttonStyle(.plain)
            .padding(2)
            .help("移除")
        }
        .help(url.lastPathComponent)
    }
}

// MARK: - Device Info

@MainActor
enum BugReportInfo {
    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "–"
    }

    static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "–"
    }

    static var macOSVersion: String {
        ProcessInfo.processInfo.operatingSystemVersionString
    }

    static var deviceModel: String {
        var size = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        guard size > 0 else { return "未知" }
        var model = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &model, &size, nil, 0)
        return String(cString: model)
    }
}

// MARK: - Bug Report Service

enum BugReportError: LocalizedError {
    case invalidURL

    var errorDescription: String? {
        switch self {
        case .invalidURL: "无法构建问题报告链接。"
        }
    }
}

/// Files bug reports as GitHub issues on the public Logue repository.
///
/// Logue is open source and ships with no backend, so reports open a prefilled
/// "New issue" page in the browser. Diagnostics are appended to the body;
/// screenshots (which a URL cannot carry) can be dragged into the issue after it opens.
enum BugReportService {
    private static let logger = Logger(subsystem: "com.bitwize.logue", category: "BugReportService")
    private static let newIssueURL = "https://github.com/bitwize-ai/Logue/issues/new"

    @MainActor
    static func submit(title: String, description: String, screenshots: [URL] = []) async throws {
        var bodyLines = [
            description,
            "",
            "---",
            "**诊断信息**",
            DiagnosticsReport.generate(),
        ]

        if !screenshots.isEmpty {
            bodyLines.append("")
            bodyLines.append("_已选择 \(screenshots.count) 张截图，请在问题页面打开后将它们拖入其中。_")
        }

        var components = URLComponents(string: newIssueURL)
        components?.queryItems = [
            URLQueryItem(name: "title", value: title),
            URLQueryItem(name: "body", value: bodyLines.joined(separator: "\n")),
            URLQueryItem(name: "labels", value: "bug"),
        ]

        guard let url = components?.url else {
            logger.error("Failed to construct the GitHub new-issue URL")
            throw BugReportError.invalidURL
        }

        NSWorkspace.shared.open(url)
    }
}
