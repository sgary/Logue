import SwiftUI

struct ModelSettingsRow: View {
    @Environment(ModelManager.self) private var modelManager
    let record: ModelConfiguration

    @State private var showDeleteConfirm = false

    private var isActive: Bool {
        modelManager.activeModel?.id == record.id
    }

    private var isDownloading: Bool {
        modelManager.isDownloading(record)
    }

    private var isDownloaded: Bool {
        modelManager.isDownloaded(record)
    }

    private var isCustomModel: Bool {
        modelManager.customModels.contains { $0.id == record.id }
    }

    private var isActivating: Bool {
        modelManager.activatingModelID == record.id && modelManager.isActivating
    }

    /// Another model (not this row) is currently downloading.
    private var isOtherDownloading: Bool {
        modelManager.isAnyDownloadInProgress && !isDownloading
    }

    private var isInferenceBusy: Bool {
        LLMEngineStatus.shared.isBusy
    }

    /// A download or activation failure for this row, in that order.
    private var rowError: String? {
        if let error = modelManager.downloadError, modelManager.downloadErrorModelID == record.id {
            return error
        }
        if let error = modelManager.activationError, modelManager.activationErrorModelID == record.id {
            return error
        }
        return nil
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Model info
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(record.displayName)
                            .font(.subheadline.weight(.medium))
                        if record.isRecommended {
                            Text("推荐")
                                .font(.caption2)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1)
                                .background(AppThemeConstants.brandPrimary.opacity(AppThemeConstants.activeOpacity), in: Capsule())
                                .foregroundStyle(AppThemeConstants.brandPrimary)
                        }
                        if isActive {
                            Text("使用中")
                                .font(.caption2)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1)
                                .background(AppThemeConstants.success.opacity(AppThemeConstants.activeOpacity), in: Capsule())
                                .foregroundStyle(AppThemeConstants.success)
                        }
                    }
                    Text(record.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                if let size = record.sizeGB {
                    Text(String(format: "%.1f GB", size))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Action buttons
                actionButtons
            }

            // Download progress bar
            if isDownloading {
                HStack(spacing: 8) {
                    ProgressView(value: modelManager.downloadProgress)
                        .tint(AppThemeConstants.accent)

                    Text(downloadProgressLabel)
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(.secondary)

                    Button {
                        modelManager.cancelDownload()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("取消下载")
                    .accessibilityLabel("取消下载")
                }
                .padding(.top, 6)
            }

            // Failure from either half of the flow
            if let error = rowError, !isDownloading {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundStyle(AppThemeConstants.error)
                    Text(error)
                        .font(.caption2)
                        .foregroundStyle(AppThemeConstants.error)
                        .lineLimit(2)
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: AppThemeConstants.radiusMedium, style: .continuous)
                .fill(isActive ? AppThemeConstants.brandPrimary
                    .opacity(AppThemeConstants.activeOpacity) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppThemeConstants.radiusMedium, style: .continuous)
                .stroke(isActive ? AppThemeConstants.brandPrimary.opacity(AppThemeConstants.borderOpacity) : Color.clear, lineWidth: 1)
        )
        .accessibilityLabel("\(record.displayName)\(isActive ? "，使用中" : "")\(isDownloaded ? "" : "，未下载")")
        .alert(isDownloaded ? "删除模型？" : "移除模型？", isPresented: $showDeleteConfirm) {
            Button(isDownloaded ? "删除" : "移除", role: .destructive) {
                if isDownloaded {
                    modelManager.deleteDownloadedModel(record)
                } else {
                    modelManager.removeCustomModel(id: record.id)
                }
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text(isDownloaded
                ? "这将从磁盘删除“\(record.displayName)”的已下载文件。之后可以重新下载。"
                : "这将从模型列表中移除“\(record.displayName)”。之后可以再次添加。")
        }
    }

    @ViewBuilder
    private var actionButtons: some View {
        if isDownloading {
            // Downloading — actions handled in the progress row below
            EmptyView()
        } else if isActivating {
            HStack(spacing: 4) {
                InlineProgressLabel(text: "正在启用…")
                Button {
                    modelManager.cancelActivation()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help("取消启用")
                .accessibilityLabel("取消启用")
            }
        } else if isDownloaded {
            HStack(spacing: 8) {
                if !isActive {
                    Button {
                        modelManager.loadModel(record)
                    } label: {
                        Text("加载")
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(AppThemeConstants.brandPrimary.opacity(AppThemeConstants.activeOpacity), in: Capsule())
                            .foregroundStyle(AppThemeConstants.brandPrimary)
                    }
                    .buttonStyle(.plain)
                    .disabled(isInferenceBusy)
                    .help("将模型加载到内存")
                }

                Button {
                    showDeleteConfirm = true
                } label: {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundStyle(AppThemeConstants.error)
                }
                .buttonStyle(.plain)
                .disabled(isActive)
                .opacity(isActive ? 0.3 : 1.0)
                .help(isActive ? "请先卸载模型再删除" : "删除已下载的模型")
                .accessibilityLabel("删除已下载的模型")
            }
        } else {
            // Not downloaded — show download button
            HStack(spacing: 8) {
                Button {
                    modelManager.downloadModel(record)
                } label: {
                    Label("下载", systemImage: "arrow.down.circle")
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(AppThemeConstants.accent.opacity(AppThemeConstants.activeOpacity), in: Capsule())
                        .foregroundStyle(AppThemeConstants.accent)
                }
                .buttonStyle(.plain)
                .disabled(isOtherDownloading)
                .opacity(isOtherDownloading ? 0.5 : 1.0)
                .help(isOtherDownloading ? "另一个模型正在下载" : "下载模型")

                // Allow removing custom models that aren't downloaded
                if isCustomModel {
                    Button {
                        showDeleteConfirm = true
                    } label: {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundStyle(AppThemeConstants.error)
                    }
                    .buttonStyle(.plain)
                    .help("移除模型")
                    .accessibilityLabel("移除模型")
                }
            }
        }
    }

    private var downloadProgressLabel: String {
        let pct = Int(modelManager.downloadProgress * 100)
        if pct == 0 {
            return "准备中…"
        }
        if let totalGB = record.sizeGB {
            let downloadedMB = modelManager.downloadProgress * totalGB * 1024
            if downloadedMB < 1 {
                let downloadedKB = downloadedMB * 1024
                return String(format: "%.0f KB / %.1f GB · %d%%", downloadedKB, totalGB, pct)
            }
            return String(format: "%.0f MB / %.1f GB · %d%%", downloadedMB, totalGB, pct)
        }
        return "\(pct)%"
    }
}
