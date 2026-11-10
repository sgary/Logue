import SwiftUI

/// Protocol for any downloadable model record used with `ModelDownloadRow`.
protocol DownloadableModel: Identifiable {
    var displayName: String { get }
    var sizeLabel: String { get }
    var descriptionText: String { get }
    var isRecommended: Bool { get }
}

/// Unified row for model download/activation in Settings.
/// Handles all 5 states: downloading, activating, active, downloaded, not-downloaded.
struct ModelDownloadRow<M: DownloadableModel>: View {
    let model: M
    let isActive: Bool
    let isDownloading: Bool
    let isActivating: Bool
    /// Set to a 0..1 value for a determinate progress bar, or nil for an indeterminate spinner.
    let downloadProgress: Double?
    let isDownloaded: Bool
    let onAction: () -> Void
    var onCancel: (() -> Void)?
    var onDelete: (() -> Void)?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isActive ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isActive ? AppThemeConstants.accent : .secondary)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(model.displayName)
                        .font(.subheadline.weight(.medium))
                    if model.isRecommended {
                        Text("推荐")
                            .font(.caption2)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(AppThemeConstants.accent.opacity(AppThemeConstants.activeOpacity), in: Capsule())
                            .foregroundStyle(AppThemeConstants.accent)
                    }
                }
                Text(model.descriptionText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(model.sizeLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 6) {
                    if isDownloading {
                        downloadingView
                        if let onCancel {
                            Button(action: onCancel) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                            .help("取消下载")
                        }
                    } else if isActivating {
                        InlineProgressLabel(text: "激活中…")
                    } else if isActive {
                        Text("使用中")
                            .font(.caption2.bold())
                            .foregroundStyle(AppThemeConstants.accent)
                    } else if isDownloaded {
                        Button("启用", action: onAction)
                            .controlSize(.mini)
                    } else {
                        Button("下载", action: onAction)
                            .controlSize(.mini)
                            .buttonStyle(.borderedProminent)
                            .tint(AppThemeConstants.accent)
                            .disabled(isDownloading)
                    }

                    // Delete button for downloaded (non-active) models
                    if let onDelete, isDownloaded, !isActive, !isDownloading, !isActivating {
                        Button(action: onDelete) {
                            Image(systemName: "trash")
                                .font(.caption)
                                .foregroundStyle(AppThemeConstants.error)
                        }
                        .buttonStyle(.plain)
                        .help("删除已下载的模型")
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(model.displayName)，\(model.sizeLabel)")
        .accessibilityValue(isActive ? "使用中" : isDownloading ? "下载中" : isActivating ? "加载中" : isDownloaded ? "已下载" :
            "未下载")
        .accessibilityHint(isActive ? "" : isDownloaded ? "双击以启用" : "双击以下载")
    }

    @ViewBuilder
    private var downloadingView: some View {
        if let progress = downloadProgress {
            ProgressView(value: progress)
                .frame(width: 80)
        } else {
            HStack(spacing: 4) {
                ProgressView().scaleEffect(0.7)
                Text("下载中…")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
