import SwiftUI

enum SidebarSection: String, CaseIterable, Identifiable {
    case all = "All Documents"
    case recent = "Recent"
    case pinned = "Pinned"

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .all: "全部文档"
        case .recent: "最近"
        case .pinned: "已置顶"
        }
    }

    var icon: String {
        switch self {
        case .all: "doc.text"
        case .recent: "clock"
        case .pinned: "pin"
        }
    }
}

/// Primary sidebar: branding, home button, new doc, search, section pills, and document list.
struct DocumentSidebarView: View {
    @Environment(DocumentStore.self) private var store
    @Environment(MeetingStore.self) private var meetingStore
    @Environment(SpaceStore.self) private var spaceStore
    @Environment(\.openSettings) private var openSettings
    @State private var searchText = ""
    @State private var activeSection: SidebarSection = .all
    /// Which row is showing its "⋯", so that row's trailing badges can step aside for it.
    @State private var revealedRowID: UUID?

    private var filteredDocs: [WritingDocument] {
        let base: [WritingDocument] = switch activeSection {
        case .all: store.activeDocuments
        case .recent: store.recentDocuments
        case .pinned: store.pinnedDocuments
        }
        guard !searchText.isEmpty else { return base }
        return base.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.body.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            sidebarHeader
            searchBar
            Divider()
            sectionPills
            Divider()
            documentList
            Divider()
            sidebarFooter
        }
        .background(AppThemeConstants.chromeBackground)
    }

    // MARK: - Header

    private var sidebarHeader: some View {
        HStack(spacing: 8) {
            // Home button
            Button {
                store.selectedDocumentID = nil
                meetingStore.selectedMeetingID = nil
            } label: {
                Image(systemName: "house")
                    .font(.body)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("首页")
            .accessibilityHint("返回首页")
            .help("首页")

            Spacer()

            Button {
                store.createDocument()
            } label: {
                Image(systemName: "square.and.pencil")
                    .font(.body)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("新建文档")
            .accessibilityHint("创建新的空白文档")
            .help("新建文档")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .font(.callout)
            TextField("搜索", text: $searchText)
                .textFieldStyle(.plain)
                .font(.callout)
                .accessibilityLabel("搜索文档")
                .accessibilityHint("输入以筛选文档列表")
            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("清除搜索")
                .accessibilityHint("清除搜索文本")
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: AppThemeConstants.radiusSmall))
        .padding(.horizontal, 10)
        .padding(.bottom, 8)
    }

    // MARK: - Section Pills

    private var sectionPills: some View {
        HStack(spacing: 0) {
            ForEach(SidebarSection.allCases) { section in
                SectionPillButton(
                    section: section,
                    isActive: activeSection == section,
                    action: { activeSection = section }
                )
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
    }

    // MARK: - Document List

    @ViewBuilder
    private var documentList: some View {
        if !store.isLoaded {
            ContentLoadingView()
        } else if filteredDocs.isEmpty {
            ContentUnavailableView(
                searchText.isEmpty ? "没有文档" : "没有结果",
                systemImage: searchText.isEmpty ? "doc.text" : "magnifyingglass"
            )
            .font(.callout)
            .frame(maxHeight: .infinity)
        } else {
            List(filteredDocs, selection: Binding(
                get: { store.selectedDocumentID },
                set: { store.selectedDocumentID = $0 }
            )) { doc in
                DocumentListRow(document: doc, isRevealed: revealedRowID == doc.id)
                    .tag(doc.id)
                    .accessibilityLabel("\(doc.title)\(doc.isPinned ? "，已置顶" : "")")
                    .accessibilityHint("打开此文档")
                    .sidebarRowMenu(
                        isSelected: store.selectedDocumentID == doc.id,
                        revealed: $revealedRowID.isRevealed(doc.id)
                    ) {
                        docContextMenu(for: doc)
                    }
            }
            .listStyle(.sidebar)
            .tint(AppThemeConstants.accent)
        }
    }

    // MARK: - Footer

    private var sidebarFooter: some View {
        HStack {
            Button(action: { openSettings() }, label: {
                Label("设置", systemImage: "gear")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            })
            .buttonStyle(.plain)
            .accessibilityLabel("设置")
            .accessibilityHint("打开应用设置")
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    // MARK: - Context Menu

    @ViewBuilder
    private func docContextMenu(for doc: WritingDocument) -> some View {
        Button {
            store.selectedDocumentID = doc.id
        } label: {
            Label("打开", systemImage: "doc.text")
        }
        Button {
            store.togglePin(id: doc.id)
        } label: {
            Label(
                doc.isPinned ? "取消置顶" : "置顶",
                systemImage: doc.isPinned ? "pin.slash" : "pin"
            )
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

// MARK: - Section Pill Button

private struct SectionPillButton: View {
    let section: SidebarSection
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: section.icon)
                .font(.callout)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .foregroundStyle(isActive ? AppThemeConstants.accent : Color.secondary)
                .background(
                    isActive ? AppThemeConstants.accent.opacity(AppThemeConstants.activeOpacity) : Color.clear,
                    in: RoundedRectangle(cornerRadius: AppThemeConstants.radiusSmall)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(section.displayName)
        .accessibilityHint("筛选以显示\(section.displayName)")
        .accessibilityAddTraits(isActive ? .isSelected : [])
        .help(section.displayName)
    }
}

// MARK: - Document List Row

struct DocumentListRow: View {
    let document: WritingDocument
    /// Whether the row's "⋯" button is showing, so the trailing badges and date can step aside.
    var isRevealed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Text(document.title)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                Spacer()
                if document.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.caption2)
                        .foregroundStyle(AppThemeConstants.pinnedColor)
                        .opacity(isRevealed ? 0 : 1)
                }
                if let score = document.score {
                    Text("\(Int(score.overall))")
                        .font(.caption2.bold())
                        .foregroundStyle(scoreColor(score.overall))
                        .opacity(isRevealed ? 0 : 1)
                }
            }
            Text(document.snippet.isEmpty ? "空文档" : document.snippet)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            HStack {
                Text(document.readingTimeLabel)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Spacer()
                Text(document.modifiedAt.formatted(.relative(presentation: .named)))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .opacity(isRevealed ? 0 : 1)
            }
        }
        .padding(.vertical, 4)
        .animation(.easeInOut(duration: AppThemeConstants.hoverDuration), value: isRevealed)
    }

    private func scoreColor(_ score: Double) -> Color {
        score >= 85 ? AppThemeConstants.success : score >= 70 ? AppThemeConstants.warning : AppThemeConstants.error
    }
}
