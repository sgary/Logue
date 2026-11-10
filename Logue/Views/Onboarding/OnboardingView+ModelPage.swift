import SwiftUI

// MARK: - Model Page

extension OnboardingView {
    var isModelBusy: Bool {
        modelManager.downloadingID != nil || modelManager.isActivating
    }

    var hasModelError: Bool {
        modelManager.downloadError != nil || modelManager.activationError != nil
    }

    var modelPage: some View {
        VStack(spacing: 20) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(modelPageIconBackground)
                    .frame(width: 72, height: 72)
                if modelManager.isActivating {
                    ProgressView()
                        .scaleEffect(1.2)
                } else {
                    Image(systemName: modelPageIcon)
                        .font(.title)
                        .foregroundStyle(modelPageIconColor)
                }
            }

            // Title & subtitle
            VStack(spacing: 8) {
                Text(modelPageTitle)
                    .font(.title2.bold())
                Text(modelPageSubtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 380)
            }

            // Action area
            if modelManager.activeModelID != nil {
                // Complete — auto-advance only once (not when navigating back)
                Label("AI 模型已就绪", systemImage: "checkmark.circle.fill")
                    .font(.callout.weight(.medium))
                    .foregroundStyle(AppThemeConstants.success)
                    .task {
                        guard !didAutoAdvanceFromModel else { return }
                        didAutoAdvanceFromModel = true
                        try? await Task.sleep(for: AppConstants.Delays.onboardingAutoAdvance)
                        withAnimation(.easeInOut(duration: 0.25)) { currentPage += 1 }
                    }
            } else if modelManager.downloadingID != nil {
                // Downloading — progress bar
                VStack(spacing: 8) {
                    ProgressView(value: modelManager.downloadProgress)
                        .frame(maxWidth: 300)
                    HStack {
                        Text("\(Int(modelManager.downloadProgress * 100))%")
                            .font(.callout.monospacedDigit())
                            .foregroundStyle(.secondary)
                        Spacer()
                        if let size = ModelConfiguration.onboardingModel.sizeGB {
                            Text("~\(String(format: "%.1f", size)) GB")
                                .font(.callout)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .frame(maxWidth: 300)
                }
            } else if modelManager.isActivating {
                // Activating — handled by spinner icon above
                EmptyView()
            } else if hasModelError {
                // Error — retry button
                VStack(spacing: 12) {
                    Text(modelManager.downloadError ?? modelManager.activationError ?? "未知错误")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 300)

                    Button("重试") {
                        modelManager.downloadAndActivate(ModelConfiguration.onboardingModel, autoActivate: true)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppThemeConstants.accent)
                    .controlSize(.large)
                    .disabled(isModelBusy)
                    .accessibilityLabel("重试下载")
                    .accessibilityHint("重新尝试下载 AI 模型")
                }
            } else {
                // Ready to download
                VStack(spacing: 12) {
                    if let size = ModelConfiguration.onboardingModel.sizeGB {
                        Text("下载约 \(String(format: "%.1f", size)) GB")
                            .font(.callout)
                            .foregroundStyle(.tertiary)
                    }

                    Button("下载") {
                        modelManager.downloadAndActivate(ModelConfiguration.onboardingModel, autoActivate: true)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppThemeConstants.accent)
                    .controlSize(.large)
                    .disabled(isModelBusy)
                    .accessibilityLabel("下载 AI 模型")
                    .accessibilityHint("下载写作建议和会议摘要所需的 AI 模型")
                }
            }

            Spacer()

            PrivacyBadge("模型通过 Apple Silicon 机器学习加速在本地运行。")
                .padding(.bottom, 8)
        }
        .padding(AppThemeConstants.paddingXLarge)
    }

    // MARK: - Model Page Helpers

    var modelPageIcon: String {
        if modelManager.activeModelID != nil {
            "checkmark.circle.fill"
        } else if hasModelError {
            "exclamationmark.triangle.fill"
        } else if modelManager.downloadingID != nil {
            "arrow.down.circle.fill"
        } else {
            "arrow.down.circle.fill"
        }
    }

    var modelPageIconColor: Color {
        if modelManager.activeModelID != nil {
            AppThemeConstants.success
        } else if hasModelError {
            .orange
        } else {
            AppThemeConstants.accent
        }
    }

    var modelPageIconBackground: Color {
        if modelManager.activeModelID != nil {
            AppThemeConstants.success.opacity(0.12)
        } else if hasModelError {
            AppThemeConstants.warning.opacity(AppThemeConstants.activeOpacity)
        } else {
            AppThemeConstants.accent.opacity(0.12)
        }
    }

    var modelPageTitle: String {
        if modelManager.activeModelID != nil {
            "AI 模型已就绪"
        } else if modelManager.isActivating {
            "正在设置 AI 模型…"
        } else if modelManager.downloadingID != nil {
            "正在下载 AI 模型…"
        } else if hasModelError {
            "下载失败"
        } else {
            "下载 AI 模型"
        }
    }

    var modelPageSubtitle: String {
        if modelManager.activeModelID != nil {
            "AI 功能已全部就绪。"
        } else if modelManager.isActivating {
            "正在准备模型，以供首次使用。"
        } else if modelManager.downloadingID != nil {
            "根据网络情况，这可能需要几分钟。"
        } else if hasModelError {
            "出了点问题。请检查网络连接后重试。"
        } else {
            "Logue 需要一个小型 AI 模型来支持写作建议、会议摘要和聊天。这是一次性下载。"
        }
    }
}
