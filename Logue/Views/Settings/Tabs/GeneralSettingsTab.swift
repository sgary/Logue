import ServiceManagement
import SwiftUI

/// Appearance mode preference for the app.
enum AppearanceMode: String, CaseIterable {
    case system
    case light
    case dark

    var displayName: String {
        switch self {
        case .system: "跟随系统"
        case .light: "浅色"
        case .dark: "深色"
        }
    }

    var icon: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light: "sun.max"
        case .dark: "moon"
        }
    }
}

/// Combined settings tab: Startup, Theme, Editor, Shortcuts, Data.
struct GeneralSettingsTab: View {
    /// The sheets this tab can put up. One case is showing at a time, which is what
    /// lets a single `.sheet(item:)` present all of them.
    enum Sheet: Identifiable {
        case welcomeTour
        case whatsNew(WhatsNewView.Mode)

        var id: String {
            switch self {
            case .welcomeTour: "welcomeTour"
            case .whatsNew: "whatsNew"
            }
        }
    }

    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled
    @AppStorage("appearanceMode") private var appearanceMode: AppearanceMode = .system
    @AppStorage("editorFontSize") private var editorFontSize: Double = 15
    @AppStorage(AppConstants.UserDefaultsKeys.defaultDocumentWidthMode) private var defaultDocumentWidthRaw =
        DocumentWidthMode.normal.rawValue
    @AppStorage(AppConstants.UserDefaultsKeys.autoSortCheckedItems) private var autoSortCheckedItems = false
    @AppStorage(AppConstants.UserDefaultsKeys.groupByDate) private var groupByDate = true
    @AppStorage(AppConstants.UserDefaultsKeys.hasClearedSeedData) private var hasClearedSeedData = false
    @AppStorage(AppConstants.UserDefaultsKeys.autoSaveSummaryToDocument) private var autoSaveSummaryToDocument = true
    @AppStorage(AppConstants.UserDefaultsKeys.sidebarSpaceSortOrder) private var sidebarSpaceSortOrderRaw = SidebarSpaceSortOrder.custom.rawValue
    @AppStorage(AppConstants.UserDefaultsKeys.webSearchEnabled) private var webSearchEnabled = false

    @State private var shortcutManager = ShortcutManager.shared

    @Environment(DocumentStore.self) private var documentStore
    @Environment(MeetingStore.self) private var meetingStore
    @Environment(SpaceStore.self) private var spaceStore

    @State private var showClearConfirmation = false
    @State private var showLoadConfirmation = false
    /// The one sheet this tab presents, if any.
    ///
    /// Item-driven rather than two booleans: `LogueApp` records that two boolean
    /// `.sheet` modifiers on one view do not reliably both present, and this tab had
    /// exactly that pair — so one of these buttons was relying on behaviour the app
    /// documents as unreliable. One modifier cannot have the problem.
    @State private var sheet: Sheet?

    var body: some View {
        Form {
            Section("启动") {
                Toggle("登录时启动", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { _, newValue in
                        do {
                            if newValue {
                                try SMAppService.mainApp.register()
                            } else {
                                try SMAppService.mainApp.unregister()
                            }
                        } catch {
                            launchAtLogin = !newValue
                        }
                    }
                Button {
                    sheet = .welcomeTour
                } label: {
                    Label("显示欢迎引导", systemImage: "sparkles")
                }
                .buttonStyle(.borderless)
                Button {
                    // Resolved when the button is pressed, not when the tab is built:
                    // the backlog it shows depends on the stamp, which the launch deck
                    // may have moved since.
                    sheet = .whatsNew(WhatsNewView.Mode.askedForByName())
                } label: {
                    Label(UICopy.WhatsNew.settingsButton, systemImage: "gift")
                }
                .buttonStyle(.borderless)
            }

            Section("主题") {
                Picker("外观", selection: $appearanceMode) {
                    ForEach(AppearanceMode.allCases, id: \.self) { mode in
                        Label(mode.displayName, systemImage: mode.icon).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: appearanceMode) {
                    applyAppearance()
                }
            }

            Section("侧边栏") {
                Picker("空间排序方式", selection: Binding(
                    get: { SidebarSpaceSortOrder(rawValue: sidebarSpaceSortOrderRaw) ?? .custom },
                    set: { sidebarSpaceSortOrderRaw = $0.rawValue }
                )) {
                    ForEach(SidebarSpaceSortOrder.allCases, id: \.self) { order in
                        Text(order.label).tag(order)
                    }
                }
                .onChange(of: sidebarSpaceSortOrderRaw) {
                    spaceStore.sortRevision += 1
                }
            }

            Section("编辑器") {
                HStack {
                    Text("字号")
                    Spacer()
                    Text("\(Int(editorFontSize)) pt")
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
                Slider(value: $editorFontSize, in: 12 ... 24, step: 1) {
                    Text("字号")
                } minimumValueLabel: {
                    Text("12").font(.caption)
                } maximumValueLabel: {
                    Text("24").font(.caption)
                }

                Picker("默认文档宽度", selection: Binding(
                    get: { DocumentWidthMode(rawValue: defaultDocumentWidthRaw) ?? .normal },
                    set: { defaultDocumentWidthRaw = $0.rawValue }
                )) {
                    ForEach(DocumentWidthMode.allCases, id: \.self) { mode in
                        Text(mode.label).tag(mode)
                    }
                }
                Text("仅应用于此后新建的文档。现有文档保留各自的宽度。")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Toggle(isOn: $autoSortCheckedItems) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("自动排序已勾选项目")
                        Text("勾选清单项后将其移到底部。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Toggle(isOn: $groupByDate) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("按日期分组笔记")
                        Text("将文档和会议分到“今天”“昨天”等分组中。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("会议") {
                Toggle(isOn: $autoSaveSummaryToDocument) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("自动将摘要保存为文档")
                        Text("录音结束后，自动根据会议摘要创建关联文档。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("快捷键") {
                ShortcutRow(
                    title: "询问 Logue",
                    shortcut: $shortcutManager.commandCenterShortcut
                ) { newShortcut in
                    shortcutManager.updateCommandCenterShortcut(newShortcut)
                }
            }

            Section("询问 Logue") {
                Toggle(isOn: $webSearchEnabled) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("启用网页搜索")
                        Text(
                            "允许智能体通过 DuckDuckGo 搜索并抓取公开网页。"
                                + "默认关闭，启用前 Logue 保持完全本地运行。"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
            }

            Section("数据") {
                if hasClearedSeedData {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("示例数据")
                            Text("加载示例文档、会议和空间。")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button("加载示例") {
                            showLoadConfirmation = true
                        }
                        .controlSize(.small)
                    }
                } else {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("示例数据")
                            Text("移除所有示例文档、会议和空间。")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button("清除示例", role: .destructive) {
                            showClearConfirmation = true
                        }
                        .controlSize(.small)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .sheet(item: $sheet) { sheet in
            switch sheet {
            case .welcomeTour: OnboardingV2View()
            case let .whatsNew(mode): WhatsNewView(mode: mode)
            }
        }
        .onAppear { applyAppearance() }
        .confirmationDialog(
            "清除所有示例数据？",
            isPresented: $showClearConfirmation,
            titleVisibility: .visible
        ) {
            Button("清除示例", role: .destructive) {
                documentStore.clearAllData()
                meetingStore.clearAllData()
                spaceStore.clearAllData()
                TaskStore.shared.clearAllData()
                hasClearedSeedData = true
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("这将移除所有示例文档、会议和空间。此操作无法撤销。")
        }
        .confirmationDialog(
            "加载示例数据？",
            isPresented: $showLoadConfirmation,
            titleVisibility: .visible
        ) {
            Button("加载示例") {
                loadSeedData()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("这会将示例文档、会议和空间添加到你的资料库。")
        }
    }

    private func loadSeedData() {
        documentStore.documents = DocumentStore.makeSeedDocuments()
        documentStore.rebuildIndexMap()
        documentStore.loadedSeedData = true
        documentStore.saveToDisk()
        meetingStore.meetings = MeetingStore.makeSeedMeetings()
        meetingStore.rebuildIndexMap()
        meetingStore.loadedSeedData = true
        meetingStore.saveToDisk()
        spaceStore.spaces = SpaceStore.makeSeedSpaces()
        spaceStore.loadedSeedData = true
        spaceStore.saveToDisk()
        hasClearedSeedData = false
    }

    private func applyAppearance() {
        let appearance: NSAppearance? = switch appearanceMode {
        case .system: nil
        case .light: NSAppearance(named: .aqua)
        case .dark: NSAppearance(named: .darkAqua)
        }
        NSApp.appearance = appearance
    }
}
