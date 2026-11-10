import SwiftUI

/// Modal sheet for configuring writing goals — audience, formality, domain, and intent.
/// Mirrors Grammarly's Goals panel.
struct WritingGoalsPanelView: View {
    let document: WritingDocument
    let onSave: (WritingDocument) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedMode: WritingGoalMode

    init(document: WritingDocument, onSave: @escaping (WritingDocument) -> Void) {
        self.document = document
        self.onSave = onSave
        _selectedMode = State(initialValue: document.goalMode)
    }

    var body: some View {
        VStack(spacing: 0) {
            // ── Header ─────────────────────────────────────────────────
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("写作目标")
                        .font(.title3.bold())
                    Text("根据你的写作场景优化建议")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("关闭")
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)

            Divider()

            // ── Goal mode grid ─────────────────────────────────────────
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("写作风格")
                        .font(.headline)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(WritingGoalMode.allCases, id: \.self) { mode in
                            GoalModeCard(
                                mode: mode,
                                isSelected: selectedMode == mode
                            ) {
                                selectedMode = mode
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    // ── Goal description ───────────────────────────────
                    VStack(alignment: .leading, spacing: 6) {
                        Text("这意味着什么")
                            .font(.subheadline.weight(.medium))
                        Text(selectedMode.systemDescription)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(14)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: AppThemeConstants.radiusLarge))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }

            Divider()

            // ── Footer actions ─────────────────────────────────────────
            HStack {
                Spacer()
                Button("取消") { dismiss() }
                    .keyboardShortcut(.escape)
                Button("应用") {
                    var updated = document
                    updated.goalMode = selectedMode
                    onSave(updated)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(AppThemeConstants.accent)
                .keyboardShortcut(.return)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .frame(width: 480, height: 520)
        .background(AppThemeConstants.chromeBackground)
    }
}

// MARK: - Goal Mode Card

private struct GoalModeCard: View {
    let mode: WritingGoalMode
    let isSelected: Bool
    let onTap: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: mode.icon)
                        .font(.title3)
                        .foregroundStyle(isSelected ? Color.white : AppThemeConstants.accent)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }
                Text(mode.displayName)
                    .font(.subheadline.bold())
                    .foregroundStyle(isSelected ? .white : .primary)
                Text(mode.shortDescription)
                    .font(.caption)
                    .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
                    .lineLimit(2)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                isSelected
                    ? AppThemeConstants.accent
                    : (isHovered ? AppThemeConstants.accent.opacity(AppThemeConstants.hoverOpacity) : AppThemeConstants.surfaceBackground),
                in: RoundedRectangle(cornerRadius: AppThemeConstants.radiusLarge)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppThemeConstants.radiusLarge)
                    .strokeBorder(isSelected ? .clear : Color.secondary.opacity(AppThemeConstants.opacityMedium), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .animation(.easeInOut(duration: 0.12), value: isHovered)
        .animation(.easeInOut(duration: 0.12), value: isSelected)
        .accessibilityLabel("\(mode.displayName)：\(mode.shortDescription)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
