import AppKit
import SwiftUI

// MARK: - ChatMessage

struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let role: ChatRole
    var content: String
    /// True for assistant messages that contain multi-paragraph drafted content
    /// (heuristic: ≥ 3 newlines and ≥ 100 chars). Shows Insert + Copy actions.
    var isInsertable: Bool = false
    /// Selected text that was attached via "Ask AI". Shown as a quote in the chat bubble.
    var quotedContext: String?

    init(role: ChatRole, content: String, quotedContext: String? = nil) {
        id = UUID()
        self.role = role
        self.content = content
        self.quotedContext = quotedContext
    }

    enum ChatRole: String, Codable { case user, assistant }
}

// MARK: - AIChatPanelView

/// AI Assistant tool panel — conversational assistant for the current document.
struct AIChatPanelView: View {
    let document: WritingDocument
    var onSave: (() -> Void)?
    @Binding var messages: [ChatMessage]
    @Binding var pendingMessage: String?
    let onInsert: (String) -> Void

    @State private var inputText = ""
    @State private var isTyping = false
    @State private var streamTask: Task<Void, Never>?
    @State private var inputHeight: CGFloat = 20
    @State private var voiceManager = VoicePushToTalkManager.shared
    @State private var scrollToBottom: UUID?
    /// Selected text from "Ask AI" — shown as a context card above the input bar.
    @State private var contextSelection: String?
    /// Triggers focus on the input field when "Ask AI" sets a pending message.
    @State private var focusInput = false

    var body: some View {
        VStack(spacing: 0) {
            if !messages.isEmpty {
                clearChatBar
            }
            if messages.isEmpty {
                emptyState
            } else {
                messageList
            }
            Divider()
            chatInput
        }
        .background(AppThemeConstants.surfaceBackground)
        .onAppear {
            if let pending = pendingMessage {
                pendingMessage = nil
                contextSelection = pending
                inputText = "请帮我改进或分析这段文本。"
                focusInput = true
            }
        }
        .onChange(of: pendingMessage) { _, newValue in
            guard let pending = newValue else { return }
            pendingMessage = nil
            contextSelection = pending
            inputText = "请帮我改进或分析这段文本。"
            focusInput = true
        }
    }

    // MARK: - Clear Chat Bar

    private var clearChatBar: some View {
        HStack {
            Spacer()
            Button {
                messages.removeAll()
                onSave?()
            } label: {
                Image(systemName: "trash")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help("清空聊天")
            .accessibilityLabel("清空聊天")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(AppThemeConstants.accent.opacity(0.12))
                    .frame(width: 56, height: 56)
                Image(systemName: "sparkles.rectangle.stack")
                    .font(.title2)
                    .foregroundStyle(AppThemeConstants.accent)
            }

            VStack(spacing: 4) {
                Text("有什么可以帮你？")
                    .font(.headline)
                Text("关于你的写作，尽管问我。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 12)

            VStack(alignment: .leading, spacing: 8) {
                Text("给你的灵感")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                FlowLayout(spacing: 6) {
                    if document.body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        QuickPromptChip(label: "帮我头脑风暴", icon: "brain") {
                            sendMessage("帮我头脑风暴一下可以写什么主题。")
                        }
                        QuickPromptChip(label: "创建大纲", icon: "list.bullet.rectangle") {
                            sendMessage("帮我为这篇文档列一个结构清晰的大纲。")
                        }
                        QuickPromptChip(label: "写初稿", icon: "pencil.line") {
                            sendMessage("帮我写一份初稿。你想从什么主题开始？")
                        }
                        QuickPromptChip(label: "写作技巧", icon: "lightbulb") {
                            sendMessage("给我一些高效写作的建议。")
                        }
                    } else {
                        QuickPromptChip(label: "改进我的写作", icon: "wand.and.stars") {
                            sendMessage("请审阅这篇文档，并给出改进建议。")
                        }
                        QuickPromptChip(label: "修正语法", icon: "checkmark.shield") {
                            sendMessage("请找出并修正文档中的所有语法和拼写问题。")
                        }
                        QuickPromptChip(label: "精简表达", icon: "arrow.down.to.line.compact") {
                            sendMessage("请在不丢失原意的前提下让文字更简洁。")
                        }
                        QuickPromptChip(label: "调整语气", icon: "speaker.wave.2") {
                            sendMessage("请调整文字语气，使其更适合目标读者。")
                        }
                        QuickPromptChip(label: "总结", icon: "text.justify.left") {
                            sendMessage("请简要总结这篇文档。")
                        }
                        QuickPromptChip(label: "展开思路", icon: "arrow.up.left.and.arrow.down.right") {
                            sendMessage("请帮我进一步展开和发展文档中的观点。")
                        }
                        QuickPromptChip(label: "添加示例", icon: "lightbulb") {
                            sendMessage("请建议一些可以增强文章说服力的相关示例。")
                        }
                        QuickPromptChip(label: "简化语言", icon: "text.redaction") {
                            sendMessage("请简化语言，让它更容易理解。")
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 24)
    }

    // MARK: - Message List

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { msg in
                        if !(msg.role == .assistant && msg.content.isEmpty) {
                            ChatBubble(
                                message: msg,
                                onInsert: msg.isInsertable ? { onInsert(msg.content) } : nil,
                                onCopy: msg.role == .assistant ? {
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(msg.content, forType: .string)
                                } : nil
                            )
                            .id(msg.id)
                        }
                    }
                    if isTyping, messages.last?.content.isEmpty ?? true {
                        TypingIndicatorView()
                            .id("typing")
                    }
                }
                .padding(AppThemeConstants.paddingMedium)
            }
            .onChange(of: messages.count) {
                if let last = messages.last {
                    withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
            .onChange(of: isTyping) {
                if isTyping {
                    withAnimation { proxy.scrollTo("typing", anchor: .bottom) }
                }
            }
            .onChange(of: scrollToBottom) {
                if let id = scrollToBottom {
                    proxy.scrollTo(id, anchor: .bottom)
                }
            }
        }
    }

    // MARK: - Context Selection Card

    private var contextSelectionCard: some View {
        HStack(alignment: .top, spacing: 8) {
            // Accent bar sized to match text content height
            AppThemeConstants.accent
                .frame(width: 3)
                .clipShape(RoundedRectangle(cornerRadius: 2))

            Text(contextSelection ?? "")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            Spacer(minLength: 0)

            Button {
                withAnimation(.easeOut(duration: 0.15)) {
                    contextSelection = nil
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .buttonStyle(.plain)
            .help("移除所选文本上下文")
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(AppThemeConstants.accent.opacity(0.06))
        )
        .padding(.horizontal, 12)
        .padding(.top, 8)
    }

    // MARK: - Chat Input

    private var chatInput: some View {
        VStack(spacing: 0) {
            if contextSelection != nil {
                contextSelectionCard
            }

            if voiceManager.isRecording {
                VoiceInputIndicator(
                    audioLevel: voiceManager.audioLevel,
                    partialTranscript: voiceManager.partialTranscript,
                    onStop: { voiceManager.stopListening() }
                )
                .padding(.horizontal, 12)
                .padding(.top, 8)
            }

            HStack(alignment: .center, spacing: 8) {
                ChatInputField(text: $inputText, height: $inputHeight, onSubmit: submit, requestFocus: $focusInput)
                    .frame(height: inputHeight)

                // Mic button for voice input
                Button {
                    voiceManager.toggle()
                } label: {
                    Image(systemName: voiceManager.isRecording ? "mic.fill" : "mic")
                        .font(.title2)
                        .foregroundStyle(voiceManager.isRecording ? AppThemeConstants.error : .secondary)
                }
                .buttonStyle(.plain)
                .help(voiceManager.isRecording ? "停止语音输入" : "语音输入")
                .accessibilityLabel(voiceManager.isRecording ? "停止语音输入" : "开始语音输入")

                if isTyping {
                    Button(action: stopGeneration) {
                        Image(systemName: "stop.circle.fill")
                            .font(.title2)
                            .foregroundStyle(AppThemeConstants.accent)
                    }
                    .buttonStyle(.plain)
                    .help("停止生成")
                    .accessibilityLabel("停止生成")
                } else {
                    Button(action: submit) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundStyle(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                ? Color.secondary.opacity(0.5) : AppThemeConstants.accent)
                    }
                    .buttonStyle(.plain)
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || LLMEngineStatus.shared.isBusy)
                    .help("发送消息")
                    .accessibilityLabel("发送消息")
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: AppThemeConstants.radiusLarge)
                .fill(AppThemeConstants.surfaceBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppThemeConstants.radiusLarge)
                .strokeBorder(Color.primary.opacity(AppThemeConstants.opacityLight), lineWidth: 1)
        )
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(AppThemeConstants.chromeBackground)
        .onAppear {
            voiceManager.onTranscriptReady = { transcript in
                inputText = transcript
            }
        }
        .onDisappear {
            // B3: Cancel streaming task on view disappear
            streamTask?.cancel()
            streamTask = nil
            isTyping = false
            voiceManager.onTranscriptReady = nil
            if voiceManager.isRecording {
                voiceManager.stopListening()
            }
        }
    }

    // MARK: - Actions

    private func submit() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        if let selection = contextSelection {
            // Show clean question + quote in chat, send context with XML tags only to LLM
            let llmPrompt = "About this text:\n<content>\n\(selection)\n</content>\n\n\(text)"
            sendMessageWithContext(displayText: text, quotedContext: selection, llmPrompt: llmPrompt)
            contextSelection = nil
        } else {
            sendMessage(text)
        }
    }

    // B1: Use message UUID instead of positional index to prevent out-of-bounds crash
    private func sendMessage(_ text: String) {
        inputText = ""
        messages.append(ChatMessage(role: .user, content: text))

        let assistantMsg = ChatMessage(role: .assistant, content: "")
        messages.append(assistantMsg)
        let assistantMsgID = assistantMsg.id
        isTyping = true

        streamTask = Task { @MainActor in
            do {
                try await streamResponse(for: text, messageID: assistantMsgID)
            } catch {
                handleStreamError(error, messageID: assistantMsgID)
            }
            isTyping = false
            streamTask = nil
            onSave?()
        }
    }

    /// Sends a message where the user-visible text differs from the LLM prompt.
    /// Used by "Ask AI" to keep XML tags out of the chat bubble.
    private func sendMessageWithContext(displayText: String, quotedContext: String, llmPrompt: String) {
        inputText = ""
        messages.append(ChatMessage(role: .user, content: displayText, quotedContext: quotedContext))

        let assistantMsg = ChatMessage(role: .assistant, content: "")
        messages.append(assistantMsg)
        let assistantMsgID = assistantMsg.id
        isTyping = true

        streamTask = Task { @MainActor in
            do {
                try await streamResponse(for: llmPrompt, messageID: assistantMsgID)
            } catch {
                handleStreamError(error, messageID: assistantMsgID)
            }
            isTyping = false
            streamTask = nil
            onSave?()
        }
    }

    private func streamResponse(for text: String, messageID: UUID) async throws {
        let context = document.body.trimmingCharacters(in: .whitespacesAndNewlines)
        // Truncate document content to fit context window
        let maxChars = LLMEngine.maxInputChars(reservedTokens: AppConstants.LLMDefaults.summaryReservedTokens)
        let safeContext = String(context.prefix(maxChars))
        let fullPrompt = safeContext.isEmpty
            ? text
            : "\(text)\n\n---\n\nDOCUMENT CONTENT:\n<content>\n\(safeContext)\n</content>"
        let system = PromptRegistry.Meeting.documentChatSystem.content
        let stream = await LLMEngine.shared.completeStream(system: system, prompt: fullPrompt, maxTokens: 2048)
        var tokenCount = 0
        for try await token in stream {
            guard !Task.isCancelled else { break }
            guard let idx = messages.firstIndex(where: { $0.id == messageID }) else { break }
            messages[idx].content += token
            tokenCount += 1
            if tokenCount % 4 == 0 {
                scrollToBottom = messageID
            }
        }
        scrollToBottom = messageID
        if let idx = messages.firstIndex(where: { $0.id == messageID }) {
            messages[idx].isInsertable = looksLikeDraftContent(messages[idx].content)
        }
    }

    private func handleStreamError(_ error: Error, messageID: UUID) {
        guard !Task.isCancelled else { return }
        let errorText = if let engineErr = error as? LLMError {
            engineErr.localizedDescription
        } else {
            "出了点问题：\(error.localizedDescription)"
        }
        if let idx = messages.firstIndex(where: { $0.id == messageID }),
           messages[idx].content.isEmpty
        {
            messages[idx].content = errorText
        }
    }

    private func stopGeneration() {
        streamTask?.cancel()
        streamTask = nil
        isTyping = false
        onSave?()
    }

    /// Heuristic: multi-paragraph response (≥3 newlines, ≥100 chars) is likely drafted content.
    private func looksLikeDraftContent(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let newlineCount = trimmed.components(separatedBy: "\n").count - 1
        return trimmed.count >= 100 && newlineCount >= 3
    }
}
