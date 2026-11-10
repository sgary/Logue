import SwiftUI

/// Displays the mixed contents of a Space — documents, meetings, and sub-spaces.
struct SpaceContentPane: View {
    let spaceID: UUID
    @Binding var sidebarSelection: SidebarItem?
    // Note: internal (not private) because SpaceContentPane+Cards.swift extension accesses these
    @Environment(DocumentStore.self) var documentStore
    @Environment(MeetingStore.self) var meetingStore
    @Environment(SpaceStore.self) var spaceStore

    @AppStorage("spaceViewMode") var viewModeRaw = ContentViewMode.list.rawValue
    @State var searchText = ""
    @State private var filterType: SpaceFilterType = .all
    @State private var sortOrder: SpaceSortOrder = .modifiedNewest
    @State var renamingSpaceID: UUID?
    @State var renamingDocID: UUID?
    @State var renamingMeetingID: UUID?
    @State var renameText = ""
    @State var iconPickerSpaceID: UUID?
    @State private var showSummaryPopover = false
    @State private var showActionItemsPopover = false
    @State private var showDecisionsPopover = false
    @State private var showStatusUpdatePopover = false
    @State private var aiTracker = SpaceAIGenerationTracker()

    var viewMode: ContentViewMode {
        ContentViewMode(rawValue: viewModeRaw) ?? .list
    }

    var space: Space? {
        spaceStore.space(for: spaceID)
    }

    // MARK: - Items

    var documents: [WritingDocument] {
        documentStore.documents(inSpace: spaceID)
    }

    var meetings: [MeetingNote] {
        meetingStore.meetings(inSpace: spaceID).filter { !$0.isArchived }
    }

    var childSpaces: [Space] {
        spaceStore.children(of: spaceID)
    }

    var allItems: [SpaceItem] {
        var items: [SpaceItem] = []

        items += childSpaces.map { SpaceItem.space($0) }

        if filterType == .all || filterType == .documents {
            items += documents.map { SpaceItem.document($0) }
        }
        if filterType == .all || filterType == .meetings {
            items += meetings.map { SpaceItem.meeting($0) }
        }

        if !searchText.isEmpty {
            let query = searchText
            items = items.filter { item in
                switch item {
                case let .document(doc):
                    doc.title.localizedCaseInsensitiveContains(query)
                        || doc.body.localizedCaseInsensitiveContains(query)
                case let .meeting(meeting):
                    meeting.title.localizedCaseInsensitiveContains(query)
                        || (meeting.summary?.localizedCaseInsensitiveContains(query) ?? false)
                case let .space(space):
                    space.name.localizedCaseInsensitiveContains(query)
                        || (space.summary?.localizedCaseInsensitiveContains(query) ?? false)
                }
            }
        }

        return sorted(items)
    }

    private func sorted(_ items: [SpaceItem]) -> [SpaceItem] {
        items.sorted { lhs, rhs in
            switch sortOrder {
            case .modifiedNewest: lhs.modifiedAt > rhs.modifiedAt
            case .modifiedOldest: lhs.modifiedAt < rhs.modifiedAt
            case .titleAZ: lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
            case .titleZA: lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedDescending
            case .createdNewest: lhs.createdAt > rhs.createdAt
            case .createdOldest: lhs.createdAt < rhs.createdAt
            }
        }
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            if let space {
                breadcrumbBar(for: space)
                Divider()
            }

            let items = allItems
            if items.isEmpty {
                emptyState
            } else if viewMode == .grid {
                contentGrid(items)
            } else {
                contentList(items)
            }
        }
        .background(AppThemeConstants.contentBackground)
        .navigationTitle(space?.name ?? "空间")
        .navigationSubtitle(subtitle)
        .searchable(text: $searchText, placement: .toolbar, prompt: "搜索空间")
        .toolbar {
            spaceToolbarContent
        }
        .alert("重命名空间", isPresented: Binding(
            get: { renamingSpaceID != nil },
            set: {
                if !$0 {
                    renamingSpaceID = nil
                }
            }
        )) {
            TextField("空间名称", text: $renameText)
            Button("取消", role: .cancel) { renamingSpaceID = nil }
            Button("重命名") {
                let trimmed = renameText.trimmingCharacters(in: .whitespacesAndNewlines)
                if let id = renamingSpaceID, !trimmed.isEmpty {
                    spaceStore.renameSpace(id: id, newName: trimmed)
                }
                renamingSpaceID = nil
            }
        }
        .alert("重命名文档", isPresented: Binding(
            get: { renamingDocID != nil },
            set: {
                if !$0 {
                    renamingDocID = nil
                }
            }
        )) {
            TextField("标题", text: $renameText)
            Button("取消", role: .cancel) { renamingDocID = nil }
            Button("重命名") {
                let trimmed = renameText.trimmingCharacters(in: .whitespacesAndNewlines)
                if let id = renamingDocID, !trimmed.isEmpty {
                    documentStore.renameDocument(id: id, newTitle: trimmed)
                }
                renamingDocID = nil
            }
        }
        .alert("重命名会议", isPresented: Binding(
            get: { renamingMeetingID != nil },
            set: {
                if !$0 {
                    renamingMeetingID = nil
                }
            }
        )) {
            TextField("标题", text: $renameText)
            Button("取消", role: .cancel) { renamingMeetingID = nil }
            Button("重命名") {
                let trimmed = renameText.trimmingCharacters(in: .whitespacesAndNewlines)
                if let id = renamingMeetingID, !trimmed.isEmpty {
                    meetingStore.renameMeeting(id: id, newTitle: trimmed)
                }
                renamingMeetingID = nil
            }
        }
        .popover(isPresented: Binding(
            get: { iconPickerSpaceID != nil },
            set: {
                if !$0 {
                    iconPickerSpaceID = nil
                }
            }
        ), arrowEdge: .trailing) {
            if let pickingID = iconPickerSpaceID {
                SpaceIconPicker(currentIcon: spaceStore.space(for: pickingID)?.icon) { newIcon in
                    spaceStore.setSpaceIcon(id: pickingID, icon: newIcon)
                    iconPickerSpaceID = nil
                }
            }
        }
    }

    private var subtitle: String {
        let dc = documents.count
        let mc = meetings.count
        var parts: [String] = []
        if dc > 0 {
            parts.append("\(dc) 个文档")
        }
        if mc > 0 {
            parts.append("\(mc) 场会议")
        }
        return parts.joined(separator: "，")
    }

    // MARK: - Breadcrumb

    private func breadcrumbBar(for space: Space) -> some View {
        let path = spaceStore.path(to: space.id)
        return HStack(spacing: 4) {
            ForEach(Array(path.enumerated()), id: \.element.id) { index, ancestor in
                if index > 0 {
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                if index == path.count - 1 {
                    Text(ancestor.name)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.primary)
                } else {
                    Button {
                        sidebarSelection = .space(ancestor.id)
                    } label: {
                        Text(ancestor.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(AppThemeConstants.surfaceBackground)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var spaceToolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            newItemMenu
        }
        ToolbarItemGroup(placement: .primaryAction) {
            aiPopoverButton(
                "空间摘要",
                icon: "text.justify.leading",
                key: "summary",
                isPresented: $showSummaryPopover,
                action: SpaceAIService.summarizeSpace
            )

            aiPopoverButton(
                "待办事项",
                icon: "checklist",
                key: "actionItems",
                isPresented: $showActionItemsPopover,
                action: SpaceAIService.aggregateActionItems
            )

            aiPopoverButton(
                "决策",
                icon: "checkmark.seal",
                key: "decisions",
                isPresented: $showDecisionsPopover,
                action: SpaceAIService.extractDecisions
            )

            aiPopoverButton(
                "状态更新",
                icon: "doc.badge.gearshape",
                key: "statusUpdate",
                isPresented: $showStatusUpdatePopover,
                action: SpaceAIService.generateStatusUpdate
            )

            filterSortMenu
        }
    }

    private var filterSortMenu: some View {
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
            Section("筛选") {
                ForEach(SpaceFilterType.allCases, id: \.self) { type in
                    Button {
                        filterType = type
                    } label: {
                        HStack {
                            Label(type.label, systemImage: type.icon)
                            if filterType == type {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            Section("排序方式") {
                ForEach(SpaceSortOrder.allCases, id: \.self) { order in
                    Button {
                        sortOrder = order
                    } label: {
                        HStack {
                            Text(order.label)
                            if sortOrder == order {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
        .help("选项")
    }

    private func aiPopoverButton(
        _ title: String,
        icon: String,
        key: String,
        isPresented: Binding<Bool>,
        action: @escaping (UUID) async throws -> String
    ) -> some View {
        Button {
            isPresented.wrappedValue.toggle()
        } label: {
            Image(systemName: icon)
        }
        .help(title)
        .popover(isPresented: isPresented, arrowEdge: .bottom) {
            SpaceAIPopover(
                title: title,
                icon: icon,
                insightKey: key,
                spaceID: spaceID,
                action: action,
                onDismiss: { isPresented.wrappedValue = false }
            )
            .environment(spaceStore)
            .environment(documentStore)
            .environment(meetingStore)
            .environment(aiTracker)
        }
    }

    private var newItemMenu: some View {
        Menu {
            Button {
                let doc = documentStore.createDocument(inSpace: spaceID)
                documentStore.selectedDocumentID = doc.id
            } label: {
                Label("新建文档", systemImage: "doc.badge.plus")
            }
            Button {
                let meeting = meetingStore.createMeeting(
                    title: "会议 \(Date.now.formatted(date: .abbreviated, time: .shortened))",
                    inSpace: spaceID
                )
                meetingStore.selectedMeetingID = meeting.id
            } label: {
                Label("新建会议", systemImage: "waveform.badge.plus")
            }
            Divider()
            Button {
                if let sub = spaceStore.createSpace(name: "新建空间", parentID: spaceID) {
                    renameText = ""
                    renamingSpaceID = sub.id
                }
            } label: {
                Label("新建子空间", systemImage: "folder.badge.plus")
            }
        } label: {
            Image(systemName: "plus")
                .accessibilityLabel("新建项目")
        }
        .help("新建项目")
    }

    // MARK: - Content List

    func contentList(_ items: [SpaceItem]) -> some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(items) { item in
                    switch item {
                    case let .space(child):
                        spaceRow(child)
                            .draggable(WorkspaceDragItem(id: child.id, type: .space))
                            .dropDestination(for: WorkspaceDragItem.self) { items, _ in
                                handleDrop(items, intoSpace: child.id)
                            }
                    case let .document(doc):
                        documentRow(doc)
                            .draggable(WorkspaceDragItem(id: doc.id, type: .document))
                    case let .meeting(meeting):
                        meetingRow(meeting)
                            .draggable(WorkspaceDragItem(id: meeting.id, type: .meeting))
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Content Grid

    func contentGrid(_ items: [SpaceItem]) -> some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 200, maximum: 280), spacing: 16)],
                spacing: 16
            ) {
                ForEach(items) { item in
                    switch item {
                    case let .space(child):
                        spaceGridCard(child)
                            .draggable(WorkspaceDragItem(id: child.id, type: .space))
                            .dropDestination(for: WorkspaceDragItem.self) { items, _ in
                                handleDrop(items, intoSpace: child.id)
                            }
                    case let .document(doc):
                        documentGridCard(doc)
                            .draggable(WorkspaceDragItem(id: doc.id, type: .document))
                    case let .meeting(meeting):
                        meetingGridCard(meeting)
                            .draggable(WorkspaceDragItem(id: meeting.id, type: .meeting))
                    }
                }
            }
            .padding(24)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView {
            Label("空空间", systemImage: "folder")
        } description: {
            Text("添加文档、会议或子空间来整理你的工作。")
        } actions: {
            HStack(spacing: 12) {
                Button("新建文档") {
                    let doc = documentStore.createDocument(inSpace: spaceID)
                    documentStore.selectedDocumentID = doc.id
                }
                .buttonStyle(.borderedProminent)
                .tint(AppThemeConstants.accent)

                Button("新建会议") {
                    let meeting = meetingStore.createMeeting(
                        title: "会议 \(Date.now.formatted(date: .abbreviated, time: .shortened))",
                        inSpace: spaceID
                    )
                    meetingStore.selectedMeetingID = meeting.id
                }
                .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
