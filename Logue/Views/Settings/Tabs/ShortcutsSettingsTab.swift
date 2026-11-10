import SwiftUI

/// Phase A0: a flat reference table of every keyboard shortcut Logue exposes.
/// Read-only for now (rebinding requires a dedicated `ShortcutManager` slot
/// that the menu commands honor — left for a follow-up). Lists the same set
/// the plan promised so the user can discover them all in one place.
struct ShortcutsSettingsTab: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                ForEach(ShortcutGroup.all) { group in
                    section(group)
                }
            }
            .padding(20)
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("键盘快捷键")
                .font(.title3.weight(.semibold))
            Text(
                "所有快捷键列于下方。自定义绑定将在后续版本推出 — 如果默认快捷键与你使用的其他工具冲突，请提交 issue。"
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    // MARK: - Group rendering

    private func section(_ group: ShortcutGroup) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(group.title)
                .font(.callout.weight(.semibold))
                .foregroundStyle(.secondary)
            ForEach(group.entries) { entry in
                shortcutRow(entry)
            }
        }
    }

    private func shortcutRow(_ entry: ShortcutEntry) -> some View {
        HStack {
            Text(entry.label)
                .font(.callout)
            Spacer()
            Text(entry.combo)
                .font(.system(.caption, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.10))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(Color.secondary.opacity(0.18), lineWidth: 0.5)
                )
        }
        .padding(.vertical, 3)
    }
}

// MARK: - Data

private struct ShortcutEntry: Identifiable {
    let id = UUID()
    let label: String
    let combo: String
}

private struct ShortcutGroup: Identifiable {
    let id = UUID()
    let title: String
    let entries: [ShortcutEntry]

    static let all: [ShortcutGroup] = [
        ShortcutGroup(title: "聊天", entries: [
            ShortcutEntry(label: "新建聊天", combo: "⌘N"),
            ShortcutEntry(label: "新建聊天（询问 Logue）", combo: "⌘L"),
            ShortcutEntry(label: "聚焦聊天输入框", combo: "⌘⇧L"),
            ShortcutEntry(label: "发送", combo: "⌘⏎"),
            ShortcutEntry(label: "停止生成", combo: "Esc"),
            ShortcutEntry(label: "复制上一条助手消息", combo: "⌘⇧C"),
            ShortcutEntry(label: "重新生成上一条回答", combo: "⌘⇧R"),
        ]),
        ShortcutGroup(title: "导航", entries: [
            ShortcutEntry(label: "命令面板", combo: "⌘K"),
            ShortcutEntry(label: "聚焦对话搜索", combo: "⌘/"),
            ShortcutEntry(label: "切换侧边栏", combo: "⌘S"),
            ShortcutEntry(label: "设置", combo: "⌘,"),
            ShortcutEntry(label: "上一条/下一条消息", combo: "⌘↑ / ⌘↓"),
        ]),
        ShortcutGroup(title: "跨应用（阶段 D）", entries: [
            ShortcutEntry(label: "内联写作助手", combo: "⌘⌃I"),
            ShortcutEntry(label: "菜单栏助手（计划中）", combo: "⌥Space"),
        ]),
        ShortcutGroup(title: "对话列表", entries: [
            ShortcutEntry(label: "导出所选对话", combo: "⌘E"),
            ShortcutEntry(label: "从所选消息分支", combo: "⌘;"),
        ]),
    ]
}
