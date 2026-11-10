import SwiftUI

/// Right panel showing action items extracted from the meeting.
struct MeetingActionItemsPanelView: View {
    @Environment(MeetingStore.self) private var store
    @Environment(RecordingSessionManager.self) private var recorder
    let meeting: MeetingNote
    @State private var extractionMessage: String?

    private var isExtracting: Bool {
        store.generatingMeetingIDs.contains(meeting.id)
    }

    private var hasSummary: Bool {
        meeting.smartMinutes != nil || meeting.summary != nil
    }

    private var isLiveRecording: Bool {
        recorder.isRecording && recorder.currentMeetingID == meeting.id
    }

    /// Whether pressing "Start Meeting" would actually start one.
    ///
    /// `isRecovering` is in here because neither of the other two flags is set while an
    /// interrupted session is being rebuilt — so the button rendered enabled, `startRecording`
    /// refused, and nothing told the user why.
    private var canStartMeeting: Bool {
        meeting.segments.isEmpty && !recorder.isRecording && !recorder.isStartingRecording
            && !recorder.isRecovering
    }

    var body: some View {
        Group {
            if isExtracting, meeting.actionItems.isEmpty {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(0.9)
                    VStack(spacing: 4) {
                        Text("正在提取待办事项…")
                            .font(.callout.weight(.medium))
                        Text("使用设备端 AI 识别任务")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if meeting.actionItems.isEmpty {
                EmptyStateView(
                    icon: "checklist",
                    title: extractionMessage != nil ? "未找到待办事项" : "暂无待办事项",
                    description: extractionMessage
                        ?? (meeting.segments.isEmpty
                            ? "开始会议以提取待办事项。"
                            : (hasSummary
                                ? "点击从现有摘要中提取待办事项。"
                                : "生成摘要后将自动提取待办事项。")),
                    actionLabel: meeting.segments.isEmpty
                        ? (canStartMeeting ? "开始会议" : nil)
                        : (extractionMessage != nil ? "重试" : (hasSummary ? "提取待办事项" : "生成摘要")),
                    action: meeting.segments.isEmpty
                        ? (canStartMeeting ? {
                            Task { await recorder.startRecording(for: meeting) }
                        } : nil)
                        : (isExtracting ? nil : {
                            extractionMessage = nil
                            if let smartMinutes = meeting.smartMinutes, !smartMinutes.actionItems.isEmpty {
                                let items = smartMinutes.actionItems.map { ActionItem(title: $0) }
                                store.setActionItems(items, for: meeting.id)
                            } else {
                                Task {
                                    let result = await store.generateAISummary(for: meeting.id)
                                    switch result {
                                    case .success:
                                        break // Action items will appear via observation
                                    case .noActionItems:
                                        extractionMessage = "未在本次会议的转写中找到待办事项。你可以重试。"
                                    case let .failed(error):
                                        extractionMessage = "提取待办事项失败：\(error)"
                                    case .skipped:
                                        extractionMessage = "AI 模型尚未加载。请检查“设置”→“模型”。"
                                    }
                                }
                            }
                        })
                )
            } else {
                VStack(spacing: 0) {
                    actionItemsControlsBar
                    Divider()

                    List {
                        Section {
                            ForEach(meeting.actionItems) { item in
                                ActionItemRow(
                                    item: item,
                                    meetingID: meeting.id,
                                    meetingTitle: meeting.title
                                )
                                .listRowSeparator(.visible)
                            }
                        }
                    }
                    .listStyle(.inset)
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .background(AppThemeConstants.surfaceBackground)
        .task {
            if meeting.actionItems.isEmpty,
               let smartMinutes = meeting.smartMinutes,
               !smartMinutes.actionItems.isEmpty
            {
                let items = smartMinutes.actionItems.map { ActionItem(title: $0) }
                store.setActionItems(items, for: meeting.id)
            }
        }
    }

    private var completedCount: Int {
        meeting.actionItems.filter(\.isCompleted).count
    }

    // MARK: - Top Controls Bar

    private var actionItemsControlsBar: some View {
        HStack(spacing: 8) {
            Text("已完成 \(completedCount)/\(meeting.actionItems.count)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            if isLiveRecording {
                if isExtracting {
                    HStack(spacing: 6) {
                        ProgressView()
                            .controlSize(.small)
                        Text("正在更新…")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Button {
                        extractionMessage = nil
                        Task {
                            let result = await store.generateAISummary(for: meeting.id)
                            switch result {
                            case .success:
                                break
                            case .noActionItems:
                                extractionMessage = "最新转写中未发现新的待办事项。"
                            case let .failed(error):
                                extractionMessage = "更新待办事项失败：\(error)"
                            case .skipped:
                                extractionMessage = "AI 模型尚未加载。请检查“设置”→“模型”。"
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.trianglehead.2.clockwise")
                            Text("更新")
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .disabled(isExtracting || recorder.postRecordingPipeline.isGenerating(for: meeting.id))
                    .help("使用最新转写重新提取待办事项")
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

// MARK: - Action Item Row

private struct ActionItemRow: View {
    @Environment(MeetingStore.self) private var store
    @State private var taskStore = TaskStore.shared
    let item: ActionItem
    let meetingID: UUID
    let meetingTitle: String

    @State private var showDatePicker = false
    @State private var showReminderPicker = false
    @State private var selectedDueDate = Date()
    @State private var selectedReminderDate = Date()

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Button {
                store.toggleActionItemCompleted(itemID: item.id, in: meetingID)
            } label: {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.body)
                    .foregroundColor(item.isCompleted ? AppThemeConstants.success : .secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(item.isCompleted ? "标记为未完成" : "标记为完成")

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.callout)
                    .strikethrough(item.isCompleted)
                    .foregroundStyle(item.isCompleted ? .secondary : .primary)

                // Metadata: assignee + due date on line 1, reminder on line 2
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        if let assignee = item.assignee {
                            Label(assignee, systemImage: "person")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        if !item.isCompleted {
                            dueDateControl
                        } else if let due = item.dueDescription, item.dueDate == nil {
                            Label(due, systemImage: "calendar")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if !item.isCompleted {
                        reminderControl
                    }
                }
            }

            Spacer()

            taskMarker
        }
        .padding(.vertical, 2)
    }

    // MARK: - Task Marker

    /// The task this action item was promoted into, if any.
    ///
    /// Read-only on purpose. Writing the task's status back into the meeting would edit a
    /// record of what was said because the user later changed their mind about the work.
    private var promotedTask: TaskItem? {
        taskStore.promotedTask(for: item.id)
    }

    @ViewBuilder
    private var taskMarker: some View {
        if let promotedTask {
            let isDone = promotedTask.status == .done
            Label(
                isDone ? "已在任务中完成" : "在任务中",
                systemImage: isDone ? "checkmark.circle.fill" : "arrow.right.circle"
            )
            .font(.caption)
            .foregroundStyle(.tertiary)
            .help("此待办事项已添加到你的任务")
        }
    }

    // MARK: - Due Date Control

    @ViewBuilder
    private var dueDateControl: some View {
        if let dueDate = item.dueDate {
            Button {
                selectedDueDate = dueDate
                showDatePicker = true
            } label: {
                Label(dueDate.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(dueDateColor(dueDate).opacity(AppThemeConstants.activeOpacity), in: Capsule())
                    .foregroundStyle(dueDateColor(dueDate))
                    .fixedSize()
            }
            .buttonStyle(.plain)
            .accessibilityLabel("截止 \(dueDate.formatted(date: .abbreviated, time: .omitted))")
            .popover(isPresented: $showDatePicker, arrowEdge: .bottom) {
                dueDatePopover
            }
        } else {
            Button {
                selectedDueDate = Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
                showDatePicker = true
            } label: {
                Label("设置截止日期", systemImage: "calendar.badge.plus")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showDatePicker, arrowEdge: .bottom) {
                dueDatePopover
            }
        }
    }

    // MARK: - Reminder Control

    @ViewBuilder
    private var reminderControl: some View {
        if let reminderDate = item.reminderDate {
            Button {
                selectedReminderDate = reminderDate
                showReminderPicker = true
            } label: {
                Label(reminderDate.formatted(date: .abbreviated, time: .shortened), systemImage: "bell.fill")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppThemeConstants.accent.opacity(0.12), in: Capsule())
                    .foregroundStyle(AppThemeConstants.accent)
                    .fixedSize()
            }
            .buttonStyle(.plain)
            .accessibilityLabel("提醒时间：\(reminderDate.formatted(date: .abbreviated, time: .shortened))")
            .popover(isPresented: $showReminderPicker, arrowEdge: .bottom) {
                reminderPopover
            }
        } else {
            Button {
                if let dueDate = item.dueDate {
                    selectedReminderDate = dueDate.addingTimeInterval(-3600)
                } else {
                    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
                    selectedReminderDate = Calendar.current.date(
                        bySettingHour: 9, minute: 0, second: 0, of: tomorrow
                    ) ?? tomorrow
                }
                showReminderPicker = true
            } label: {
                Image(systemName: "bell")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .buttonStyle(.plain)
            .help("设置提醒")
            .accessibilityLabel("设置提醒")
            .popover(isPresented: $showReminderPicker, arrowEdge: .bottom) {
                reminderPopover
            }
        }
    }

    // MARK: - Due Date Popover

    private var dueDatePopover: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("截止日期")
                .font(.subheadline.weight(.semibold))

            HStack(spacing: 6) {
                dueDatePreset("今天", date: Calendar.current.date(
                    bySettingHour: 17, minute: 0, second: 0, of: .now
                ))
                dueDatePreset("明天", date: Calendar.current.date(
                    bySettingHour: 9, minute: 0, second: 0,
                    of: Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
                ))
                dueDatePreset("下周", date: Calendar.current.date(
                    byAdding: .weekOfYear, value: 1, to: .now
                ))
            }

            Divider()

            DatePicker("自定义：", selection: $selectedDueDate, displayedComponents: [.date])
                .datePickerStyle(.field)
                .font(.caption)

            HStack {
                if item.dueDate != nil {
                    Button("移除") {
                        store.setActionItemDueDate(nil, itemID: item.id, in: meetingID)
                        showDatePicker = false
                    }
                    .foregroundStyle(AppThemeConstants.error)
                }

                Spacer()

                Button("设置") {
                    store.setActionItemDueDate(selectedDueDate, itemID: item.id, in: meetingID)
                    showDatePicker = false
                }
                .buttonStyle(.borderedProminent)
                .tint(AppThemeConstants.accent)
                .controlSize(.small)
            }
        }
        .padding(AppThemeConstants.paddingMedium)
        .frame(width: 260)
    }

    private func dueDatePreset(_ label: String, date: Date?) -> some View {
        Button(label) {
            if let date {
                store.setActionItemDueDate(date, itemID: item.id, in: meetingID)
                showDatePicker = false
            }
        }
        .font(.caption)
        .buttonStyle(.bordered)
        .controlSize(.small)
    }

    // MARK: - Reminder Popover

    private var reminderPopover: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("提醒")
                .font(.subheadline.weight(.semibold))

            VStack(spacing: 4) {
                reminderPreset("1 小时后", date: Date.now.addingTimeInterval(3600))
                reminderPreset("3 小时后", date: Date.now.addingTimeInterval(10800))
                reminderPreset("明天上午 9 点", date: Calendar.current.date(
                    bySettingHour: 9, minute: 0, second: 0,
                    of: Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
                ))
                if let dueDate = item.dueDate, dueDate > Date.now.addingTimeInterval(3600) {
                    reminderPreset(
                        "截止前 1 小时",
                        date: dueDate.addingTimeInterval(-3600)
                    )
                }
            }

            Divider()

            DatePicker("自定义：", selection: $selectedReminderDate, in: Date.now..., displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.field)
                .font(.caption)

            HStack {
                if item.reminderDate != nil {
                    Button("移除") {
                        store.cancelActionItemReminder(itemID: item.id, in: meetingID)
                        showReminderPicker = false
                    }
                    .foregroundStyle(AppThemeConstants.error)
                }

                Spacer()

                Button("设置") {
                    store.setActionItemReminder(
                        itemID: item.id,
                        in: meetingID,
                        reminderDate: selectedReminderDate
                    )
                    showReminderPicker = false
                }
                .buttonStyle(.borderedProminent)
                .tint(AppThemeConstants.accent)
                .controlSize(.small)
            }
        }
        .padding(AppThemeConstants.paddingMedium)
        .frame(width: 260)
    }

    private func reminderPreset(_ label: String, date: Date?) -> some View {
        Button {
            if let date {
                store.setActionItemReminder(
                    itemID: item.id,
                    in: meetingID,
                    reminderDate: date
                )
                showReminderPicker = false
            }
        } label: {
            HStack {
                Image(systemName: "bell")
                    .font(.caption2)
                Text(label)
                    .font(.caption)
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: AppThemeConstants.radiusSmall))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func dueDateColor(_ date: Date) -> Color {
        let now = Date.now
        if date < now {
            return AppThemeConstants.error
        }
        if date < now.addingTimeInterval(86400) {
            return AppThemeConstants.warning
        }
        return AppThemeConstants.brandPrimary
    }
}
