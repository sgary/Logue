import SwiftUI

// MARK: - Sort & Filter Options

enum DocSortOrder: String, CaseIterable {
    case modifiedNewest = "Last Modified"
    case modifiedOldest = "Oldest Modified"
    case titleAZ = "Title A–Z"
    case titleZA = "Title Z–A"
    case createdNewest = "Newest Created"
    case createdOldest = "Oldest Created"

    var displayName: String {
        switch self {
        case .modifiedNewest: "最近修改"
        case .modifiedOldest: "最早修改"
        case .titleAZ: "标题 A–Z"
        case .titleZA: "标题 Z–A"
        case .createdNewest: "最近创建"
        case .createdOldest: "最早创建"
        }
    }

    /// The nearest equivalent a saved view can store.
    ///
    /// `SavedViewSort` has no created-at cases, so those fall back to modified in the same
    /// direction rather than silently becoming the default.
    var asSavedViewSort: SavedViewSort {
        switch self {
        case .modifiedNewest, .createdNewest: .recentlyModified
        case .modifiedOldest, .createdOldest: .oldestModified
        case .titleAZ: .titleAscending
        case .titleZA: .titleDescending
        }
    }

    var icon: String {
        switch self {
        case .modifiedNewest, .createdNewest: "arrow.down"
        case .modifiedOldest, .createdOldest: "arrow.up"
        case .titleAZ: "textformat.abc"
        case .titleZA: "textformat.abc"
        }
    }

    var isDateBased: Bool {
        switch self {
        case .modifiedNewest, .modifiedOldest, .createdNewest, .createdOldest: true
        case .titleAZ, .titleZA: false
        }
    }

    var dateKeyPath: KeyPath<WritingDocument, Date>? {
        switch self {
        case .modifiedNewest, .modifiedOldest: \.modifiedAt
        case .createdNewest, .createdOldest: \.createdAt
        default: nil
        }
    }
}

enum DocFilterMode: String, CaseIterable {
    case all = "All Documents"
    case inbox = "Inbox"
    case pinned = "Pinned"
    case recent = "Recent"

    var displayName: String {
        switch self {
        case .all: "全部文档"
        case .inbox: "收件箱"
        case .pinned: "已置顶"
        case .recent: "最近"
        }
    }

    var icon: String {
        switch self {
        case .all: "doc.text"
        case .inbox: "tray"
        case .pinned: "pin"
        case .recent: "clock"
        }
    }
}

// MARK: - DocumentListPane

/// Column 2 content when Documents category is selected.
/// Shows search, filter/sort/view menus, and a selectable document list or gallery.
struct DocumentListPane: View {
    // Extension-visible: +Organise
    @Environment(DocumentStore.self) var store
    @Environment(SpaceStore.self) private var spaceStore
    @Environment(\.colorScheme) private var colorScheme
    @Binding var selectedItem: ContentListItem?
    // Extension-visible: +Organise
    @State var searchText = ""
    // Extension-visible: +Organise
    @State var filterMode: DocFilterMode = .all
    // Extension-visible: +Organise
    @State var sortOrder: DocSortOrder = .modifiedNewest
    @State private var renamingDocID: UUID?
    @State private var renameText = ""
    /// Which row is showing its "⋯", so that row's trailing badges can step aside for it.
    @State private var revealedRowID: UUID?
    @FocusState private var isRenameFieldFocused: Bool
    @State private var hasAutoSelected = false
    // Extension-visible: +Organise
    /// Active saved view, when one is chosen instead of a built-in filter.
    @State var activeSavedViewID: UUID?
    // Extension-visible: +Organise
    /// Active type filter, when one is chosen.
    @State var activeTypeName: String?
    // Extension-visible: +Organise
    /// The naming prompt currently up, if any.
    @State var organisePrompt: OrganisePrompt?
    /// Documents ticked for a bulk action. Non-empty shows the bulk bar.
    @State private var bulkSelection: Set<UUID> = []
    @State private var bulkTagText = ""
    @State private var showingBulkTagField = false

    private var filteredDocs: [WritingDocument] {
        let base: [WritingDocument] = if let activeSavedViewID {
            store.documents(matching: activeSavedViewID)
        } else if let activeTypeName {
            store.activeDocuments.filter { $0.typeName == activeTypeName }
        } else {
            switch filterMode {
            case .all: store.activeDocuments
            case .inbox: store.inboxDocuments
            case .recent: store.recentDocuments
            case .pinned: store.pinnedDocuments
            }
        }
        let searched: [WritingDocument] = if searchText.isEmpty {
            base
        } else {
            base.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                    $0.body.localizedCaseInsensitiveContains(searchText)
            }
        }
        return sorted(searched)
    }

    private func sorted(_ docs: [WritingDocument]) -> [WritingDocument] {
        switch sortOrder {
        case .modifiedNewest: docs.sorted { $0.modifiedAt > $1.modifiedAt }
        case .modifiedOldest: docs.sorted { $0.modifiedAt < $1.modifiedAt }
        case .titleAZ: docs.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .titleZA: docs.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedDescending }
        case .createdNewest: docs.sorted { $0.createdAt > $1.createdAt }
        case .createdOldest: docs.sorted { $0.createdAt < $1.createdAt }
        }
    }

    var body: some View {
        listView
            .searchable(text: $searchText, prompt: "搜索文档")
            .navigationTitle("文档")
            .sheet(item: $organisePrompt) { prompt in
                OrganiseNamingSheet(prompt: prompt) { name in
                    commitOrganisePrompt(prompt, name: name)
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        // Filter
                        Section("筛选") {
                            ForEach(DocFilterMode.allCases, id: \.rawValue) { mode in
                                Button {
                                    filterMode = mode
                                    activeSavedViewID = nil
                                    activeTypeName = nil
                                } label: {
                                    HStack {
                                        Label(mode.displayName, systemImage: mode.icon)
                                        if filterMode == mode {
                                            Spacer()
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        }

                        Section("视图") {
                            ForEach(store.savedViews) { view in
                                Button {
                                    activeSavedViewID = view.id
                                    activeTypeName = nil
                                } label: {
                                    HStack {
                                        Label(view.name, systemImage: view.symbolName)
                                        if activeSavedViewID == view.id {
                                            Spacer()
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }

                            Divider()

                            Button {
                                organisePrompt = .newView
                            } label: {
                                Label("将当前筛选保存为视图…", systemImage: "plus")
                            }

                            if let active = store.savedViews.first(where: { $0.id == activeSavedViewID }) {
                                Button {
                                    organisePrompt = .renameView(active)
                                } label: {
                                    Label("重命名此视图…", systemImage: "pencil")
                                }
                                Button(role: .destructive) {
                                    deleteSavedView(active)
                                } label: {
                                    Label("删除此视图", systemImage: "trash")
                                }
                            }
                        }

                        if !store.documentTypes.isEmpty {
                            Section("类型") {
                                ForEach(DocumentType.ordered(store.documentTypes)) { type in
                                    Button {
                                        activeTypeName = type.name
                                        activeSavedViewID = nil
                                    } label: {
                                        HStack {
                                            Label(type.name, systemImage: type.symbolName)
                                            if activeTypeName == type.name {
                                                Spacer()
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }

                                if let active = store.documentTypes.first(where: { $0.name == activeTypeName }) {
                                    Divider()
                                    Button {
                                        organisePrompt = .renameType(active)
                                    } label: {
                                        Label("重命名此类型…", systemImage: "pencil")
                                    }
                                    Button(role: .destructive) {
                                        deleteType(active)
                                    } label: {
                                        Label("删除此类型", systemImage: "trash")
                                    }
                                }
                            }
                        }

                        // Sort
                        Section("排序方式") {
                            ForEach(DocSortOrder.allCases, id: \.rawValue) { order in
                                Button {
                                    sortOrder = order
                                } label: {
                                    HStack {
                                        Text(order.displayName)
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
                    .accessibilityLabel("筛选和排序选项")
                    .accessibilityHint("打开菜单以筛选、排序和配置文档视图")
                    .help("筛选、排序和视图选项")
                }
            }
            .onAppear {
                hasAutoSelected = false
                autoSelectFirst()
            }
            .onChange(of: store.activeDocuments.count) { _, _ in
                hasAutoSelected = false
                autoSelectFirst()
            }
            .onChange(of: selectedItem) { _, newValue in
                // If selection is cleared, auto-select again
                if newValue == nil {
                    hasAutoSelected = false
                    DispatchQueue.main.async {
                        autoSelectFirst()
                    }
                }
            }
    }

    // MARK: - Auto-select first

    private func autoSelectFirst() {
        guard !hasAutoSelected, selectedItem == nil else { return }

        // If no documents exist, create one
        if store.activeDocuments.isEmpty {
            let newDoc = store.createDocument()
            selectedItem = .document(newDoc.id)
            hasAutoSelected = true
            return
        }

        // Otherwise select the first document
        if let first = filteredDocs.first {
            selectedItem = .document(first.id)
            hasAutoSelected = true
        }
    }

    // MARK: - List View

    private var listView: some View {
        VStack(spacing: 0) {
            if filterMode == .inbox, activeSavedViewID == nil, activeTypeName == nil {
                inboxHeader
            }
            if !bulkSelection.isEmpty {
                bulkActionBar
            }
            documentList
        }
    }

    /// Explains the inbox rather than showing an unexplained subset of documents.
    private var inboxHeader: some View {
        HStack(spacing: 6) {
            Image(systemName: "tray")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(store.inboxCount) 个待整理")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.quaternary.opacity(0.4))
    }

    /// Shown while documents are ticked. Every action here is reversible except
    /// Trash, which moves to Trash rather than deleting outright.
    private var bulkActionBar: some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                Text("已选择 \(bulkSelection.count) 个")
                    .font(.caption.weight(.medium))

                Spacer()

                Button("标签") { showingBulkTagField.toggle() }
                    .font(.caption)

                if filterMode == .inbox {
                    Button("整理") {
                        store.applyBulk(to: bulkSelection) { BulkAction.markingOrganised($0) }
                        bulkSelection.removeAll()
                    }
                    .font(.caption)
                }

                Button("移到废纸篓", role: .destructive) {
                    store.applyBulk(to: bulkSelection) { BulkAction.trashing($0) }
                    bulkSelection.removeAll()
                }
                .font(.caption)

                Button("清除") { bulkSelection.removeAll() }
                    .font(.caption)
            }

            if showingBulkTagField {
                HStack(spacing: 6) {
                    TextField("标签名称", text: $bulkTagText)
                        .textFieldStyle(.roundedBorder)
                        .font(.caption)
                        .onSubmit(applyBulkTag)
                    Button("添加", action: applyBulkTag)
                        .font(.caption)
                        .disabled(bulkTagText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(AppThemeConstants.accent.opacity(0.10))
    }

    private func applyBulkTag() {
        let tag = bulkTagText
        guard !tag.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        store.applyBulk(to: bulkSelection) { BulkAction.addingTag(tag, to: $0) }
        bulkTagText = ""
        showingBulkTagField = false
        bulkSelection.removeAll()
    }

    private var documentList: some View {
        List(selection: $selectedItem) {
            ForEach(filteredDocs) { doc in
                if renamingDocID == doc.id {
                    renameField(for: doc)
                        .tag(ContentListItem.document(doc.id))
                } else {
                    DocumentListRow(document: doc, isRevealed: revealedRowID == doc.id)
                        .tag(ContentListItem.document(doc.id))
                        .accessibilityLabel("\(doc.title)\(doc.isPinned ? "，已置顶" : "")")
                        .accessibilityHint("打开此文档")
                        .sidebarRowMenu(
                            isSelected: selectedItem == .document(doc.id),
                            revealed: $revealedRowID.isRevealed(doc.id)
                        ) {
                            docContextMenu(for: doc)
                        }
                }
            }
        }
        .listStyle(.inset)
        .scrollContentBackground(.hidden)
        .background(AppThemeConstants.surfaceBackground)
        .overlay {
            if !store.isLoaded {
                ContentLoadingView()
            } else if filteredDocs.isEmpty {
                ContentUnavailableView(
                    searchText.isEmpty ? "没有文档" : "没有结果",
                    systemImage: searchText.isEmpty ? "doc.text" : "magnifyingglass"
                )
            }
        }
    }

    // MARK: - Rename

    private func renameField(for doc: WritingDocument) -> some View {
        TextField("标题", text: $renameText, onCommit: {
            store.renameDocument(id: doc.id, newTitle: renameText)
            renamingDocID = nil
        })
        .focused($isRenameFieldFocused)
        .textFieldStyle(.plain)
        .font(.subheadline.weight(.medium))
        .padding(.vertical, 4)
        .onExitCommand {
            renamingDocID = nil
        }
        .onAppear {
            renameText = doc.title
            isRenameFieldFocused = true
        }
    }

    // MARK: - Context Menu

    @ViewBuilder
    private func docContextMenu(for doc: WritingDocument) -> some View {
        Button(bulkSelection.contains(doc.id) ? "取消选择" : "选择以批量操作") {
            if bulkSelection.contains(doc.id) {
                bulkSelection.remove(doc.id)
            } else {
                bulkSelection.insert(doc.id)
            }
        }

        if !store.documentTypes.isEmpty {
            Menu("设置类型") {
                Button("从此文档新建类型…") {
                    organisePrompt = .newType(doc)
                }
                Divider()
                ForEach(DocumentType.ordered(store.documentTypes)) { type in
                    Button(type.name) { store.applyType(type, to: doc.id) }
                }
            }
        }

        Button(doc.isOrganised ? "移到收件箱" : "标记为已整理") {
            if doc.isOrganised {
                var updated = doc
                updated.isOrganised = false
                store.updateDocument(updated)
            } else {
                store.markOrganised(id: doc.id)
            }
        }

        Divider()

        Button {
            store.togglePin(id: doc.id)
        } label: {
            Label(
                doc.isPinned ? "取消置顶" : "置顶",
                systemImage: doc.isPinned ? "pin.slash" : "pin"
            )
        }
        Button {
            renameText = doc.title
            renamingDocID = doc.id
        } label: {
            Label("重命名", systemImage: "pencil")
        }
        if !spaceStore.topLevelSpaces.isEmpty || doc.spaceID != nil {
            Menu("移动到") {
                HierarchicalSpaceMenu(currentSpaceID: doc.spaceID) { newSpaceID in
                    store.moveDocument(id: doc.id, toSpace: newSpaceID)
                }
            }
        }
        Button {
            PDFExportService.export(document: doc)
        } label: {
            Label("导出为 PDF", systemImage: "arrow.down.doc")
        }
        Divider()
        Button(role: .destructive) {
            store.deleteDocument(id: doc.id)
        } label: {
            Label("移到废纸篓", systemImage: "trash")
        }
    }
}
