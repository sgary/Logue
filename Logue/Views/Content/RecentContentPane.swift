import SwiftUI

/// Shows recently modified documents and meetings across the workspace.
struct RecentContentPane: View {
    @Environment(DocumentStore.self) private var documentStore
    @Environment(MeetingStore.self) private var meetingStore
    @Environment(SpaceStore.self) private var spaceStore

    @AppStorage("recentViewMode") private var viewModeRaw = ContentViewMode.list.rawValue

    private var viewMode: ContentViewMode {
        ContentViewMode(rawValue: viewModeRaw) ?? .list
    }

    /// Number of recent items to show.
    private let recentLimit = 30

    private var recentItems: [SpaceItem] {
        let docs = documentStore.activeDocuments.map { SpaceItem.document($0) }
        let meetings = meetingStore.activeMeetings
            .filter { !$0.isArchived }
            .map { SpaceItem.meeting($0) }
        return (docs + meetings)
            .sorted { $0.modifiedAt > $1.modifiedAt }
            .prefix(recentLimit)
            .map { $0 }
    }

    /// Both stores, because this pane mixes documents and meetings: showing "nothing here"
    /// while either is still reading would be wrong about half the content.
    private var isLoaded: Bool {
        documentStore.isLoaded && meetingStore.isLoaded
    }

    var body: some View {
        Group {
            if !isLoaded {
                ContentLoadingView()
            } else if recentItems.isEmpty {
                ContentUnavailableView {
                    Label("没有最近项目", systemImage: "clock")
                } description: {
                    Text("你最近修改的文档和会议会显示在这里。")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewMode == .grid {
                contentGrid
            } else {
                contentList
            }
        }
        .background(AppThemeConstants.contentBackground)
        .navigationTitle("最近")
        .navigationSubtitle("最近 \(recentItems.count) 个项目")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                viewModeMenu

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModeRaw = viewMode == .list
                            ? ContentViewMode.grid.rawValue
                            : ContentViewMode.list.rawValue
                    }
                } label: {
                    Image(systemName: viewMode == .list ? "square.grid.2x2" : "list.bullet")
                }
                .help(viewMode == .list ? "网格视图" : "列表视图")
                .accessibilityLabel(viewMode == .list ? "切换到网格视图" : "切换到列表视图")
            }
        }
    }

    // MARK: - View Mode Menu

    private var viewModeMenu: some View {
        Menu {
            Section("视图") {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModeRaw = ContentViewMode.list.rawValue
                    }
                } label: {
                    HStack {
                        Label("列表", systemImage: "list.bullet")
                        if viewMode == .list {
                            Spacer(); Image(systemName: "checkmark")
                        }
                    }
                }
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModeRaw = ContentViewMode.grid.rawValue
                    }
                } label: {
                    HStack {
                        Label("网格", systemImage: "square.grid.2x2")
                        if viewMode == .grid {
                            Spacer(); Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
        .help("选项")
    }

    // MARK: - List

    private var contentList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(recentItems) { item in
                    switch item {
                    case let .document(doc):
                        documentRow(doc)
                    case let .meeting(meeting):
                        meetingRow(meeting)
                    case .space:
                        EmptyView()
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Grid

    private var contentGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 200, maximum: 280), spacing: 16)],
                spacing: 16
            ) {
                ForEach(recentItems) { item in
                    switch item {
                    case let .document(doc):
                        documentGridCard(doc)
                    case let .meeting(meeting):
                        meetingGridCard(meeting)
                    case .space:
                        EmptyView()
                    }
                }
            }
            .padding(24)
        }
    }

    // MARK: - Grid Cards

    private func documentGridCard(_ doc: WritingDocument) -> some View {
        let snippetLines = doc.title.count > 30 ? 3 : 4

        return HomeCardShell {
            documentStore.selectedDocumentID = doc.id
        } content: { _ in
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "doc.text")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    Spacer()
                    if doc.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption2)
                            .foregroundStyle(AppThemeConstants.pinnedColor)
                    }
                }

                Text(doc.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(doc.snippet.isEmpty ? "空文档" : doc.snippet)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(snippetLines)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 0)

                HStack {
                    if let spaceID = doc.spaceID, let space = spaceStore.space(for: spaceID) {
                        spaceBadge(space.name)
                    }
                    Spacer()
                    Text(doc.modifiedAt.formatted(.relative(presentation: .named)))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
        } contextMenu: {
            docContextMenu(doc)
        }
    }

    private func meetingGridCard(_ meeting: MeetingNote) -> some View {
        let previewLines = meeting.title.count > 30 ? 3 : 4

        return HomeCardShell {
            meetingStore.selectedMeetingID = meeting.id
        } content: { _ in
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: meeting.recordingMode.iconName)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    Spacer()
                    if meeting.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption2)
                            .foregroundStyle(AppThemeConstants.pinnedColor)
                    }
                }

                Text(meeting.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                if let summary = meeting.summary {
                    Text(summary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(previewLines)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 0)

                HStack {
                    if meeting.duration > 0 {
                        Text(meeting.formattedDuration)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .monospacedDigit()
                    }
                    if let spaceID = meeting.spaceID, let space = spaceStore.space(for: spaceID) {
                        spaceBadge(space.name)
                    }
                    Spacer()
                    Text(meeting.modifiedAt.formatted(.relative(presentation: .named)))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
        } contextMenu: {
            meetingContextMenu(meeting)
        }
    }

    // MARK: - List Rows

    private func documentRow(_ doc: WritingDocument) -> some View {
        HomeCardShell {
            documentStore.selectedDocumentID = doc.id
        } content: { _ in
            HStack(spacing: 12) {
                Image(systemName: "doc.text")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(doc.title)
                            .font(.body.weight(.medium))
                            .lineLimit(1)
                        if doc.isPinned {
                            Image(systemName: "pin.fill")
                                .font(.caption2)
                                .foregroundStyle(AppThemeConstants.pinnedColor)
                        }
                    }
                    HStack(spacing: 8) {
                        Text(doc.snippet.isEmpty ? "空文档" : doc.snippet)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        if let spaceID = doc.spaceID, let space = spaceStore.space(for: spaceID) {
                            spaceBadge(space.name)
                        }
                    }
                }

                Spacer()

                Text(doc.modifiedAt.formatted(.relative(presentation: .named)))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
        } contextMenu: {
            docContextMenu(doc)
        }
    }

    private func meetingRow(_ meeting: MeetingNote) -> some View {
        HomeCardShell {
            meetingStore.selectedMeetingID = meeting.id
        } content: { _ in
            HStack(spacing: 12) {
                Image(systemName: meeting.recordingMode.iconName)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(meeting.title)
                            .font(.body.weight(.medium))
                            .lineLimit(1)
                        if meeting.isPinned {
                            Image(systemName: "pin.fill")
                                .font(.caption2)
                                .foregroundStyle(AppThemeConstants.pinnedColor)
                        }
                    }
                    HStack(spacing: 8) {
                        if meeting.duration > 0 {
                            Text(meeting.formattedDuration)
                                .monospacedDigit()
                        }
                        if let spaceID = meeting.spaceID, let space = spaceStore.space(for: spaceID) {
                            spaceBadge(space.name)
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                }

                Spacer()

                Text(meeting.modifiedAt.formatted(.relative(presentation: .named)))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
        } contextMenu: {
            meetingContextMenu(meeting)
        }
    }

    // MARK: - Context Menus

    @ViewBuilder
    private func docContextMenu(_ doc: WritingDocument) -> some View {
        Button {
            documentStore.selectedDocumentID = doc.id
        } label: {
            Label("打开", systemImage: "doc.text")
        }
        Button {
            documentStore.togglePin(id: doc.id)
        } label: {
            Label(
                doc.isPinned ? "取消置顶" : "置顶",
                systemImage: doc.isPinned ? "pin.slash" : "pin"
            )
        }
        if !spaceStore.topLevelSpaces.isEmpty || doc.spaceID != nil {
            Menu("移动到") {
                HierarchicalSpaceMenu(currentSpaceID: doc.spaceID) { newSpaceID in
                    documentStore.moveDocument(id: doc.id, toSpace: newSpaceID)
                }
            }
        }
        Divider()
        Button(role: .destructive) {
            documentStore.deleteDocument(id: doc.id)
        } label: {
            Label("移到废纸篓", systemImage: "trash")
        }
    }

    @ViewBuilder
    private func meetingContextMenu(_ meeting: MeetingNote) -> some View {
        Button {
            meetingStore.selectedMeetingID = meeting.id
        } label: {
            Label("打开", systemImage: "waveform")
        }
        Button {
            meetingStore.togglePin(id: meeting.id)
        } label: {
            Label(
                meeting.isPinned ? "取消置顶" : "置顶",
                systemImage: meeting.isPinned ? "pin.slash" : "pin"
            )
        }
        Button {
            meetingStore.toggleArchive(id: meeting.id)
        } label: {
            Label(
                meeting.isArchived ? "取消归档" : "归档",
                systemImage: meeting.isArchived ? "tray.and.arrow.up" : "archivebox"
            )
        }
        if !spaceStore.topLevelSpaces.isEmpty || meeting.spaceID != nil {
            Menu("移动到") {
                HierarchicalSpaceMenu(currentSpaceID: meeting.spaceID) { newSpaceID in
                    meetingStore.moveMeeting(id: meeting.id, toSpace: newSpaceID)
                }
            }
        }
        Divider()
        Button(role: .destructive) {
            meetingStore.trashMeeting(id: meeting.id)
        } label: {
            Label("移到废纸篓", systemImage: "trash")
        }
    }

    // MARK: - Helpers

    private func spaceBadge(_ name: String) -> some View {
        Text(name)
            .font(.caption2)
            .foregroundStyle(.tertiary)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Capsule().fill(.quaternary))
    }
}
