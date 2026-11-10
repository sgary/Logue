import SwiftUI

/// Claude-style inline tool execution indicator.
///
/// Collapsed: single line with icon + description + status (e.g. "Searched 5 meetings")
/// Expanded: shows tool name, arguments, and formatted result content.
/// Approval state: shows Approve / Reject buttons for destructive tools pending confirmation.
struct ToolExecutionCard: View {
    let toolCall: AgentToolCall
    let result: AgentToolResult?
    /// Conversation ID — required only when the card may render approval buttons; nil for
    /// non-destructive cards rendered from history.
    let conversationID: UUID?

    @State private var isExpanded = false

    init(toolCall: AgentToolCall, result: AgentToolResult?, conversationID: UUID? = nil) {
        self.toolCall = toolCall
        self.result = result
        self.conversationID = conversationID
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Collapsed: single-line summary row
            Button {
                guard result != nil else { return }
                withAnimation(.easeInOut(duration: 0.15)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 6) {
                    // Expand chevron (only if result available)
                    if result != nil {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(.tertiary)
                            .frame(width: 10)
                    }

                    // Tool icon
                    toolIcon
                        .font(.system(size: 11))
                        .foregroundStyle(statusColor)

                    // Summary text
                    Text(summaryText)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    Spacer()

                    // Approval buttons (destructive + awaiting confirmation)
                    if toolCall.status == .needsConfirmation, let conversationID {
                        ToolApprovalButtons(
                            toolCallID: toolCall.id,
                            conversationID: conversationID,
                            clearance: toolCall.clearance
                        )
                    } else {
                        statusBadge
                    }
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 8)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            // Expanded: tool details + result
            if isExpanded, let result {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                        .padding(.horizontal, 8)

                    // Tool name + arguments
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Text(toolCall.toolName)
                                .font(.caption)
                                .fontDesign(.monospaced)
                                .foregroundStyle(.secondary)

                            if !toolCall.arguments.isEmpty, toolCall.arguments != "{}" {
                                Text(formatArguments(toolCall.arguments))
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                                    .lineLimit(1)
                            }
                        }

                        // Result content
                        MarkdownTextView(text: result.output)
                            .font(.caption)
                            .foregroundStyle(result.isError ? .red : .primary)

                        // Phase C polish: when the result references a rendered
                        // diagram, embed the SVG inline below the tool card.
                        if toolCall.toolName == "render_diagram", !result.isError {
                            InlineDiagramView(messageContent: result.output)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.primary.opacity(0.03))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 0.5)
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Summary Text

    /// Human-readable one-line summary of what the tool did.
    private var summaryText: String {
        if toolCall.status == .needsConfirmation {
            return pendingApprovalText
        }
        guard let result, !result.isError else {
            if toolCall.status == .running || toolCall.status == .pending {
                return runningText
            }
            return "\(actionVerb)失败"
        }
        return completedSummary(from: result.output)
    }

    private var pendingApprovalText: String {
        switch toolCall.toolName {
        case "update_document": "智能体想要更新文档"
        case "delete_document": "智能体想要删除文档"
        case "rename_space": "智能体想要重命名空间"
        case "delete_space": "智能体想要删除空间"
        case "create_calendar_event": "智能体想要创建日历事件"
        default: "智能体想要运行 \(toolCall.toolName)"
        }
    }

    private var runningText: String {
        switch toolCall.toolName {
        case "search_meetings": "正在搜索会议…"
        case "list_meetings": "正在加载会议…"
        case "get_meeting_details": "正在加载会议详情…"
        case "get_transcript": "正在加载转写文本…"
        case "get_action_items": "正在加载待办事项…"
        case "get_daily_digest": "正在生成每日摘要…"
        case "list_documents": "正在加载文档…"
        case "search_documents": "正在搜索文档…"
        case "get_document": "正在加载文档内容…"
        case "get_upcoming_events": "正在检查日历…"
        case "create_document": "正在创建文档…"
        case "update_document": "正在更新文档…"
        case "delete_document": "正在删除文档…"
        case "move_document": "正在移动文档…"
        case "add_document_tag": "正在添加标签…"
        case "create_space": "正在创建空间…"
        case "rename_space": "正在重命名空间…"
        case "delete_space": "正在删除空间…"
        case "create_calendar_event": "正在创建日历事件…"
        case "summarize_document": "正在总结文档…"
        case "rephrase_text": "正在改写文本…"
        case "check_grammar": "正在检查语法…"
        case "check_clarity": "正在检查清晰度…"
        case "detect_tone": "正在检测语气…"
        case "fact_check_document": "正在核查文档事实…"
        case "detect_pii": "正在扫描个人身份信息…"
        case "list_templates": "正在加载模板…"
        case "create_document_from_template": "正在从模板创建…"
        case "export_document_pdf": "正在导出 PDF…"
        default: "正在运行 \(toolCall.toolName)…"
        }
    }

    // swiftlint:disable cyclomatic_complexity
    private func completedSummary(from output: String) -> String {
        let firstLine = output.components(separatedBy: "\n").first ?? output
        let count = extractCount(from: firstLine)

        switch toolCall.toolName {
        // Read-only meetings
        case "search_meetings":
            if output.starts(with: "No meetings") {
                return "没有找到匹配的会议"
            }
            return count.map { "找到 \($0) 场匹配的会议" } ?? "已搜索会议"
        case "list_meetings":
            return count.map { "已加载 \($0) 场会议" } ?? "已列出会议"
        case "get_meeting_details":
            return "已加载会议详情"
        case "get_transcript":
            return "已加载转写文本"
        case "get_action_items":
            if output.starts(with: "No") {
                return "没有找到待办事项"
            }
            return count.map { "找到 \($0) 个待办事项" } ?? "已加载待办事项"
        case "get_daily_digest":
            if output.contains("No meetings") {
                return "今天没有会议"
            }
            return count.map { "已总结 \($0) 场会议" } ?? "已生成每日摘要"
        // Read-only documents
        case "list_documents":
            if output.starts(with: "No") {
                return "没有找到文档"
            }
            return count.map { "已加载 \($0) 个文档" } ?? "已列出文档"
        case "search_documents":
            if output.starts(with: "No documents") {
                return "没有找到匹配的文档"
            }
            return count.map { "找到 \($0) 个匹配的文档" } ?? "已搜索文档"
        case "get_document":
            return "已加载文档内容"
        // Read-only calendar
        case "get_upcoming_events":
            if output.contains("No upcoming") || output.contains("not enabled") {
                return "没有即将到来的事件"
            }
            return count.map { "找到 \($0) 个即将到来的事件" } ?? "已检查日历"
        // Templates & export
        case "list_templates":
            return count.map { "已加载 \($0) 个模板" } ?? "已列出模板"
        case "create_document_from_template": return "已从模板创建文档"
        case "export_document_pdf": return "已导出 PDF"
        default:
            return writeOrAISummary()
        }
    }

    // swiftlint:enable cyclomatic_complexity

    /// Summaries for write and AI tools — plain, count-independent labels.
    private func writeOrAISummary() -> String {
        let summaries: [String: String] = [
            // Writes
            "create_document": "已创建文档",
            "update_document": "已更新文档",
            "delete_document": "已将文档移到废纸篓",
            "move_document": "已移动文档",
            "add_document_tag": "已添加标签",
            "create_space": "已创建空间",
            "rename_space": "已重命名空间",
            "delete_space": "已删除空间",
            "create_calendar_event": "已创建日历事件",
            // AI
            "summarize_document": "已总结文档",
            "rephrase_text": "已改写文本",
            "check_grammar": "已检查语法",
            "check_clarity": "已检查清晰度",
            "detect_tone": "已检测语气",
            "fact_check_document": "已核查文档事实",
            "detect_pii": "已扫描个人身份信息",
        ]
        return summaries[toolCall.toolName] ?? "已执行 \(toolCall.toolName)"
    }

    /// Extracts the first number from a string (e.g. "Found 5 meeting(s)" → 5).
    private func extractCount(from text: String) -> Int? {
        let digits = text.components(separatedBy: .decimalDigits.inverted).compactMap { Int($0) }
        return digits.first
    }

    private var actionVerb: String {
        switch toolCall.toolName {
        case "search_meetings", "search_documents": "搜索"
        case "list_meetings", "list_documents": "加载列表"
        case "get_action_items": "加载待办事项"
        case "get_daily_digest": "生成摘要"
        case "get_upcoming_events": "检查日历"
        default: "执行"
        }
    }

    // MARK: - Icons & Status

    @ViewBuilder
    private var toolIcon: some View {
        switch toolCall.toolName {
        case let name where name.contains("meeting"), let name where name.contains("transcript"):
            Image(systemName: "mic.fill")
        case let name where name.contains("document") || name.contains("rephrase"):
            Image(systemName: "doc.text.fill")
        case let name where name.contains("template"):
            Image(systemName: "doc.on.doc.fill")
        case let name where name.contains("calendar") || name.contains("event"):
            Image(systemName: "calendar")
        case let name where name.contains("space"):
            Image(systemName: "folder.fill")
        case let name where name.contains("action"):
            Image(systemName: "checklist")
        case let name where name.contains("digest"):
            Image(systemName: "newspaper.fill")
        case let name where name.contains("grammar") || name.contains("clarity") || name.contains("tone"):
            Image(systemName: "text.magnifyingglass")
        case let name where name.contains("fact_check"):
            Image(systemName: "checkmark.seal")
        case let name where name.contains("pii"):
            Image(systemName: "lock.shield.fill")
        case let name where name.contains("export") || name.contains("pdf"):
            Image(systemName: "square.and.arrow.up")
        case let name where name.contains("summar"):
            Image(systemName: "text.redaction")
        default:
            Image(systemName: "wrench.fill")
        }
    }

    @ViewBuilder
    private var statusBadge: some View {
        switch toolCall.status {
        case .pending, .running:
            ProgressView()
                .controlSize(.mini)
        case .completed:
            Image(systemName: "checkmark")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.green)
        case .failed:
            Image(systemName: "xmark")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.red)
        case .needsConfirmation:
            Image(systemName: "questionmark")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.orange)
        }
    }

    private var statusColor: Color {
        switch toolCall.status {
        case .completed: .green
        case .failed: .red
        case .needsConfirmation: .orange
        default: .secondary
        }
    }

    // MARK: - Helpers

    private func formatArguments(_ json: String) -> String {
        guard let data = json.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return json }
        return dict.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
    }
}
