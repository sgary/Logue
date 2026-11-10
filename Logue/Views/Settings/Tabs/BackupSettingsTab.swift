import SwiftUI

/// Settings tab for exporting, importing, and iCloud backup of app data.
struct BackupSettingsTab: View {
    @Environment(MeetingStore.self) private var meetingStore
    @Environment(DocumentStore.self) private var documentStore
    @Environment(SpaceStore.self) private var spaceStore

    @State private var backupManager = BackupManager.shared
    @State private var importMode: BackupManager.ImportMode = .merge
    @State private var showImportConfirmation = false
    @State private var showReplaceWarning = false
    @State private var showICloudRestoreConfirmation = false
    @State private var showICloudReplaceWarning = false
    @State private var selectedICloudEntry: BackupManager.ICloudBackupEntry?

    var body: some View {
        Form {
            iCloudSection
            localExportSection
            localImportSection

            // MARK: - Status

            if let message = backupManager.statusMessage {
                Section {
                    Label(
                        message,
                        systemImage: message.contains("失败") ? "exclamationmark.triangle" : "checkmark.circle"
                    )
                    .font(.callout)
                    .foregroundStyle(message.contains("失败") ? .red : AppThemeConstants.success)
                }
            }

            // MARK: - Privacy

            Section {
                PrivacyBadge(
                    "本地备份保留在你的 Mac 上。iCloud 备份由 Apple 端到端加密。",
                    style: .standard
                )
            } header: {
                Text("隐私与安全")
            }
        }
        .formStyle(.grouped)
        .onAppear { backupManager.refreshICloudBackups() }
        .confirmationDialog("导入备份？", isPresented: $showImportConfirmation, titleVisibility: .visible) {
            Button("导入并合并") { performLocalImport(mode: .merge) }
            Button("取消", role: .cancel) {}
        } message: {
            Text("备份中的新项目将被添加，现有项目不会改变。")
        }
        .confirmationDialog("替换所有数据？", isPresented: $showReplaceWarning, titleVisibility: .visible) {
            Button("替换所有数据", role: .destructive) { performLocalImport(mode: .replace) }
            Button("取消", role: .cancel) {}
        } message: {
            Text("这将删除当前所有数据并替换为备份内容。此操作无法撤销。")
        }
        .confirmationDialog(
            "从 iCloud 恢复？",
            isPresented: $showICloudRestoreConfirmation,
            titleVisibility: .visible
        ) {
            Button("与现有数据合并") { restoreSelectedICloudBackup(mode: .merge) }
            Button("取消", role: .cancel) {}
        } message: {
            if let entry = selectedICloudEntry {
                Text("这会将 \(entry.id) 的数据合并到当前数据中。")
            }
        }
        .confirmationDialog(
            "从 iCloud 替换所有数据？",
            isPresented: $showICloudReplaceWarning,
            titleVisibility: .visible
        ) {
            Button("替换所有数据", role: .destructive) { restoreSelectedICloudBackup(mode: .replace) }
            Button("取消", role: .cancel) {}
        } message: {
            Text("这将删除当前所有数据并替换为 iCloud 备份内容。此操作无法撤销。")
        }
    }

    // MARK: - iCloud Section

    private var iCloudSection: some View {
        Section {
            if backupManager.isICloudAvailable {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("iCloud 云盘", systemImage: "icloud.fill")
                            .font(.callout.weight(.medium))
                            .foregroundStyle(AppThemeConstants.accent)

                        Spacer()

                        Button {
                            backupManager.backupToiCloud(
                                meetingStore: meetingStore,
                                documentStore: documentStore,
                                spaceStore: spaceStore
                            )
                        } label: {
                            if backupManager.isSyncingToiCloud {
                                ProgressView()
                                    .controlSize(.small)
                            } else {
                                Label("立即备份", systemImage: "icloud.and.arrow.up")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppThemeConstants.accent)
                        .controlSize(.small)
                        .disabled(backupManager.isSyncingToiCloud)
                        .accessibilityLabel("备份到 iCloud")
                        .accessibilityHint("将加密备份保存到你的 iCloud 云盘")
                    }

                    Text("备份会在上传前加密。即使卸载 Logue，备份仍会保留。")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let lastSync = backupManager.lastICloudBackupDate {
                        Text("上次 iCloud 备份：\(lastSync.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }

                    // iCloud backup list
                    if !backupManager.iCloudBackups.isEmpty {
                        Divider()

                        Text("可用的 iCloud 备份")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)

                        ForEach(backupManager.iCloudBackups) { entry in
                            iCloudBackupRow(entry)
                        }
                    }
                }
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "icloud.slash")
                        .foregroundStyle(.secondary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("iCloud 不可用")
                            .font(.callout.weight(.medium))
                        Text("请在系统设置中登录 iCloud 以启用云备份。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        } header: {
            Text("iCloud 备份")
        }
    }

    private func iCloudBackupRow(_ entry: BackupManager.ICloudBackupEntry) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                Text(ByteCountFormatter.string(fromByteCount: entry.size, countStyle: .file))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            Menu {
                Button {
                    selectedICloudEntry = entry
                    showICloudRestoreConfirmation = true
                } label: {
                    Label("恢复（合并）", systemImage: "arrow.down.circle")
                }

                Button {
                    selectedICloudEntry = entry
                    showICloudReplaceWarning = true
                } label: {
                    Label("恢复（替换全部）", systemImage: "arrow.counterclockwise.circle")
                }

                Divider()

                Button(role: .destructive) {
                    backupManager.deleteICloudBackup(entry)
                } label: {
                    Label("删除备份", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .menuStyle(.borderlessButton)
            .frame(width: 24)
            .accessibilityLabel("\(entry.date.formatted(date: .abbreviated, time: .shortened)) 的备份选项")
        }
    }

    // MARK: - Local Export Section

    private var localExportSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text("导出为 Mac 上的文件。")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                HStack {
                    dataSummary

                    Spacer()

                    Button {
                        backupManager.exportBackup(
                            meetingStore: meetingStore,
                            documentStore: documentStore,
                            spaceStore: spaceStore
                        )
                    } label: {
                        Label("导出到文件", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .disabled(backupManager.isExporting)
                    .accessibilityLabel("将备份导出到文件")
                    .accessibilityHint("将所有数据保存到本地文件")
                }

                if let lastExport = backupManager.lastExportDate {
                    Text("上次本地导出：\(lastExport.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        } header: {
            Text("本地导出")
        }
    }

    // MARK: - Local Import Section

    private var localImportSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text("从本地备份文件恢复。")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                Picker("导入模式", selection: $importMode) {
                    Text("合并 — 添加新项目，保留现有项目").tag(BackupManager.ImportMode.merge)
                    Text("替换 — 覆盖当前所有数据").tag(BackupManager.ImportMode.replace)
                }
                .pickerStyle(.radioGroup)
                .accessibilityLabel("导入模式")

                HStack {
                    Spacer()

                    Button {
                        if importMode == .replace {
                            showReplaceWarning = true
                        } else {
                            showImportConfirmation = true
                        }
                    } label: {
                        Label("从文件导入", systemImage: "square.and.arrow.down")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .disabled(backupManager.isImporting)
                    .accessibilityLabel("从文件导入备份")
                    .accessibilityHint("从本地备份文件恢复数据")
                }
            }
        } header: {
            Text("本地导入")
        }
    }

    // MARK: - Helpers

    private var dataSummary: some View {
        HStack(spacing: 16) {
            summaryItem(count: meetingStore.meetings.count, label: "场会议", icon: "mic.fill")
            summaryItem(count: documentStore.documents.count, label: "个文档", icon: "doc.text.fill")
            summaryItem(count: spaceStore.spaces.count, label: "个空间", icon: "folder.fill")
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }

    private func summaryItem(count: Int, label: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text("\(count) \(label)")
        }
        .accessibilityElement(children: .combine)
    }

    private func performLocalImport(mode: BackupManager.ImportMode) {
        backupManager.importBackup(
            meetingStore: meetingStore,
            documentStore: documentStore,
            spaceStore: spaceStore,
            mode: mode
        )
    }

    private func restoreSelectedICloudBackup(mode: BackupManager.ImportMode) {
        guard let entry = selectedICloudEntry else { return }
        backupManager.restoreFromiCloud(
            entry: entry,
            meetingStore: meetingStore,
            documentStore: documentStore,
            spaceStore: spaceStore,
            mode: mode
        )
    }
}
