// swiftlint:disable file_length
import SwiftUI

/// Full-screen meeting workspace: recording bar → transcript timeline → right tool panel.
/// Actions (Summarize, Start/Stop, Tag, Fav/Archive/Delete) live in the macOS toolbar.
struct MeetingWorkspaceView: View {
    @Environment(MeetingStore.self) private var store
    @Environment(\.colorScheme) private var colorScheme
    @Environment(RecordingSessionManager.self) private var recorder
    // Arch-1: Use @Environment instead of SpaceStore.shared
    @Environment(SpaceStore.self) private var spaceStore

    // UI state
    @State private var activeTool: MeetingTool? = .aiChat
    @State private var newTagText = ""
    @State private var showTagPopover = false
    @FocusState private var isTagFieldFocused: Bool
    @State private var showDeleteConfirmation = false
    @State private var showRenameAlert = false
    @State private var renameText = ""
    @State private var isSidebarCollapsed = false
    @State private var toolPanelWidths: [String: CGFloat] = [:]
    @State private var scrollToSegmentID: UUID?
    @State private var audioPlaybackService = AudioPlaybackService()
    @State private var chatMessages: [MeetingChatMessage] = []

    // Bookmark state (moved from MeetingRecordingBar)
    @State private var showBookmarkPopover = false
    @State private var bookmarkLabel = ""
    @State private var bookmarkColor: BookmarkColor = .orange
    @State private var showBookmarkConfirm = false
    @State private var bookmarkConfirmTask: Task<Void, Never>?

    var body: some View {
        if let meeting = store.selectedMeeting {
            VStack(spacing: 0) {
                // Error banner
                if let errorMessage = recorder.errorMessage {
                    errorBanner(message: errorMessage)
                }

                // Space suggestion banner
                if let suggestedID = recorder.postRecordingPipeline.suggestedSpaceID,
                   recorder.postRecordingPipeline.suggestedSpaceMeetingID == meeting.id,
                   let spaceName = spaceStore.space(for: suggestedID)?.name
                {
                    spaceSuggestionBanner(
                        spaceName: spaceName,
                        meetingID: meeting.id,
                        spaceID: suggestedID
                    )
                }

                // The tip that used to sit here explained the System Audio button to users who could
                // not find it. The tap arms itself now, so there is nothing left to explain.

                // What is left is capture telling the user something it did on its own — a headset
                // that dropped, a fallback it took. Non-blocking and self-clearing: recording is
                // still running, and there is nothing to decide.
                if meeting.wasRecovered {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.clockwise.circle")
                            .foregroundStyle(.secondary)
                        Text("应用意外退出后已恢复录音——最后几秒可能缺失。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppThemeConstants.categoryBlue.opacity(0.08))
                }

                if let notice = recorder.captureNotice, recorder.isRecording {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundStyle(.secondary)
                        Text(notice)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppThemeConstants.categoryYellow.opacity(0.08))
                    .transition(.opacity)
                }

                // Main content area
                HStack(spacing: 0) {
                    // Center: transcript timeline
                    TranscriptTimelineView(
                        segments: meeting.segments,
                        volatileText: recorder.isRecording ? recorder.volatileText : "",
                        bookmarks: meeting.bookmarks,
                        isLive: recorder.isRecording,
                        externalScrollTarget: $scrollToSegmentID,
                        onAddBookmark: { timestamp, label, color in
                            let bookmark = Bookmark(label: label, timestamp: timestamp, color: color)
                            store.addBookmark(bookmark, to: meeting.id)
                        },
                        onRemoveBookmark: { bookmarkID in
                            store.removeBookmark(bookmarkID: bookmarkID, from: meeting.id)
                        },
                        onChangeBookmarkType: { bookmarkID, label, color in
                            if var bookmark = meeting.bookmarks.first(where: { $0.id == bookmarkID }) {
                                bookmark.label = label
                                bookmark.color = color
                                store.updateBookmark(bookmark, in: meeting.id)
                            }
                        },
                        onEditSegment: { segmentID, newText in
                            store.updateSegmentText(meetingID: meeting.id, segmentID: segmentID, text: newText)
                        },
                        onRenameSpeaker: { oldName, newName in
                            renameSpeaker(in: meeting, from: oldName, to: newName)
                        },
                        onSeekToTime: { time in
                            audioPlaybackService.seek(to: time)
                            if !audioPlaybackService.isPlaying {
                                audioPlaybackService.play()
                            }
                        },
                        activeSegmentID: audioPlaybackService.activeSegmentID,
                        speakerColors: meeting.speakerColorsByName
                    )
                    .frame(maxWidth: .infinity)

                    // Right: unified sidebar (tab strip + panel)
                    UnifiedSidebarView(
                        activeTool: $activeTool,
                        isCollapsed: $isSidebarCollapsed,
                        panelWidths: $toolPanelWidths
                    ) { tool in
                        rightPanel(for: tool, meeting: meeting)
                    }
                }
                .measuringWorkspaceWidth()
            }
            .background(AppThemeConstants.contentBackground)
            .navigationTitle(meeting.title)
            .navigationSubtitle(meetingSubtitle(for: meeting))
            .toolbar {
                meetingWorkspaceToolbar(for: meeting)
            }
            .id(meeting.id)
            .onAppear {
                chatMessages = meeting.chatMessages
            }
            .onChange(of: store.selectedMeetingID) { oldID, _ in
                // Save chat to the old meeting
                if let oldID {
                    store.setChatMessages(chatMessages, for: oldID)
                }
                // Load chat from the new meeting
                if let meeting = store.selectedMeeting {
                    chatMessages = meeting.chatMessages
                }
            }
            .task(id: meeting.id) {
                await takeAutoRecordRequest(for: meeting)
            }
            // Retried whenever the recorder frees up — a rebuild finishing, or the previous
            // session finishing being written. The `.task` above re-runs on a change of meeting,
            // not on the recorder becoming free, so a queued capture sat unclaimed.
            .onChange(of: recorder.recordingState) { _, state in
                guard state == .idle else { return }
                Task { await takeAutoRecordRequest(for: meeting) }
            }
            // A request belongs to the meeting that is open. Leaving before the recorder frees
            // up strands it otherwise: this view is the only thing that can take it, so it
            // survived for the life of the process and started recording the next time that
            // meeting was merely opened to read.
            .onDisappear {
                if store.pendingAutoRecord == meeting.id {
                    store.pendingAutoRecord = nil
                }
            }
            .onAppear {
                audioPlaybackService.segments = meeting.segments
            }
            .onChange(of: meeting.segments) { _, newSegments in
                audioPlaybackService.segments = newSegments
            }
            .onChange(of: audioPlaybackService.activeSegmentID) { _, segmentID in
                if let segmentID {
                    scrollToSegmentID = segmentID
                }
            }
            .onDisappear {
                store.setChatMessages(chatMessages, for: meeting.id)
            }
            .onExitCommand {
                store.selectedMeetingID = nil
            }
            .onChange(of: isSidebarCollapsed) { _, collapsed in
                if !collapsed, activeTool == nil {
                    activeTool = .aiChat
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .openMeetingExportPanel)) { _ in
                MeetingExportPanelView.exportMarkdown(meeting: meeting)
            }
            .alert("删除会议？", isPresented: $showDeleteConfirmation) {
                Button("删除", role: .destructive) {
                    store.trashMeeting(id: meeting.id)
                }
                Button("取消", role: .cancel) {}
            } message: {
                Text("“\(meeting.title)”将移到废纸篓。")
            }
        }
    }
}

// MARK: - Toolbar

extension MeetingWorkspaceView {
    @ToolbarContentBuilder
    func meetingWorkspaceToolbar(for meeting: MeetingNote) -> some ToolbarContent {
        newMeetingToolbarItem()
        recordingStatusToolbarItem()
        audioToggleToolbarItems()
        recordControlToolbarItems(for: meeting)
        moreMenuToolbarItem(for: meeting)
        sidebarToggleToolbarItem()
    }

    @ToolbarContentBuilder
    func newMeetingToolbarItem() -> some ToolbarContent {
        // New meeting (left side)
        ToolbarItem(placement: .navigation) {
            Button {
                let newMeeting = store.createMeeting(
                    title: "会议 \(Date.now.formatted(date: .abbreviated, time: .shortened))"
                )
                store.selectedMeetingID = newMeeting.id
            } label: {
                Image(systemName: "plus")
            }
            .help("新建会议")
        }
    }

    @ToolbarContentBuilder
    func recordingStatusToolbarItem() -> some ToolbarContent {
        // Center: recording status when active (overrides navigationTitle)
        ToolbarItem(placement: .principal) {
            if recorder.isRecording {
                RecordingStatusView(
                    elapsedTime: recorder.elapsedTime,
                    audioLevel: recorder.audioLevel,
                    isCapturingSystemAudio: recorder.isCapturingSystemAudio
                )
            }
        }
    }

    /// The single capture control: mute.
    ///
    /// There is no system-audio button. The tap arms itself when something starts playing, and the
    /// recording status capsule says so — offering a switch for it would be offering to undo a
    /// decision the app is making correctly on its own.
    @ToolbarContentBuilder
    func audioToggleToolbarItems() -> some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            if recorder.isRecording {
                Button {
                    recorder.setMicMuted(recorder.isMicActive)
                } label: {
                    Image(systemName: recorder.isMicActive ? "mic.fill" : "mic.slash.fill")
                        .font(.caption)
                        .foregroundStyle(recorder.isMicActive ? .primary : .secondary)
                }
                .help(recorder.isMicActive ? "静音麦克风" : "取消麦克风静音")
            }
        }
    }

    @ToolbarContentBuilder
    func recordControlToolbarItems(for meeting: MeetingNote) -> some ToolbarContent {
        // Start/Stop
        ToolbarItem(placement: .primaryAction) {
            startStopButton(for: meeting)
        }

        // Quick bookmark (visible during recording)
        if recorder.isRecording, recorder.currentMeetingID == meeting.id {
            ToolbarItem(placement: .primaryAction) {
                quickBookmarkButton(for: meeting)
            }
        }
    }

    /// Starts the recording this meeting was opened to start, if it still wants one.
    ///
    /// The request is only cleared once it has actually been taken — by this call starting a
    /// session, or by one already running. A refused start leaves it in place for the retry
    /// above, because consuming it meant automatic capture silently did nothing whenever it
    /// landed while an interrupted recording was being rebuilt.
    func takeAutoRecordRequest(for meeting: MeetingNote) async {
        guard store.pendingAutoRecord == meeting.id else { return }
        if recorder.isRecording {
            store.pendingAutoRecord = nil
            return
        }
        // The outcome says whether the obstacle clears on its own; only then is the request
        // worth keeping for the retry. Deriving that here from `isRecovering` missed the window
        // where the previous session was still being written, and treated a denied microphone
        // as temporary — leaving a request armed to fire the next time the meeting was opened.
        let outcome = await recorder.startRecording(for: meeting)
        if !outcome.clearsOnItsOwn {
            store.pendingAutoRecord = nil
        }
    }

    @ViewBuilder
    func startStopButton(for meeting: MeetingNote) -> some View {
        if recorder.isRecovering {
            recordProgressButton(label: "正在结束中断的录音…")
        } else if recorder.isStartingRecording {
            recordProgressButton(label: "正在开始…")
        } else if recorder.isStopping {
            recordProgressButton(label: "正在停止…")
        } else if recorder.isDiarizing(for: meeting.id) {
            recordProgressButton(
                label: recorder.diarizationStage.isEmpty ? "正在识别发言人…" : recorder.diarizationStage
            )
        } else if recorder.isRecording {
            stopRecordingButton(for: meeting)
        } else {
            startRecordingButton(for: meeting)
        }
    }

    func recordProgressButton(label: String) -> some View {
        Button {} label: {
            HStack(spacing: 4) {
                ProgressView()
                    .controlSize(.small)
                Text(label)
            }
        }
        .disabled(true)
    }

    func stopRecordingButton(for meeting: MeetingNote) -> some View {
        Button {
            toggleRecording(for: meeting)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "stop.circle.fill")
                Text("停止")
            }
        }
        .tint(AppThemeConstants.error)
        .keyboardShortcut("r", modifiers: .command)
        .accessibilityLabel("停止录音")
        .accessibilityHint("停止当前会议录音")
    }

    func startRecordingButton(for meeting: MeetingNote) -> some View {
        Button {
            startSmartRecording(for: meeting)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "record.circle")
                Text("开始")
            }
        }
        .keyboardShortcut("r", modifiers: .command)
        .accessibilityLabel("开始录音")
        .help("开始录音（⌘R）")
    }

    func quickBookmarkButton(for meeting: MeetingNote) -> some View {
        Button {
            let bookmark = Bookmark(label: "书签", timestamp: recorder.elapsedTime, color: .orange)
            store.addBookmark(bookmark, to: meeting.id)
            showBookmarkConfirm = true
            Task { @MainActor in
                try? await Task.sleep(for: AppConstants.Delays.bookmarkConfirmLong)
                showBookmarkConfirm = false
            }
        } label: {
            Image(systemName: showBookmarkConfirm ? "bookmark.fill" : "bookmark")
                .foregroundStyle(showBookmarkConfirm ? AppThemeConstants.warning : .secondary)
        }
        .keyboardShortcut("b", modifiers: .command)
        .help("添加书签（⌘B）")
        .accessibilityLabel("添加书签")
    }

    @ToolbarContentBuilder
    func moreMenuToolbarItem(for meeting: MeetingNote) -> some ToolbarContent {
        // More menu (right of Start/Stop)
        ToolbarItem(placement: .primaryAction) {
            Menu {
                moreMenuContent(for: meeting)
            } label: {
                Label("更多", systemImage: "ellipsis.circle")
            }
            .help("更多选项")
            .popover(isPresented: $showTagPopover, arrowEdge: .bottom) {
                tagPopoverContent(meeting: meeting)
            }
            .alert("重命名会议", isPresented: $showRenameAlert) {
                TextField("标题", text: $renameText)
                Button("重命名") {
                    store.renameMeeting(id: meeting.id, newTitle: renameText)
                }
                Button("取消", role: .cancel) {}
            }
        }
    }

    @ViewBuilder
    func moreMenuContent(for meeting: MeetingNote) -> some View {
        Button {
            store.togglePin(id: meeting.id)
        } label: {
            Label(
                meeting.isPinned ? "取消置顶" : "置顶",
                systemImage: meeting.isPinned ? "pin.slash" : "pin"
            )
        }
        Button {
            store.toggleArchive(id: meeting.id)
        } label: {
            Label(
                meeting.isArchived ? "取消归档" : "归档",
                systemImage: meeting.isArchived ? "tray.and.arrow.up" : "archivebox"
            )
        }
        Button {
            Task { @MainActor in
                await store.regenerateAITitle(for: meeting.id)
            }
        } label: {
            Label("生成标题", systemImage: "sparkles")
        }
        .disabled(meeting.segments.isEmpty)
        Button {
            renameText = meeting.title
            showRenameAlert = true
        } label: {
            Label("重命名", systemImage: "pencil")
        }
        Button {
            showTagPopover = true
        } label: {
            Label("添加标签", systemImage: "tag")
        }
        Divider()
        Menu {
            exportMenuContent(for: meeting)
        } label: {
            Label("导出", systemImage: "square.and.arrow.up")
        }
        Divider()
        Button(role: .destructive) {
            showDeleteConfirmation = true
        } label: {
            Label("删除会议", systemImage: "trash")
        }
    }

    @ViewBuilder
    func exportMenuContent(for meeting: MeetingNote) -> some View {
        Button {
            MeetingExportPanelView.exportTranscript(meeting: meeting)
        } label: {
            Label("完整转写", systemImage: "doc.text")
        }
        Button {
            MeetingExportPanelView.exportSmartMinutes(meeting: meeting)
        } label: {
            Label("会议纪要", systemImage: "doc.plaintext")
        }
        Button {
            MeetingExportPanelView.exportActionItems(meeting: meeting)
        } label: {
            Label("待办事项", systemImage: "checklist")
        }
        Button {
            MeetingExportPanelView.exportMarkdown(meeting: meeting)
        } label: {
            Label("Markdown", systemImage: "text.document")
        }
        if !meeting.bookmarks.isEmpty {
            Button {
                MeetingExportPanelView.exportBookmarks(meeting: meeting)
            } label: {
                Label("书签时刻", systemImage: "bookmark.fill")
            }
        }
        Divider()
        Button {
            MeetingExportPanelView.copyToClipboard(meeting.fullTranscript)
        } label: {
            Label("复制转写", systemImage: "doc.on.doc")
        }
        Button {
            let content = meeting.smartMinutes != nil
                ? meeting.smartMinutesMarkdown()
                : (meeting.summary ?? "暂无摘要")
            MeetingExportPanelView.copyToClipboard(content)
        } label: {
            Label("复制摘要", systemImage: "doc.on.doc")
        }
    }

    @ToolbarContentBuilder
    func sidebarToggleToolbarItem() -> some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                withAnimation(.spring(duration: 0.25, bounce: 0.1)) {
                    isSidebarCollapsed.toggle()
                }
            } label: {
                Image(systemName: "sidebar.right")
            }
            .help(isSidebarCollapsed ? "显示工具侧边栏" : "隐藏工具侧边栏")
            .accessibilityLabel(isSidebarCollapsed ? "显示工具侧边栏" : "隐藏工具侧边栏")
        }
    }
}

// MARK: - Helpers & Banners

extension MeetingWorkspaceView {
    func meetingSubtitle(for meeting: MeetingNote) -> String {
        var parts: [String] = []
        if meeting.duration > 0 {
            let minutes = Int(meeting.duration / 60)
            parts.append("\(minutes) 分钟")
        }
        let segmentCount = meeting.segments.count
        if segmentCount > 0 {
            parts.append("\(segmentCount) 条转写")
        }
        // Count only speakers that appear in at least one transcript segment,
        // not all Speaker objects (some may have no segments assigned by diarization).
        let speakerCount = Set(meeting.segments.compactMap(\.speakerLabel)).count
        if speakerCount > 0 {
            parts.append("\(speakerCount) 位发言人")
        }
        return parts.joined(separator: " · ")
    }

    func submitTag(to meetingID: UUID) {
        let trimmed = newTagText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        store.addTag(trimmed, to: meetingID)
        newTagText = ""
    }

    func tagPopoverContent(meeting: MeetingNote) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if !meeting.tags.isEmpty {
                FlowLayout(spacing: 4) {
                    ForEach(meeting.tags, id: \.self) { tag in
                        FilterChip(label: tag, style: .removable, tintColor: AppThemeConstants.tagColor(for: tag)) {
                            store.removeTag(tag, from: meeting.id)
                        }
                    }
                }
            }

            HStack(spacing: 6) {
                TextField("添加标签…", text: $newTagText)
                    .textFieldStyle(.plain)
                    .font(.subheadline)
                    .focused($isTagFieldFocused)
                    .onSubmit { submitTag(to: meeting.id) }

                if !newTagText.isEmpty {
                    Button { submitTag(to: meeting.id) } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(AppThemeConstants.accent)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("添加标签")
                }
            }
            .padding(8)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: AppThemeConstants.radiusSmall))

            tagSuggestions(for: meeting)
        }
        .padding(12)
        .frame(width: 260)
        .onAppear { isTagFieldFocused = true }
    }

    @ViewBuilder
    func tagSuggestions(for meeting: MeetingNote) -> some View {
        let suggestions = store.allTags.filter {
            !newTagText.isEmpty
                && $0.localizedCaseInsensitiveContains(newTagText)
                && !meeting.tags.contains($0)
        }
        if !suggestions.isEmpty {
            HStack(spacing: 4) {
                ForEach(suggestions.prefix(5), id: \.self) { suggestion in
                    let color = AppThemeConstants.tagColor(for: suggestion)
                    Button {
                        store.addTag(suggestion, to: meeting.id)
                        newTagText = ""
                    } label: {
                        Text(suggestion)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(color.opacity(AppThemeConstants.opacityLight), in: Capsule())
                            .foregroundStyle(color)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    func errorBanner(message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(AppThemeConstants.warning)
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            if message.contains("permission") || message.contains("Permission") || message.contains("access denied")
                || message.contains("权限") || message.contains("访问被拒绝") {
                Button {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone") {
                        NSWorkspace.shared.open(url)
                    }
                } label: {
                    Text("打开设置")
                        .font(.caption.weight(.medium))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            Button {
                recorder.errorMessage = nil
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.tertiary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("关闭错误提示")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(AppThemeConstants.warning.opacity(0.08))
    }

    func spaceSuggestionBanner(spaceName: String, meetingID: UUID, spaceID: UUID) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.callout)
                .foregroundStyle(AppThemeConstants.brandPrimary)

            Text("归档到")
                .font(.callout)
                .foregroundStyle(.secondary)
            Text(spaceName)
                .font(.callout.weight(.medium))

            Spacer()

            Button("移动") {
                withAnimation(.easeOut(duration: 0.2)) {
                    store.moveMeeting(id: meetingID, toSpace: spaceID)
                    recorder.postRecordingPipeline.suggestedSpaceID = nil
                    recorder.postRecordingPipeline.suggestedSpaceMeetingID = nil
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(AppThemeConstants.accent)
            .controlSize(.small)

            Button {
                withAnimation(.easeOut(duration: 0.2)) {
                    recorder.postRecordingPipeline.suggestedSpaceID = nil
                    recorder.postRecordingPipeline.suggestedSpaceMeetingID = nil
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("忽略建议")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(AppThemeConstants.brandPrimary.opacity(AppThemeConstants.hoverOpacity))
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    @ViewBuilder
    func rightPanel(for tool: MeetingTool, meeting: MeetingNote) -> some View {
        switch tool {
        case .summary:
            MeetingSummaryPanelView(meeting: meeting)
        case .bookmarks:
            MeetingBookmarksPanelView(meeting: meeting, scrollToSegmentID: $scrollToSegmentID)
        case .actionItems:
            MeetingActionItemsPanelView(meeting: meeting)
        case .aiChat:
            MeetingAIChatPanelView(meeting: meeting, onSave: { saveChatMessages(meetingID: meeting.id) }, messages: $chatMessages)
        case .speakers:
            MeetingSpeakersPanelView(meeting: meeting)
        case .recording:
            AudioPlaybackView(meeting: meeting, service: audioPlaybackService)
        }
    }

    func saveChatMessages(meetingID: UUID) {
        store.setChatMessages(chatMessages, for: meetingID)
    }
}

// MARK: - Bookmarks & Recording

extension MeetingWorkspaceView {
    static let bookmarkPresets: [(String, BookmarkColor)] = [
        ("关键决策", .blue),
        ("待办事项", .orange),
        ("重要", .red),
        ("问题", .purple),
    ]

    /// Renaming to a name another speaker already holds merges the two — see
    /// `MeetingNote.renamingSpeaker(from:to:)`.
    func renameSpeaker(in meeting: MeetingNote, from oldName: String, to newName: String) {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        // Skip the persist entirely when the field was committed unchanged. `updateMeeting`
        // does not compare, so without this a no-op commit still bumps `modifiedAt`.
        guard !trimmed.isEmpty, trimmed != oldName else { return }
        store.updateMeeting(meeting.renamingSpeaker(from: oldName, to: trimmed))
    }

    func addBookmark(for meeting: MeetingNote, label: String, color: BookmarkColor) {
        let bookmark = Bookmark(
            label: label,
            timestamp: recorder.elapsedTime,
            color: color
        )
        store.addBookmark(bookmark, to: meeting.id)
    }

    func bookmarkPopoverContent(meeting: MeetingNote) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("添加书签")
                .font(.subheadline.weight(.semibold))

            VStack(spacing: 4) {
                ForEach(Self.bookmarkPresets, id: \.0) { preset in
                    Button {
                        addBookmark(for: meeting, label: preset.0, color: preset.1)
                        showBookmarkPopover = false
                        flashBookmarkConfirm()
                    } label: {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(preset.1.swiftUIColor)
                                .frame(width: 8, height: 8)
                            Text(preset.0)
                                .font(.caption)
                            Spacer()
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: AppThemeConstants.radiusSmall))
                    }
                    .buttonStyle(.plain)
                }
            }

            Divider()

            bookmarkCustomLabel(meeting: meeting)
        }
        .padding(12)
        .frame(width: 200)
    }

    func bookmarkCustomLabel(meeting: MeetingNote) -> some View {
        HStack(spacing: 6) {
            TextField("自定义标签", text: $bookmarkLabel)
                .textFieldStyle(.plain)
                .font(.caption)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: AppThemeConstants.radiusSmall))
                .onSubmit { submitBookmark(for: meeting) }

            Button { submitBookmark(for: meeting) } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.body)
                    .foregroundColor(AppThemeConstants.accent)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("添加自定义书签")
        }
    }

    func submitBookmark(for meeting: MeetingNote) {
        addBookmark(for: meeting, label: bookmarkLabel, color: bookmarkColor)
        showBookmarkPopover = false
        bookmarkLabel = ""
        flashBookmarkConfirm()
    }

    func flashBookmarkConfirm() {
        bookmarkConfirmTask?.cancel()
        showBookmarkConfirm = true
        bookmarkConfirmTask = Task {
            try? await Task.sleep(for: AppConstants.Delays.bookmarkConfirm)
            guard !Task.isCancelled else { return }
            showBookmarkConfirm = false
        }
    }

    func toggleRecording(for meeting: MeetingNote) {
        Task { @MainActor in
            if recorder.isRecording {
                await recorder.stopRecording()
            } else {
                await recorder.startRecording(for: meeting)
            }
        }
    }

    /// Starts recording. There is nothing to ask: the microphone always runs, and the system-audio
    /// tap arms itself when something actually starts playing rather than when a conferencing app
    /// merely happens to be open — which it often is, hours after the call ended.
    private func startSmartRecording(for meeting: MeetingNote) {
        toggleRecording(for: meeting)
    }
}

// MARK: - Recording Status View (toolbar inline)

/// Compact recording status shown in the macOS toolbar during active recording.
///
/// Says what is being captured; it does not offer to change it. The microphone has no indicator
/// here because the mute button sitting beside this capsule already shows its state and is the one
/// control for it — two mic glyphs an inch apart was what made automatic capture still look like a
/// pair of toggles.
struct RecordingStatusView: View {
    let elapsedTime: TimeInterval
    let audioLevel: Float
    var isCapturingSystemAudio: Bool = false

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(AppThemeConstants.error)
                .frame(width: 8, height: 8)
                .accessibilityLabel("录音中")

            Text(TranscriptSegment.formatTime(elapsedTime))
                .font(.caption.monospacedDigit().weight(.medium))
                .accessibilityLabel("录音时间：\(TranscriptSegment.formatTime(elapsedTime))")

            AudioLevelMeter(level: audioLevel)
                .frame(width: 64, height: 14)

            if isCapturingSystemAudio {
                Image(systemName: "display")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .help("同时捕获系统音频")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(AppThemeConstants.error.opacity(0.08), in: Capsule())
        .clipShape(Capsule())
    }
}
