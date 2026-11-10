import os.log
import SwiftUI
import UniformTypeIdentifiers

/// Right panel for exporting meeting data in various formats.
struct MeetingExportPanelView: View {
    let meeting: MeetingNote
    @State private var exportStatus: String?

    var body: some View {
        List {
            Section("导出") {
                ExportOptionButton(
                    title: "完整转写",
                    subtitle: "包含时间戳和发言人标签的纯文本",
                    icon: "doc.text",
                    action: { exportTranscript() }
                )

                ExportOptionButton(
                    title: "会议纪要",
                    subtitle: "包含决策、待办事项和后续跟进的结构化摘要",
                    icon: "doc.plaintext",
                    action: { exportSmartMinutes() }
                )

                ExportOptionButton(
                    title: "待办事项",
                    subtitle: "含负责人的待办事项清单",
                    icon: "checklist",
                    action: { exportActionItems() }
                )

                ExportOptionButton(
                    title: "Markdown",
                    subtitle: "Markdown 格式的完整会议笔记",
                    icon: "text.document",
                    action: { exportMarkdown() }
                )

                if !meeting.bookmarks.isEmpty {
                    ExportOptionButton(
                        title: "书签时刻",
                        subtitle: "\(meeting.bookmarks.count) 个书签及其转写上下文",
                        icon: "bookmark.fill",
                        action: { exportBookmarks() }
                    )
                }
            }

            Section("快速复制") {
                HStack(spacing: 8) {
                    Button {
                        copyToClipboard(meeting.fullTranscript)
                    } label: {
                        Label("转写", systemImage: "doc.on.doc")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)

                    Button {
                        let content = meeting.smartMinutes != nil
                            ? meeting.smartMinutesMarkdown()
                            : (meeting.summary ?? "暂无摘要")
                        copyToClipboard(content)
                    } label: {
                        Label("摘要", systemImage: "doc.on.doc")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }

                if let status = exportStatus {
                    Label(status, systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(AppThemeConstants.success)
                        .transition(.opacity)
                }
            }

            Section {
                PrivacyBadge("导出的文件仅保存在你的设备上。")
            }
        }
        .listStyle(.inset)
        .scrollContentBackground(.hidden)
        .background(AppThemeConstants.surfaceBackground)
    }

    // MARK: - Instance Export Methods (delegate to static)

    private func exportTranscript() {
        Self.exportTranscript(meeting: meeting)
    }

    private func exportSmartMinutes() {
        Self.exportSmartMinutes(meeting: meeting)
    }

    private func exportActionItems() {
        Self.exportActionItems(meeting: meeting)
    }

    private func exportBookmarks() {
        Self.exportBookmarks(meeting: meeting)
    }

    private func exportMarkdown() {
        Self.exportMarkdown(meeting: meeting)
    }

    private func copyToClipboard(_ text: String) {
        Self.copyToClipboard(text)
        exportStatus = "已复制到剪贴板"
        Task {
            try? await Task.sleep(for: AppConstants.Delays.toastDismiss)
            await MainActor.run { exportStatus = nil }
        }
    }

    // MARK: - Static Export Methods

    static func exportTranscript(meeting: MeetingNote) {
        let content = meeting.fullTranscript
        saveFile(content: content, defaultName: "\(meeting.title) - 转写.txt", contentType: .plainText)
    }

    static func exportSmartMinutes(meeting: MeetingNote) {
        let content = meeting.smartMinutesMarkdown()
        saveFile(content: content, defaultName: "\(meeting.title) - 会议纪要.md", contentType: .plainText)
    }

    static func exportActionItems(meeting: MeetingNote) {
        var content = "# 待办事项 — \(meeting.title)\n\n"
        for item in meeting.actionItems {
            let check = item.isCompleted ? "[x]" : "[ ]"
            var line = "- \(check) \(item.title)"
            if let assignee = item.assignee {
                line += " (@\(assignee))"
            }
            if let due = item.dueDescription {
                line += " — 截止：\(due)"
            }
            content += line + "\n"
        }
        saveFile(content: content, defaultName: "\(meeting.title) - 待办事项.md", contentType: .plainText)
    }

    static func exportBookmarks(meeting: MeetingNote) {
        var content = "# 书签时刻 — \(meeting.title)\n\n"
        content += "**日期：** \(meeting.createdAt.formatted())\n"
        content += "**书签：** \(meeting.bookmarks.count)\n\n"

        for bookmark in meeting.bookmarks.sorted(by: { $0.timestamp < $1.timestamp }) {
            let label = bookmark.label.isEmpty ? "书签" : bookmark.label
            content += "## [\(bookmark.formattedTimestamp)] \(label)\n\n"

            let nearby = meeting.segments.filter { segment in
                segment.startTime >= bookmark.timestamp - 5 && segment.startTime <= bookmark.timestamp + 10
            }
            if nearby.isEmpty {
                content += "_此时间戳没有转写内容。_\n\n"
            } else {
                for segment in nearby {
                    let speaker = segment.speakerLabel ?? "发言人"
                    content += "> [\(segment.formattedStartTime)] **\(speaker)：** \(segment.text)\n"
                }
                content += "\n"
            }
        }

        saveFile(content: content, defaultName: "\(meeting.title) - 书签.md", contentType: .plainText)
    }

    static func exportMarkdown(meeting: MeetingNote) {
        var content = "# \(meeting.title)\n\n"
        content += "**日期：** \(meeting.createdAt.formatted())\n"
        content += "**时长：** \(meeting.formattedDuration)\n"
        content += "**模式：** \(meeting.recordingMode.label)\n\n"

        if let summary = meeting.summary {
            content += "## 摘要\n\n\(summary)\n\n"
        }

        if let minutes = meeting.smartMinutes, !minutes.actionItems.isEmpty {
            content += "## 待办事项\n\n"
            for item in minutes.actionItems {
                content += "- [ ] \(item)\n"
            }
            content += "\n"
        }

        content += "## 转写\n\n"
        content += meeting.fullTranscript

        saveFile(content: content, defaultName: "\(meeting.title).md", contentType: .plainText)
    }

    static func copyToClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }

    private static func saveFile(content: String, defaultName: String, contentType: UTType) {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = defaultName
        panel.allowedContentTypes = [contentType]

        if panel.runModal() == .OK, let url = panel.url {
            do {
                try content.write(to: url, atomically: true, encoding: .utf8)
            } catch {
                Logger(subsystem: AppConstants.bundleID, category: "Export")
                    .error("Export failed: \(error.localizedDescription, privacy: .public)")
            }
        }
    }
}

// MARK: - Export Option Button

private struct ExportOptionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.tint)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.callout.weight(.medium))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "arrow.down.to.line")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("导出\(title)")
        .accessibilityHint(subtitle)
    }
}
