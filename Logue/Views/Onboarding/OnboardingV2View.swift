import SwiftUI

/// Phase A0: a streamlined 3-card welcome tour. Replaces the 11-page legacy
/// flow when no license/auth gates are required (today it's used as a
/// "welcome tour" the user can re-trigger from Settings; the legacy
/// `OnboardingView` still owns the first-launch licensing path).
///
/// Cards (in order):
///   1. Privacy promise — "Everything stays on your Mac".
///   2. Choose your model — basic picker over installed/MLX models.
///   3. Set your hotkey — pre-fills ⌥Space + ⌘⌃I as defaults.
struct OnboardingV2View: View {
    @Environment(\.dismiss) private var dismiss

    enum Card: Int, CaseIterable {
        case privacy
        case model
        case hotkey
    }

    @State private var current: Card = .privacy
    @State private var modelManager = ModelManager.shared

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                ForEach(Card.allCases, id: \.self) { card in
                    if card == current {
                        cardView(card)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(Motion.spring, value: current)

            Divider()
            footer
        }
        .frame(width: 540, height: 460)
        .background(.regularMaterial)
    }

    // MARK: - Cards

    @ViewBuilder
    private func cardView(_ card: Card) -> some View {
        switch card {
        case .privacy: privacyCard
        case .model: modelCard
        case .hotkey: hotkeyCard
        }
    }

    private var privacyCard: some View {
        VStack(spacing: 18) {
            Spacer()
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)
                .symbolEffect(.pulse)
            Text("所有内容都留在这台 Mac 上")
                .font(.title.weight(.semibold))
                .multilineTextAlignment(.center)
            Text("Logue 的所有模型、向量嵌入和推理都在设备端运行。数据不会离开这台 Mac。没有分析、没有遥测、没有服务器。")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 420)
            Spacer()
        }
        .padding(28)
    }

    private var modelCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("选择你的模型", systemImage: "cpu")
                .font(.title2.weight(.semibold))
            Text("此模型在本地运行，用于聊天、摘要和设备端搜索。你可以随时在“设置 → 模型”中更改。")
                .font(.callout)
                .foregroundStyle(.secondary)

            ScrollView {
                VStack(spacing: 6) {
                    let modelList = modelManager.allModels
                    if modelList.isEmpty {
                        Text("还没有安装模型——打开“设置 → 模型”浏览。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(modelList, id: \.id) { model in
                            modelRow(model)
                        }
                    }
                }
            }
            .frame(maxHeight: 220)

            Text("提示：4 位量化的 7B 模型可轻松放入 16 GB 统一内存。")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(28)
    }

    private func modelRow(_ model: ModelConfiguration) -> some View {
        let isActive = modelManager.activeModelID == model.id
        return Button {
            modelManager.activeModelID = model.id
        } label: {
            HStack(spacing: 8) {
                Image(systemName: isActive ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isActive ? Color.accentColor : Color.secondary)
                VStack(alignment: .leading, spacing: 1) {
                    Text(model.displayName).font(.callout.weight(.medium))
                    Text(model.id)
                        .font(.caption2.monospaced())
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer()
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isActive ? Color.accentColor.opacity(0.14) : Color.secondary.opacity(0.06))
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var hotkeyCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("设置快捷键", systemImage: "command.square.fill")
                .font(.title2.weight(.semibold))
            Text("Logue 提供两个跨应用快捷键，之后可在“设置 → 快捷键”中更改。")
                .font(.callout)
                .foregroundStyle(.secondary)

            shortcutCard(
                icon: "sparkles",
                title: "菜单栏助手",
                combo: "⌥Space",
                detail: "在任意应用中弹出快速聊天窗口"
            )
            shortcutCard(
                icon: "text.cursor",
                title: "行内写作助手",
                combo: "⌘⌃I",
                detail: "在任意应用中重写所选文本——简化、扩写、修正语法…"
            )

            Text("首次使用 ⌘⌃I 时，macOS 会请求辅助功能权限，以便 Logue 读取你的选中文本。")
                .font(.caption2)
                .foregroundStyle(.tertiary)

            Spacer()
        }
        .padding(28)
    }

    private func shortcutCard(icon: String, title: String, combo: String, detail: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.accentColor)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.callout.weight(.semibold))
                Text(detail).font(.caption2).foregroundStyle(.secondary)
            }
            Spacer()
            Text(combo)
                .font(.system(.callout, design: .monospaced))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.secondary.opacity(0.12))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .strokeBorder(Color.secondary.opacity(0.2), lineWidth: 0.5)
                )
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.secondary.opacity(0.06))
        )
    }

    // MARK: - Footer

    private var footer: some View {
        HStack {
            // Card pager dots
            HStack(spacing: 6) {
                ForEach(Card.allCases, id: \.self) { card in
                    Circle()
                        .fill(card == current ? Color.accentColor : Color.secondary.opacity(0.3))
                        .frame(width: 6, height: 6)
                }
            }
            Spacer()
            if current != .privacy {
                Button("返回") {
                    if let prev = Card(rawValue: current.rawValue - 1) {
                        current = prev
                    }
                }
                .keyboardShortcut(.leftArrow, modifiers: [])
            }
            Button(current == .hotkey ? "开始使用" : "继续") {
                if let next = Card(rawValue: current.rawValue + 1) {
                    current = next
                } else {
                    dismiss()
                }
            }
            .buttonStyle(.borderedProminent)
            .keyboardShortcut(.return)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
}
