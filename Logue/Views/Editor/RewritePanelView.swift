import SwiftUI

// MARK: - RewriteStyle

enum RewriteStyle: String, CaseIterable, Identifiable {
    case professional = "Professional"
    case casual = "Casual"
    case academic = "Academic"
    case creative = "Creative"
    case technical = "Technical"
    case concise = "Concise"
    case persuasive = "Persuasive"
    case natural = "Natural"

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .professional: "专业"
        case .casual: "随性"
        case .academic: "学术"
        case .creative: "创意"
        case .technical: "技术"
        case .concise: "简洁"
        case .persuasive: "说服力"
        case .natural: "自然"
        }
    }

    var icon: String {
        switch self {
        case .professional: "briefcase.fill"
        case .casual: "bubble.left.fill"
        case .academic: "graduationcap.fill"
        case .creative: "paintbrush.fill"
        case .technical: "terminal.fill"
        case .concise: "text.alignleft"
        case .persuasive: "megaphone.fill"
        case .natural: "person.fill.viewfinder"
        }
    }

    var description: String {
        switch self {
        case .professional: "适合商务场合的专业语气"
        case .casual: "亲切自然的口语风格"
        case .academic: "学术化的正式语言"
        case .creative: "富有表现力的叙事"
        case .technical: "适用于文档、代码注释和规范说明"
        case .concise: "清晰简明、直击要点"
        case .persuasive: "有说服力的论证"
        case .natural: "自然的真人语气——去除 AI 腔调，增加缩写和多样的句式"
        }
    }

    var color: Color {
        switch self {
        case .professional: AppThemeConstants.brandPrimary
        case .casual: AppThemeConstants.success
        case .academic: AppThemeConstants.categoryPurple
        case .creative: AppThemeConstants.warning
        case .technical: AppThemeConstants.accent
        case .concise: AppThemeConstants.brandPrimary
        case .persuasive: AppThemeConstants.error
        case .natural: AppThemeConstants.success
        }
    }

    // MARK: - Centralized Prompts

    /// System prompt for the rewrite LLM call.
    /// Sourced from `PromptRegistry.Writing.rewriteStyleInstruction`.
    var systemPrompt: String {
        PromptRegistry.Writing.rewriteStyleInstruction(for: rawValue)
    }
}

// MARK: - RewritePanelView

struct RewritePanelView: View {
    let document: WritingDocument
    var onApply: ((String) -> Void)?
    var onResultSave: ((RewriteResult?) -> Void)?

    @State private var selectedStyle: RewriteStyle = .professional
    @State private var originalText: String = ""
    @State private var rewrittenText: String = ""
    @State private var rewrittenStyle: RewriteStyle?
    @State private var cachedRewrittenText: String = ""
    @State private var isRewriting = false
    @State private var errorMessage: String?
    @State private var showApplyConfirmation = false
    @State private var didApply = false
    @State private var rewriteTask: Task<Void, Never>?

    var body: some View {
        ScrollView {
            content
        }
        .background(AppThemeConstants.surfaceBackground)
        .onAppear {
            if rewrittenText.isEmpty, let saved = document.rewriteResult {
                originalText = saved.originalText
                rewrittenText = saved.rewrittenText
                cachedRewrittenText = saved.rewrittenText
                if let style = RewriteStyle.allCases.first(where: { $0.rawValue.lowercased() == saved.style.lowercased() }) {
                    selectedStyle = style
                    rewrittenStyle = style
                }
            }
        }
        .onChange(of: selectedStyle) { _, newStyle in
            guard !cachedRewrittenText.isEmpty else { return }
            rewrittenText = newStyle == rewrittenStyle ? cachedRewrittenText : ""
            errorMessage = nil
        }
        .onDisappear { rewriteTask?.cancel() }
        .alert("要替换文档正文吗？", isPresented: $showApplyConfirmation) {
            Button("替换", role: .destructive) {
                onApply?(rewrittenText)
                didApply = true
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("这将用重写后的版本替换整篇文档。此操作可以撤销。")
        }
    }

    // MARK: - Content

    private var content: some View {
        VStack(spacing: 0) {
            // Style selector + Rewrite button (compact row)
            HStack(spacing: 8) {
                Menu {
                    ForEach(RewriteStyle.allCases) { style in
                        Button {
                            selectedStyle = style
                        } label: {
                            Label(style.displayName, systemImage: style.icon)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: selectedStyle.icon)
                        Text(selectedStyle.displayName)
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Spacer()

                Button(action: rewriteText) {
                    HStack(spacing: 4) {
                        if isRewriting {
                            ProgressView().controlSize(.mini)
                        } else {
                            Image(systemName: "wand.and.stars")
                        }
                        Text(isRewriting ? "正在重写…" : "重写")
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(AppThemeConstants.accent)
                .controlSize(.small)
                .disabled(isRewriting || document.body.isEmpty || LLMEngineStatus.shared.isBusy)
                .accessibilityLabel("重写文本")
                .accessibilityHint("按所选风格重写你的文本")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Divider()

            if let errorMessage {
                errorState(errorMessage)
            } else if isRewriting, rewrittenText.isEmpty {
                loadingState
            } else if rewrittenText.isEmpty {
                emptyState
            } else {
                resultsView
            }
        }
    }

    private var loadingState: some View {
        VStack(spacing: 12) {
            ProgressView()
                .controlSize(.regular)
            Text("正在重写你的文本…")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding()
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "arrow.clockwise.circle")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("选择风格并重写")
                .font(.subheadline.weight(.medium))
            Text("用 AI 重写，轻松改写你的文本")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding()
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(AppThemeConstants.error)
            Text("重写失败")
                .font(.subheadline.weight(.medium))
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            Button(action: rewriteText) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.clockwise")
                    Text("重试")
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding()
    }

    private var resultsView: some View {
        resultOnlyView
            .padding(AppThemeConstants.paddingLarge)
    }

    private var resultOnlyView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: selectedStyle.icon)
                        .foregroundStyle(selectedStyle.color)
                    Text(selectedStyle.displayName)
                        .font(.caption.weight(.semibold))
                }
                Spacer()
                Button(action: { copyToClipboard(rewrittenText) }, label: {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.on.doc")
                        Text("复制")
                    }
                    .font(.caption)
                })
                .buttonStyle(.borderless)
            }

            Text(rewrittenText)
                .font(.subheadline)
                .textSelection(.enabled)
                .padding(AppThemeConstants.paddingMedium)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppThemeConstants.textInputBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: AppThemeConstants.radiusMedium)
                        .strokeBorder(selectedStyle.color.opacity(0.3), lineWidth: 1)
                )

            // Quick actions
            HStack(spacing: 8) {
                if didApply {
                    Button {
                        onApply?(originalText)
                        didApply = false
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.uturn.backward")
                            Text("撤销")
                        }
                        .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .tint(AppThemeConstants.warning)
                    .accessibilityLabel("撤销重写")
                    .accessibilityHint("恢复文档的原始文本")
                } else {
                    Button { showApplyConfirmation = true } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle")
                            Text("应用")
                        }
                        .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .tint(AppThemeConstants.success)
                    .disabled(onApply == nil)
                    .accessibilityLabel("应用重写")
                    .accessibilityHint("用重写后的版本替换文档文本")
                }

                Button { rewriteText() } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.clockwise")
                        Text("重试")
                    }
                    .font(.caption)
                }
                .buttonStyle(.bordered)
                .accessibilityLabel("重试")
                .accessibilityHint("生成新的重写结果")
            }
        }
    }

    // MARK: - Actions

    private func rewriteText() {
        isRewriting = true
        originalText = document.body
        rewrittenText = ""
        cachedRewrittenText = ""
        rewrittenStyle = nil
        errorMessage = nil
        didApply = false

        rewriteTask = Task { @MainActor in
            let systemPrompt = selectedStyle.systemPrompt
            let userText = originalText

            do {
                let trimmed = try await withRetry {
                    let response = try await LLMEngine.shared.complete(
                        system: systemPrompt,
                        prompt: userText
                    )
                    let trimmed = response.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { throw LLMError.emptyResponse }
                    return trimmed
                }
                rewrittenText = trimmed
                cachedRewrittenText = trimmed
                rewrittenStyle = selectedStyle
                onResultSave?(RewriteResult(
                    style: selectedStyle.displayName,
                    originalText: originalText,
                    rewrittenText: trimmed
                ))
            } catch {
                errorMessage = error.localizedDescription
            }
            isRewriting = false
        }
    }

    private func copyToClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}

// MARK: - StyleCard

private struct StyleCard: View {
    let style: RewriteStyle
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 6) {
                Image(systemName: style.icon)
                    .font(.title3)
                    .foregroundStyle(isSelected ? .white : style.color)

                Text(style.displayName)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: AppThemeConstants.radiusMedium)
                    .fill(isSelected ? style.color : style.color.opacity(AppThemeConstants.activeOpacity))
            )
        }
        .buttonStyle(.plain)
        .help(style.description)
        .accessibilityLabel("\(style.displayName) 风格")
        .accessibilityHint(style.description)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
