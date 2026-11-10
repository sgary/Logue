import SwiftUI

/// Dismissible banner shown on the Overview when sample data is still present.
struct SeedDataBannerView: View {
    @AppStorage(AppConstants.UserDefaultsKeys.hasClearedSeedData) private var hasClearedSeedData = false
    @Environment(DocumentStore.self) private var documentStore
    @Environment(MeetingStore.self) private var meetingStore
    @Environment(SpaceStore.self) private var spaceStore

    @State private var showConfirmation = false
    @State private var isDismissed = false

    /// Only show the banner when seed data was actually loaded (not real user data from disk).
    private var storesLoadedSeedData: Bool {
        meetingStore.loadedSeedData || documentStore.loadedSeedData
    }

    var body: some View {
        if !hasClearedSeedData, !isDismissed, storesLoadedSeedData {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.title3)
                    .foregroundStyle(AppThemeConstants.brandPrimary)

                VStack(alignment: .leading, spacing: 2) {
                    Text("正在用示例数据体验")
                        .font(.subheadline.weight(.medium))
                    Text("准备好从头开始时，清除示例数据。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button("清除示例") {
                    showConfirmation = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .tint(AppThemeConstants.accent)
                .accessibilityLabel("清除示例数据")
                .accessibilityHint("移除所有示例文档、会议和文件夹")

                Button {
                    withAnimation(.easeOut(duration: 0.2)) {
                        isDismissed = true
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("关闭示例数据横幅")
            }
            .padding(14)
            .background(
                AppThemeConstants.brandPrimary.opacity(AppThemeConstants.hoverOpacity),
                in: RoundedRectangle(cornerRadius: AppThemeConstants.radiusLarge)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppThemeConstants.radiusLarge)
                    .strokeBorder(AppThemeConstants.brandPrimary.opacity(AppThemeConstants.opacityMedium), lineWidth: 1)
            )
            .transition(.opacity.combined(with: .move(edge: .top)))
            .confirmationDialog(
                "清除所有示例数据？",
                isPresented: $showConfirmation,
                titleVisibility: .visible
            ) {
                Button("清除示例", role: .destructive) {
                    clearSeedData()
                }
                Button("取消", role: .cancel) {}
            } message: {
                Text("这将移除所有示例文档、会议和文件夹。此操作无法撤销。")
            }
        }
    }

    private func clearSeedData() {
        withAnimation(.easeOut(duration: 0.25)) {
            documentStore.clearAllData()
            meetingStore.clearAllData()
            spaceStore.clearAllData()
            TaskStore.shared.clearAllData()
            hasClearedSeedData = true
        }
    }
}
