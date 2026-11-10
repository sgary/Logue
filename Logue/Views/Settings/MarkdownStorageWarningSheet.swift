import AppKit
import SwiftUI

/// Shown before documents stop being encrypted.
///
/// Written to be read, not clicked past. Every line is something the user could
/// reasonably be upset to discover afterwards — especially the iCloud one, which is a
/// consequence of the folder's location rather than of anything they asked for.
struct MarkdownStorageWarningSheet: View {
    let onConfirm: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var hasAcknowledged = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            points
            Divider()
            footer
        }
        .padding(20)
        .frame(width: 520)
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: "lock.open.trianglebadge.exclamationmark")
                .font(.title2)
                .foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text("将文档存储为纯 Markdown？")
                    .font(.headline)
                Text("这会改变文档的存放位置，并移除加密。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var points: some View {
        VStack(alignment: .leading, spacing: 10) {
            point(
                "folder",
                "文档将移动到 \(DocumentStorage.markdownRootURL.path.replacingOccurrences(of: NSHomeDirectory(), with: "~"))",
                "每个文档一个 .md 文件，按空间整理到对应文件夹。"
            )
            point(
                "lock.open",
                "文档将不再加密",
                "任何能读取你主文件夹的应用、脚本或 AI 智能体都能读取它们。"
            )
            point(
                "icloud",
                "默认不会进入 iCloud",
                "该文件夹位于“文档”旁边而不是其中，否则 iCloud 云盘的 "
                    + "“桌面与文档文件夹”选项会同步你笔记的未加密副本。"
                    + "覆盖整个主文件夹的备份工具仍会备份它。"
            )
            point(
                "waveform",
                "会议仍保持加密",
                "转写文本、音频、摘要和待办事项不受影响。"
            )
            point(
                "trash",
                "废纸篓仍在 Logue 内",
                "删除的文档不会写入该文件夹。它们保留在加密存储中，"
                    + "关闭此功能后会回到废纸篓。"
            )
            point(
                "arrow.uturn.backward",
                "之后可以关闭此功能",
                "关闭后，文档会移回加密存储，然后该文件夹会被移到废纸篓，"
                    + "确保文档始终只存放在一个地方。你也可以选择保留该文件夹。"
            )
        }
    }

    private func point(_ symbol: String, _ title: String, _ detail: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: symbol)
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(width: 18)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.callout.weight(.medium))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: $hasAcknowledged) {
                Text("我了解我的文档将不再加密")
                    .font(.callout)
            }

            HStack {
                Spacer()
                Button("取消") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("启用") {
                    onConfirm()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!hasAcknowledged)
            }
        }
    }
}
