import AppKit
import SwiftUI

/// Phase A0: dedicated privacy surface. Surfaces encryption status, data
/// location with "Reveal in Finder", and the plain-English permission summary
/// (with a hand-off to System Settings when the user wants to revoke).
struct PrivacySettingsTab: View {
    @State private var storage = DocumentStorage.shared
    @Environment(DocumentStore.self) private var documentStore
    @State private var taskStore = TaskStore.shared
    @Environment(SpaceStore.self) private var spaceStore
    @State private var showingEnableWarning = false
    @State private var showingDisableConfirmation = false
    @State private var storageError: String?
    @State private var dataDirectory: URL = Self.dataDirectory()
    @State private var showEraseConfirm = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                encryptionSection
                Divider()
                dataLocationSection
                Divider()
                markdownStorageSection
                Divider()
                BrowserExtensionSection()
                Divider()
                permissionsSection
                Divider()
                eraseSection
            }
            .padding(20)
        }
    }

    // MARK: - Plain Markdown Storage

    /// Opt-in plain-markdown storage.
    ///
    /// Under Privacy because that is the real trade: documents stop being encrypted and
    /// become readable by anything on the Mac. Presenting it as a convenience feature
    /// would bury the part the user needs to weigh.
    private var markdownStorageSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("纯 Markdown 存储")
                .font(.headline)

            Text("将文档作为普通 .md 文件存储在主文件夹的 Logue 文件夹中，这样你可以在其他应用中编辑、"
                + "使用 git 跟踪，或让 AI 智能体读取。会议、转写和音频始终加密。")
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if storage.mode.isMarkdown {
                HStack(spacing: 8) {
                    Image(systemName: "folder")
                        .foregroundStyle(.secondary)
                    Text(DocumentStorage.markdownRootURL.path
                        .replacingOccurrences(of: NSHomeDirectory(), with: "~"))
                        .font(.callout)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Spacer()
                    Button("显示") {
                        NSWorkspace.shared.activateFileViewerSelecting(
                            [DocumentStorage.markdownRootURL]
                        )
                    }
                    .controlSize(.small)
                    Button("关闭") { showingDisableConfirmation = true }
                        .controlSize(.small)
                }

                Label("此文件夹中的文档未加密。", systemImage: "lock.open")
                    .font(.caption)
                    .foregroundStyle(.orange)
            } else {
                Button("开启…") { showingEnableWarning = true }
                    .controlSize(.small)
            }

            if let error = storageError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .sheet(isPresented: $showingEnableWarning) {
            MarkdownStorageWarningSheet { enableMarkdownStorage() }
        }
        .confirmationDialog(
            "关闭纯 Markdown 存储？",
            isPresented: $showingDisableConfirmation,
            titleVisibility: .visible
        ) {
            // Moving the folder to the Trash is the first and default choice deliberately. A
            // folder left behind looks like the library but is not one: nothing writes to it and
            // nothing reads it, so an edit made there silently does nothing. Keeping it is still
            // offered for anyone who tracks it in git or wants to move it themselves.
            Button("关闭并将文件夹移到废纸篓") { disableMarkdownStorage(retiringFolder: true) }
            Button("关闭并保留文件夹") { disableMarkdownStorage(retiringFolder: false) }
            Button("取消", role: .cancel) {}
        } message: {
            Text("你的文档会移回 Logue 的加密存储。此后 Logue 不再读取或写入 Logue 文件夹，"
                + "因此将文件夹留在原处意味着在那里所做的编辑不会生效。移到废纸篓可保留恢复的可能。")
        }
    }

    private func enableMarkdownStorage() {
        storageError = nil
        do {
            try storage.switchToMarkdown(
                documents: documentStore.documents,
                spaces: spaceStore.spaces,
                tasks: taskStore.tasks
            )
        } catch {
            // Nothing was changed: the switch verifies every file before flipping.
            storageError = error.localizedDescription
        }
    }

    private func disableMarkdownStorage(retiringFolder: Bool) {
        storageError = nil

        do {
            let restored = try storage.switchToEncrypted(
                knownSpaces: spaceStore.spaces,
                retiringFolder: retiringFolder,
                // What the folder has to account for. Fewer means files are missing rather than
                // deleted, and switching would prune the encrypted copies of the difference.
                expectedDocumentCount: documentStore.activeDocuments.count
            )

            // The switch already re-encrypted these; adopting them now means the list on
            // screen matches what encrypted storage holds before the folder can be trashed.
            taskStore.replaceAll(with: storage.restoredTasks)

            Task {
                // In this order, and awaited: the folder is the only copy of anything created while
                // the setting was on, so it cannot go to the Trash until every document is confirmed
                // written to encrypted storage. This used to be an unawaited task with log-only
                // failures, running *after* the folder had already been trashed.
                await documentStore.adoptAfterStorageSwitch(restored)
                await documentStore.awaitPendingSaves()

                guard retiringFolder else { return }
                do {
                    try storage.retireFolderAfterReEncryption(of: restored)
                } catch {
                    storageError = error.localizedDescription
                }
            }
        } catch {
            // Nothing was changed: the switch refuses before it reads rather than part-way through.
            storageError = error.localizedDescription
        }
    }

    // MARK: - Encryption

    private var encryptionSection: some View {
        sectionCard(title: "加密") {
            HStack(spacing: 10) {
                Image(systemName: "lock.fill")
                    .font(.title3)
                    .foregroundStyle(.green)
                VStack(alignment: .leading, spacing: 2) {
                    Text("AES-256-GCM 静态加密")
                        .font(.callout.weight(.semibold))
                    Text(encryptionDetail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    /// Reads the mode rather than asserting the default.
    ///
    /// The flat claim sat directly above the section explaining that documents are *not* encrypted
    /// once this setting is on — a contradiction on the one tab where a user goes to check exactly
    /// this.
    private var encryptionDetail: String {
        if storage.mode.isMarkdown {
            return "对话和会议在磁盘上加密，密钥绝不会离开这台 Mac。文档则不然：纯 Markdown 存储已开启，"
                + "因此它们是主文件夹中的可读文件。"
        }
        return "对话、会议和文档均在磁盘上加密。密钥绝不会离开这台 Mac。"
    }

    // MARK: - Data location

    private var dataLocationSection: some View {
        sectionCard(title: "数据位置") {
            VStack(alignment: .leading, spacing: 8) {
                Text(dataDirectory.path)
                    .font(.system(.caption, design: .monospaced))
                    .textSelection(.enabled)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.secondary.opacity(0.08))
                    )
                HStack(spacing: 8) {
                    Button {
                        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: dataDirectory.path)
                    } label: {
                        Label("在访达中显示", systemImage: "folder")
                    }
                    .controlSize(.small)
                    Spacer()
                }
            }
        }
    }

    // MARK: - Permissions summary

    private var permissionsSection: some View {
        sectionCard(title: "权限") {
            VStack(alignment: .leading, spacing: 6) {
                permissionRow(
                    icon: "mic",
                    title: "麦克风",
                    detail: "录制会议时使用，绝不会发送到设备外。"
                )
                permissionRow(
                    icon: "calendar",
                    title: "日历",
                    detail: "读取即将开始的事件，按请求创建/编辑/删除。"
                )
                permissionRow(
                    icon: "checklist",
                    title: "提醒事项",
                    detail: "按请求读取和写入提醒事项。"
                )
                permissionRow(
                    icon: "person.crop.circle",
                    title: "通讯录",
                    detail: "查找姓名和电子邮件地址以起草消息。"
                )
                permissionRow(
                    icon: "accessibility",
                    title: "辅助功能",
                    detail: "⌘⌃I 内联写作助手读取选中文本所必需。"
                )
                Button {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy") {
                        NSWorkspace.shared.open(url)
                    }
                } label: {
                    Label("打开系统设置 → 隐私", systemImage: "arrow.up.right.square")
                }
                .controlSize(.small)
                .padding(.top, 4)
            }
        }
    }

    private func permissionRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(width: 18)
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.callout.weight(.medium))
                Text(detail)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 3)
    }

    // MARK: - Erase

    private var eraseSection: some View {
        sectionCard(title: "重置") {
            VStack(alignment: .leading, spacing: 8) {
                Text("抹除所有设备端 Logue 数据，包括对话、会议、文档和向量存储。此操作无法撤销。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button(role: .destructive) {
                    showEraseConfirm = true
                } label: {
                    Label("抹除所有数据…", systemImage: "trash")
                }
                .controlSize(.small)
                .alert("抹除所有 Logue 数据？", isPresented: $showEraseConfirm) {
                    Button("取消", role: .cancel) {}
                    Button("抹除", role: .destructive) { eraseAllData() }
                } message: {
                    Text("这将从此 Mac 删除所有对话、会议和文档。此操作无法撤销。")
                }
            }
        }
    }

    // MARK: - Helpers

    private func sectionCard(
        title: String,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.callout.weight(.semibold))
            content()
        }
    }

    private static func dataDirectory() -> URL {
        let base = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first ?? URL.temporaryDirectory
        return base.appending(path: "Logue", directoryHint: .isDirectory)
    }

    private func eraseAllData() {
        do {
            let fm = FileManager.default
            if fm.fileExists(atPath: dataDirectory.path) {
                try fm.removeItem(at: dataDirectory)
            }

            // The unencrypted folder too, or "All data erased" is a false claim: with plain markdown
            // storage on, every document is a readable file outside this directory, and the setting
            // itself is in UserDefaults so the next launch would read them straight back in.
            if storage.mode.isMarkdown {
                try storage.eraseMarkdownFolder()
            }

            ToastCenter.shared.show("所有数据已抹除，请重启 Logue", kind: .warning)
        } catch {
            ToastCenter.shared.show("无法抹除数据", kind: .warning)
        }
    }
}
