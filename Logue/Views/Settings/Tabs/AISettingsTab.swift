import AVFoundation
import SwiftUI

/// Phase A: dedicated tab for agent / chat customization. Houses everything
/// that's specific to Ask Logue rather than the general app — system prompt
/// override, per-tool enable/disable, inference parameter sliders, memory
/// recall thresholds, TTS voice picker, Tavily key + reasoning toggle.
///
/// Each setting writes through `UserDefaults` (or `KeychainHelper` for the
/// Tavily key) and AgentCoordinator picks them up on every send.
struct AISettingsTab: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                systemPromptSection
                Divider()
                toolsSection
                Divider()
                inferenceSection
                Divider()
                memorySection
                Divider()
                ttsSection
                Divider()
                webSearchSection
                Divider()
                imageRoutingSection
                Divider()
                knowledgeGraphSection
                Divider()
                reasoningSection
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - System prompt

    @AppStorage(AppConstants.UserDefaultsKeys.agentSystemPromptOverride)
    private var systemPromptOverride: String = ""

    private var systemPromptSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("系统提示词", subtitle: "替换 Logue 默认的智能体指令。留空则使用内置提示词。")
            TextEditor(text: $systemPromptOverride)
                .font(.system(size: 12, design: .monospaced))
                .frame(minHeight: 120, maxHeight: 220)
                .padding(6)
                .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
                )
            HStack {
                Text(systemPromptOverride.isEmpty ? "正在使用内置默认值" : "已启用覆盖")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("重置") { systemPromptOverride = "" }
                    .controlSize(.small)
                    .disabled(systemPromptOverride.isEmpty)
            }
        }
    }

    // MARK: - Per-tool enable/disable

    @AppStorage(AppConstants.UserDefaultsKeys.disabledAgentTools)
    private var disabledToolsRaw: String = ""

    private var disabledTools: Set<String> {
        Set(disabledToolsRaw.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty })
    }

    private static let toolGroups: [(title: String, items: [(String, String)])] = [
        ("读取 — 会议与文档", [
            ("list_meetings", "浏览会议"),
            ("search_meetings", "关键词搜索会议"),
            ("semantic_search_meetings", "概念搜索会议"),
            ("get_meeting_details", "读取会议"),
            ("get_transcript", "读取完整转写"),
            ("get_action_items", "读取待办事项"),
            ("get_daily_digest", "每日活动摘要"),
            ("list_documents", "浏览文档"),
            ("search_documents", "关键词搜索文档"),
            ("semantic_search_documents", "概念搜索文档"),
            ("get_document", "读取文档"),
        ]),
        ("写入 — 内容", [
            ("create_document", "创建文档"),
            ("update_document", "编辑文档"),
            ("delete_document", "删除文档"),
            ("move_document", "移动文档"),
            ("add_document_tag", "为文档添加标签"),
            ("create_space", "创建空间"),
            ("rename_space", "重命名空间"),
            ("delete_space", "删除空间"),
            ("export_document_pdf", "将文档导出为 PDF"),
        ]),
        ("日历与提醒事项", [
            ("get_upcoming_events", "列出即将开始的事件"),
            ("create_calendar_event", "创建事件"),
            ("update_calendar_event", "更新事件"),
            ("delete_calendar_event", "删除事件"),
            ("get_reminders", "列出提醒事项"),
            ("add_reminder", "添加提醒事项"),
            ("update_reminder", "更新提醒事项"),
            ("delete_reminder", "删除提醒事项"),
        ]),
        ("AI 辅助", [
            ("summarize_document", "生成摘要"),
            ("rephrase_text", "改写"),
            ("check_grammar", "语法检查"),
            ("check_clarity", "清晰度检查"),
            ("detect_tone", "语气检测"),
            ("fact_check_document", "事实核查"),
            ("detect_pii", "PII 检测"),
            ("render_diagram", "渲染图表"),
            ("generate_slides", "生成幻灯片"),
        ]),
        ("Apple 原生", [
            ("draft_email", "在邮件中起草邮件"),
            ("fetch_contacts", "查找联系人"),
            ("get_location", "获取当前位置"),
        ]),
        ("计算与对话框", [
            ("run_javascript", "运行 JavaScript"),
            ("get_confirmation", "是/否对话框"),
            ("get_text_input", "文本输入对话框"),
            ("get_user_selection", "单选对话框"),
        ]),
        ("文件（阶段 G）", [
            ("list_directory", "列出目录内容"),
            ("read_file_at_path", "读取指定路径的文件"),
            ("write_text_to_file", "将文本写入文件"),
            ("delete_file_at_path", "删除指定路径的文件"),
        ]),
    ]

    private var toolsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("工具", subtitle: "关闭你不想让智能体调用的工具。切换后将在下一条消息生效。")
            ForEach(Self.toolGroups, id: \.title) { group in
                DisclosureGroup(group.title) {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(group.items, id: \.0) { item in
                            toolRow(name: item.0, label: item.1)
                        }
                    }
                    .padding(.leading, 8)
                    .padding(.top, 4)
                }
                .font(.callout.weight(.medium))
            }
        }
    }

    private func toolRow(name: String, label: String) -> some View {
        let isEnabled = !disabledTools.contains(name)
        return Toggle(isOn: Binding(
            get: { isEnabled },
            set: { newValue in setTool(name, enabled: newValue) }
        )) {
            HStack {
                Text(label).font(.callout)
                Spacer()
                Text(name)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.tertiary)
            }
        }
        .toggleStyle(.switch)
    }

    private func setTool(_ name: String, enabled: Bool) {
        var current = disabledTools
        if enabled {
            current.remove(name)
        } else {
            current.insert(name)
        }
        disabledToolsRaw = current.sorted().joined(separator: ",")
    }

    // MARK: - Inference params

    @AppStorage(AppConstants.UserDefaultsKeys.inferenceTemperature)
    private var temperature: Double = -1

    @AppStorage(AppConstants.UserDefaultsKeys.inferenceTopP)
    private var topP: Double = -1

    @AppStorage(AppConstants.UserDefaultsKeys.inferenceMaxTokens)
    private var maxTokens: Int = -1

    private var inferenceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("推理参数", subtitle: "覆盖采样参数。默认值适用于大多数场景。")

            inferenceSlider(
                label: "温度",
                detail: "越低越聚焦，越高越有创意",
                value: $temperature,
                range: 0 ... 2,
                step: 0.05,
                defaultValue: -1
            )
            inferenceSlider(
                label: "Top-p",
                detail: "核采样阈值",
                value: $topP,
                range: 0 ... 1,
                step: 0.05,
                defaultValue: -1
            )

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("最大输出 Token 数").font(.callout.weight(.medium))
                    Text(maxTokens < 0 ? "默认" : "\(maxTokens) Token")
                        .font(.caption2).foregroundStyle(.secondary)
                }
                Spacer()
                Stepper(
                    value: Binding(
                        get: { maxTokens < 0 ? 2048 : maxTokens },
                        set: { maxTokens = $0 }
                    ),
                    in: 256 ... 8192,
                    step: 256
                ) { EmptyView() }
                if maxTokens >= 0 {
                    Button("默认") { maxTokens = -1 }.controlSize(.small)
                }
            }
        }
    }

    private func inferenceSlider(
        label: String,
        detail: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double,
        defaultValue: Double
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(label).font(.callout.weight(.medium))
                    Text(detail).font(.caption2).foregroundStyle(.secondary)
                }
                Spacer()
                Text(value.wrappedValue < 0 ? "默认" : String(format: "%.2f", value.wrappedValue))
                    .font(.caption.monospacedDigit())
                if value.wrappedValue >= 0 {
                    Button("重置") { value.wrappedValue = defaultValue }.controlSize(.small)
                }
            }
            Slider(
                value: Binding(
                    get: { value.wrappedValue < 0 ? range.lowerBound : value.wrappedValue },
                    set: { value.wrappedValue = $0 }
                ),
                in: range,
                step: step
            )
        }
    }

    // MARK: - Memory thresholds

    @AppStorage(AppConstants.UserDefaultsKeys.memoryRecallThreshold)
    private var recallThreshold: Double = 0.6

    @AppStorage(AppConstants.UserDefaultsKeys.memoryTopK)
    private var topK: Int = 5

    private var memorySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("记忆", subtitle: "智能体回答时回忆相关会议或文档的积极程度。")

            inferenceSlider(
                label: "回忆阈值",
                detail: "仅回忆相似度高于此值的片段",
                value: $recallThreshold,
                range: 0.3 ... 0.95,
                step: 0.05,
                defaultValue: 0.6
            )

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Top-K").font(.callout.weight(.medium))
                    Text("每轮最多回忆的片段数")
                        .font(.caption2).foregroundStyle(.secondary)
                }
                Spacer()
                Stepper(value: $topK, in: 1 ... 20) { Text("\(topK)").monospacedDigit() }
            }
        }
    }

    // MARK: - TTS voice

    @AppStorage(AppConstants.UserDefaultsKeys.ttsVoiceIdentifier)
    private var voiceID: String = ""

    private var ttsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("文字转语音", subtitle: "聊天中“朗读”操作使用的语音。")
            Picker("语音", selection: $voiceID) {
                Text("系统默认").tag("")
                ForEach(Self.englishVoices(), id: \.identifier) { voice in
                    Text("\(voice.name) — \(voice.language)")
                        .tag(voice.identifier)
                }
            }
            .pickerStyle(.menu)
        }
    }

    /// Show only English voices (and any user's preferred locale) sorted by
    /// quality. The full system list runs to 500+ voices on macOS — too noisy.
    private static func englishVoices() -> [AVSpeechSynthesisVoice] {
        AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix("en") }
            .sorted { lhs, rhs in
                if lhs.quality.rawValue != rhs.quality.rawValue {
                    return lhs.quality.rawValue > rhs.quality.rawValue
                }
                return lhs.name < rhs.name
            }
    }

    // MARK: - Web search

    @AppStorage(AppConstants.UserDefaultsKeys.webSearchEnabled)
    private var webSearchEnabled: Bool = false

    @AppStorage(AppConstants.UserDefaultsKeys.tavilyKeyPresent)
    private var tavilyKeyPresent: Bool = false

    @State private var tavilyDraft: String = ""

    private var webSearchSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader(
                "网页搜索",
                subtitle: "默认关闭。开启后，智能体可以调用 DuckDuckGo（免费）或 Tavily（需要密钥）。"
            )
            Toggle("启用网络工具", isOn: $webSearchEnabled)
                .toggleStyle(.switch)

            HStack {
                SecureField(
                    tavilyKeyPresent ? "•••• 已保存 Tavily 密钥" : "可选的 Tavily API 密钥",
                    text: $tavilyDraft
                )
                .textFieldStyle(.roundedBorder)

                Button(tavilyKeyPresent ? "替换" : "保存") {
                    saveTavilyKey()
                }
                .disabled(tavilyDraft.isEmpty)

                if tavilyKeyPresent {
                    Button("清除") { clearTavilyKey() }
                }
            }
            Text(tavilyKeyPresent
                ? "进行网页搜索时优先使用 Tavily。移除密钥后会回退到 DuckDuckGo。"
                : "没有密钥时，网页搜索使用 DuckDuckGo 的免费 HTML 端点。")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .onAppear {
            tavilyKeyPresent = Self.readKeychain(Self.tavilyKeychainKey)?.isEmpty == false
        }
    }

    /// Flatten KeychainHelper's `String??` (throws + optional) into `String?`.
    /// Typed-throws compiler can't infer the flatten with `??nil` cleanly and
    /// SwiftLint flags it, so we wrap once and reuse.
    private static func readKeychain(_ key: String) -> String? {
        do {
            return try KeychainHelper.read(key: key)
        } catch {
            return nil
        }
    }

    private static let tavilyKeychainKey = "agent.tavilyAPIKey"

    private func saveTavilyKey() {
        let trimmed = tavilyDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        do {
            try KeychainHelper.save(key: Self.tavilyKeychainKey, value: trimmed)
            tavilyKeyPresent = true
            tavilyDraft = ""
            ToastCenter.shared.show(UICopy.Toast.saved)
        } catch {
            ToastCenter.shared.show("无法保存密钥", kind: .warning)
        }
    }

    private func clearTavilyKey() {
        _ = KeychainHelper.delete(key: Self.tavilyKeychainKey)
        tavilyKeyPresent = false
        ToastCenter.shared.show("已清除")
    }

    // MARK: - Apple Intelligence routing (Phase F)

    @State private var imageRoutingEnabled: Bool = PromptIntentClassifier.shared.isRoutingEnabled

    private var imageRoutingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader(
                "Apple Intelligence",
                subtitle: "将图像生成提示词路由到 ImagePlayground，而不是文本智能体。"
            )
            Toggle("启用图像路由", isOn: $imageRoutingEnabled)
                .toggleStyle(.switch)
                .onChange(of: imageRoutingEnabled) { _, newValue in
                    PromptIntentClassifier.setRoutingEnabled(newValue)
                }
            if imageRoutingEnabled {
                Text("图像意图评分 ≥ 70% 的提示词会打开 ImagePlayground。需要此 Mac 支持 Apple Intelligence。")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Knowledge Graph

    @State private var graphEnabled: Bool = UserDefaults.standard.bool(forKey: "graph.buildKnowledgeGraph")
    @State private var isRebuildingCommunities = false
    @State private var lastRebuildSummary: String?

    private var knowledgeGraphSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader(
                "知识图谱",
                subtitle: "索引完成后，Logue 会提取实体和关系以支持跨会议回忆。会使用推理资源，默认关闭。"
            )
            Toggle("构建知识图谱", isOn: $graphEnabled)
                .toggleStyle(.switch)
                .onChange(of: graphEnabled) { _, newValue in
                    Task {
                        await EntityExtractor.shared.setEnabled(newValue)
                    }
                }
            if graphEnabled {
                Text(
                    "每次会议或文档索引完成后，实体提取会在后台运行。"
                        + "启用后会使用当前模型，资料库较大时可能需要几分钟。"
                )
                .font(.caption2)
                .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    Button {
                        rebuildCommunities()
                    } label: {
                        if isRebuildingCommunities {
                            ProgressView().controlSize(.mini)
                            Text("正在重建…")
                        } else {
                            Image(systemName: "circle.hexagongrid.fill")
                            Text("重建社区")
                        }
                    }
                    .controlSize(.small)
                    .disabled(isRebuildingCommunities)
                    if let lastRebuildSummary {
                        Text(lastRebuildSummary)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top, 4)
            }
        }
    }

    private func rebuildCommunities() {
        isRebuildingCommunities = true
        lastRebuildSummary = nil
        Task {
            let summary = await CommunityDetector.shared.rebuildCommunities()
            await MainActor.run {
                lastRebuildSummary = summary
                isRebuildingCommunities = false
            }
        }
    }

    // MARK: - Reasoning toggle

    @AppStorage(AppConstants.UserDefaultsKeys.showReasoningBlocks)
    private var showReasoning: Bool = false

    private var reasoningSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionHeader("推理", subtitle: "部分模型会在回答前输出 <thinking> 块。默认关闭。")
            Toggle("在回答中显示推理块", isOn: $showReasoning)
                .toggleStyle(.switch)
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String, subtitle: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.headline)
            if let subtitle {
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}
