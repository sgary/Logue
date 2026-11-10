import AppKit
import SwiftUI

/// The Tasks surface: capture at the top, the app's filter chips and toolbar, the list below.
///
/// Shares its chrome with the action item inbox on purpose — the two screens are one idea
/// (what the model found, and what you accepted), and a red chip means the same thing on
/// both.
struct TaskListView: View {
    @State private var store = TaskStore.shared
    @State private var meetingStore = MeetingStore.shared

    @AppStorage(AppConstants.UserDefaultsKeys.taskFilterMode)
    private var filterModeRaw = TaskFilterMode.all.rawValue
    @AppStorage(AppConstants.UserDefaultsKeys.taskSortOrder)
    private var sortOrderRaw = TaskSortOrder.dueDateAsc.rawValue

    @State private var searchText = ""
    @State private var selectedTag: String?
    @State private var selectedTaskID: UUID?
    /// Incremented by the toolbar's + button to focus the capture field.
    @State private var focusRequest = 0
    @State private var triageService = TaskTriageService.shared
    @State private var engineStatus = LLMEngineStatus.shared
    @State private var showTriage = false

    private var filterMode: TaskFilterMode {
        TaskFilterMode(rawValue: filterModeRaw) ?? .all
    }

    private var sortOrder: TaskSortOrder {
        TaskSortOrder(rawValue: sortOrderRaw) ?? .dueDateAsc
    }

    private var visibleTasks: [TaskItem] {
        TaskFilter.sort(
            TaskFilter.apply(
                store.tasks, mode: filterMode, tag: selectedTag, searchText: searchText
            ),
            by: sortOrder
        )
    }

    private var counts: [TaskFilterMode: Int] {
        var result: [TaskFilterMode: Int] = [:]
        for mode in TaskFilterMode.allCases {
            result[mode] = TaskFilter.apply(store.tasks, mode: mode, tag: selectedTag).count
        }
        return result
    }

    // MARK: - Body

    /// The selected task, re-read from the store rather than held, so an edit applied
    /// anywhere (the inspector, triage, a completion toggle) is what the inspector shows.
    private var selectedTask: TaskItem? {
        guard let selectedTaskID else { return nil }
        return store.task(id: selectedTaskID)
    }

    var body: some View {
        HStack(spacing: 0) {
            listPane

            if let selectedTask {
                Divider()
                TaskInspectorPanel(
                    task: selectedTask,
                    meetingTitle: meetingTitle(for: selectedTask),
                    onChange: { store.update($0) },
                    onCommitText: { commit in
                        // Applied to the record as it stands, not to the copy the panel was
                        // showing when the field was first focused, and only the fields the
                        // commit actually carries.
                        guard let latest = store.tasks.first(where: { $0.id == commit.taskID }),
                              let updated = commit.applied(to: latest)
                        else { return }
                        store.update(updated)
                    },
                    onDelete: {
                        store.delete(id: selectedTask.id)
                        selectedTaskID = nil
                    },
                    onOpenSource: { openSource(for: selectedTask) },
                    onClose: { selectedTaskID = nil }
                )
                .transition(.move(edge: .trailing))
            }
        }
        .animation(.easeOut(duration: 0.15), value: selectedTaskID)
    }

    private var listPane: some View {
        VStack(spacing: 0) {
            TaskQuickAddField(
                onCapture: { text in store.capture(text) },
                focusRequest: focusRequest
            )
            .padding(.horizontal, 24)
            .padding(.top, 12)

            filterChipBar
            Divider()

            if visibleTasks.isEmpty {
                emptyState
            } else {
                taskList
            }
        }
        .background(AppThemeConstants.contentBackground)
        .navigationTitle("任务")
        .navigationSubtitle(subtitle)
        .searchable(text: $searchText, placement: .toolbar, prompt: "搜索任务")
        .toolbar {
            toolbarContent
        }
        .sheet(isPresented: $showTriage) {
            triageSheet
        }
    }

    private var subtitle: String {
        let total = visibleTasks.count
        return "\(total) 个任务"
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            // Capture is the field at the top of the list, but a field is not what people
            // look for when they want to add something — they look for a plus. This puts one
            // where it is expected and sends the cursor to the field.
            Button {
                focusRequest += 1
            } label: {
                Image(systemName: "plus")
            }
            .help("添加任务")
            .accessibilityLabel("添加任务")
            .keyboardShortcut("n", modifiers: [.command, .shift])

            Button {
                showTriage = true
                Task {
                    await triageService.run(tasks: store.tasks, knownTags: store.allTags)
                }
            } label: {
                Image(systemName: "sparkles")
            }
            // Concurrent inference races on the shared session; this is the project-wide
            // guard for any control that reaches the engine.
            .disabled(engineStatus.isBusy || store.openTasks.isEmpty)
            .help("让 Logue 检查你的未完成任务")
            .accessibilityLabel("分诊任务")

            sortMenu
        }
    }

    private var sortMenu: some View {
        Menu {
            Picker("排序", selection: $sortOrderRaw) {
                ForEach(TaskSortOrder.allCases, id: \.rawValue) { order in
                    Text(order.displayName).tag(order.rawValue)
                }
            }
            if !store.allTags.isEmpty {
                Divider()
                Button("所有标签") { selectedTag = nil }
                ForEach(store.allTags, id: \.self) { tag in
                    Button(tag) { selectedTag = tag }
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down.circle")
        }
        .help("排序与筛选")
        .accessibilityLabel("排序任务")
    }

    // MARK: - Filter Chip Bar

    private var filterChipBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(TaskFilterMode.allCases, id: \.rawValue) { mode in
                    let count = counts[mode] ?? 0
                    FilterChip(
                        label: "\(mode.displayName) \(count)",
                        isSelected: filterMode == mode,
                        tintColor: tintColor(for: mode)
                    ) {
                        filterModeRaw = mode.rawValue
                    }
                    .accessibilityLabel("\(mode.displayName)，\(count) 个任务")
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
        }
    }

    /// The same mapping the action item chips use, so a red chip means the same thing on
    /// both screens.
    private func tintColor(for mode: TaskFilterMode) -> Color? {
        switch mode {
        case .overdue: AppThemeConstants.error
        case .today, .upcoming: AppThemeConstants.warning
        case .completed: AppThemeConstants.success
        default: nil
        }
    }

    // MARK: - List

    private var taskList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(visibleTasks) { task in
                    TaskRowView(
                        task: task,
                        meetingTitle: meetingTitle(for: task),
                        isSelected: task.id == selectedTaskID,
                        onToggle: { store.toggleCompletion(id: task.id) },
                        onOpenSource: { openSource(for: task) },
                        onSelect: { selectedTaskID = task.id },
                        onRename: { store.update(TaskEdit.renamed(task, to: $0)) }
                    )
                    .contextMenu {
                        priorityMenu(for: task)
                        Divider()
                        Button("删除", role: .destructive) {
                            if selectedTaskID == task.id {
                                selectedTaskID = nil
                            }
                            store.delete(id: task.id)
                        }
                    }
                    if task.id != visibleTasks.last?.id {
                        Divider().padding(.leading, 44)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
        }
    }

    private func priorityMenu(for task: TaskItem) -> some View {
        Menu("优先级") {
            ForEach(TaskPriority.allCases, id: \.rawValue) { priority in
                Button {
                    var updated = task
                    updated.priority = priority
                    store.update(updated)
                } label: {
                    Label(priority.displayName, systemImage: priority.symbolName)
                }
            }
        }
    }

    private var triageSheet: some View {
        VStack(alignment: .trailing, spacing: 0) {
            TaskTriagePanelView()
            Button("完成") {
                showTriage = false
                triageService.clear()
            }
            .keyboardShortcut(.defaultAction)
            .padding([.trailing, .bottom], 16)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView {
            Label(emptyTitle, systemImage: emptyIcon)
        } description: {
            Text(emptyDescription)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyTitle: String {
        if !searchText.isEmpty {
            return "没有匹配的任务"
        }
        switch filterMode {
        case .all: return "这里还没有内容"
        case .today: return "今天没有到期任务"
        case .overdue: return "没有逾期任务"
        case .upcoming: return "没有即将到期的任务"
        case .noDueDate: return "所有任务都有日期"
        case .completed: return "没有已完成的任务"
        }
    }

    private var emptyIcon: String {
        if !searchText.isEmpty {
            return "magnifyingglass"
        }
        switch filterMode {
        case .overdue, .today, .upcoming: return "checkmark.circle"
        case .completed: return "circle"
        default: return "checklist"
        }
    }

    private var emptyDescription: String {
        if !searchText.isEmpty {
            return "没有与“\(searchText)”匹配的任务"
        }
        switch filterMode {
        case .all: return "在上方输入即可添加任务。例如：“明天发送演示文稿 #发布 !”。"
        case .today: return "今天没有任务到期。"
        case .overdue: return "没有任务逾期。"
        case .upcoming: return "没有安排在未来。"
        case .noDueDate: return "所有未完成任务都有截止日期。"
        case .completed: return "已完成的任务会显示在这里。"
        }
    }

    // MARK: - Source Meeting

    private func meetingTitle(for task: TaskItem) -> String? {
        guard let id = task.sourceMeetingID else { return nil }
        return meetingStore.meetings.first { $0.id == id }?.title
    }

    /// Built through `DeepLink` rather than by assembling a string, so the scheme and host
    /// stay in one place.
    private func openSource(for task: TaskItem) {
        guard let id = task.sourceMeetingID else { return }
        NSWorkspace.shared.open(DeepLink.meeting(id: id).url)
    }
}
