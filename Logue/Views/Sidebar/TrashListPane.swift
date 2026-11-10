import SwiftUI

// MARK: - Trash Item

private enum TrashItem: Identifiable {
    case document(WritingDocument)
    case meeting(MeetingNote)

    var id: UUID {
        switch self {
        case let .document(doc): doc.id
        case let .meeting(note): note.id
        }
    }

    var title: String {
        switch self {
        case let .document(doc): doc.title
        case let .meeting(note): note.title
        }
    }

    var icon: String {
        switch self {
        case .document: "doc.text"
        case let .meeting(note): note.recordingMode.iconName
        }
    }

    var iconColor: Color {
        switch self {
        case .document: AppThemeConstants.categoryPurple
        case .meeting: AppThemeConstants.accent
        }
    }

    var typeBadge: String {
        switch self {
        case .document: "文档"
        case .meeting: "会议"
        }
    }

    var trashedAt: Date? {
        switch self {
        case let .document(doc): doc.trashedAt
        case let .meeting(note): note.trashedAt
        }
    }

    var subtitle: String {
        switch self {
        case let .document(doc):
            return "\(doc.wordCount) 字"
        case let .meeting(note):
            var parts: [String] = []
            if note.duration > 0 {
                parts.append(note.formattedDuration)
            }
            if !note.segments.isEmpty {
                parts.append("\(note.segments.count) 个片段")
            }
            return parts.isEmpty ? "会议" : parts.joined(separator: " \u{00B7} ")
        }
    }
}

// MARK: - TrashListPane

/// Shows all trashed documents and meetings with restore and permanent delete actions.
struct TrashListPane: View {
    @Environment(DocumentStore.self) private var documentStore
    @Environment(MeetingStore.self) private var meetingStore
    @Environment(\.colorScheme) private var colorScheme

    @State private var searchText = ""
    @State private var showEmptyConfirmation = false
    @AppStorage(AppConstants.UserDefaultsKeys.trashViewMode) private var viewModeRaw = ContentViewMode.list.rawValue

    private var viewMode: ContentViewMode {
        ContentViewMode(rawValue: viewModeRaw) ?? .list
    }

    private var allTrashItems: [TrashItem] {
        let docs: [TrashItem] = documentStore.trashedDocuments.map { .document($0) }
        let meetings: [TrashItem] = meetingStore.trashedMeetings.map { .meeting($0) }
        return (docs + meetings).sorted { ($0.trashedAt ?? .distantPast) > ($1.trashedAt ?? .distantPast) }
    }

    private var trashItems: [TrashItem] {
        guard !searchText.isEmpty else { return allTrashItems }
        return allTrashItems.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        Group {
            if !documentStore.isLoaded || !meetingStore.isLoaded {
                ContentLoadingView()
            } else if allTrashItems.isEmpty {
                emptyState
            } else if trashItems.isEmpty {
                searchEmptyState
            } else if viewMode == .grid {
                trashGrid
            } else {
                trashList
            }
        }
        .background(AppThemeConstants.contentBackground)
        .navigationTitle("废纸篓")
        .navigationSubtitle("\(allTrashItems.count) 个项目")
        .searchable(text: $searchText, placement: .toolbar, prompt: "搜索废纸篓")
        .toolbar {
            trashToolbarContent
        }
        .alert("清空废纸篓？", isPresented: $showEmptyConfirmation) {
            Button("取消", role: .cancel) {}
            Button("清空废纸篓", role: .destructive) {
                documentStore.emptyDocumentTrash()
                meetingStore.emptyMeetingTrash()
            }
        } message: {
            Text("这将永久删除全部 \(allTrashItems.count) 个项目。此操作无法撤销。")
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var trashToolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            if !allTrashItems.isEmpty {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModeRaw = viewMode == .list
                            ? ContentViewMode.grid.rawValue
                            : ContentViewMode.list.rawValue
                    }
                } label: {
                    Image(systemName: viewMode == .list ? "square.grid.2x2" : "list.bullet")
                }
                .accessibilityLabel(viewMode == .list ? "切换到网格视图" : "切换到列表视图")
                .accessibilityHint("在列表和网格布局之间切换")
                .help(viewMode == .list ? "网格视图" : "列表视图")

                Button(role: .destructive) {
                    showEmptyConfirmation = true
                } label: {
                    Label("清空废纸篓", systemImage: "trash.slash")
                }
                .accessibilityLabel("清空废纸篓")
                .accessibilityHint("永久删除废纸篓中的所有项目")
                .help("永久删除废纸篓中的所有项目")
            }
        }
    }

    // MARK: - Trash List

    private var trashList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(trashItems) { item in
                    trashRow(item)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
        }
    }

    private func trashRow(_ item: TrashItem) -> some View {
        HStack(spacing: 12) {
            Image(systemName: item.icon)
                .font(.title3)
                .foregroundStyle(item.iconColor)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.body.weight(.medium))
                    .lineLimit(1)
                HStack(spacing: 8) {
                    Text(item.typeBadge)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 1)
                        .background(
                            item.iconColor.opacity(AppThemeConstants.opacityLight),
                            in: RoundedRectangle(cornerRadius: AppThemeConstants.radiusXSmall)
                        )
                    Text(item.subtitle)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    if let trashedAt = item.trashedAt {
                        Text("\u{00B7}")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                        Text("删除于 \(trashedAt.formatted(.relative(presentation: .named)))")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: AppThemeConstants.radiusLarge)
                .fill(AppThemeConstants.surfaceBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppThemeConstants.radiusLarge)
                .stroke(AppThemeConstants.borderColor, lineWidth: 0.5)
        )
        .accessibilityLabel("\(item.title)，\(item.typeBadge)")
        .accessibilityHint("打开此项目的还原和删除操作")
        .sidebarRowMenu { trashItemContextMenu(item) }
    }

    // MARK: - Trash Grid

    private var trashGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 200, maximum: 280), spacing: 16)],
                spacing: 16
            ) {
                ForEach(trashItems) { item in
                    trashGridCard(item)
                }
            }
            .padding(24)
        }
    }

    private func trashGridCard(_ item: TrashItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: item.icon)
                    .font(.title3)
                    .foregroundStyle(item.iconColor)
                Spacer()
                Text(item.typeBadge)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 1)
                    .background(
                        item.iconColor.opacity(AppThemeConstants.opacityLight),
                        in: RoundedRectangle(cornerRadius: AppThemeConstants.radiusXSmall)
                    )
            }

            Text(item.title)
                .font(.subheadline.weight(.semibold))
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Text(item.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Spacer(minLength: 0)

            if let trashedAt = item.trashedAt {
                Text("删除于 \(trashedAt.formatted(.relative(presentation: .named)))")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: AppThemeConstants.radiusLarge)
                .fill(AppThemeConstants.surfaceBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppThemeConstants.radiusLarge)
                .stroke(AppThemeConstants.borderColor, lineWidth: 0.5)
        )
        .accessibilityLabel("\(item.title)，\(item.typeBadge)")
        .accessibilityHint("打开此项目的还原和删除操作")
        .sidebarRowMenu { trashItemContextMenu(item) }
    }

    // MARK: - Context Menu

    @ViewBuilder
    private func trashItemContextMenu(_ item: TrashItem) -> some View {
        Button {
            restoreItem(item)
        } label: {
            Label("放回原处", systemImage: "arrow.uturn.backward")
        }
        Divider()
        Button(role: .destructive) {
            permanentlyDeleteItem(item)
        } label: {
            Label("永久删除", systemImage: "trash")
        }
    }

    // MARK: - Actions

    private func restoreItem(_ item: TrashItem) {
        switch item {
        case let .document(doc):
            documentStore.restoreDocument(id: doc.id)
        case let .meeting(note):
            meetingStore.restoreMeeting(id: note.id)
        }
    }

    private func permanentlyDeleteItem(_ item: TrashItem) {
        switch item {
        case let .document(doc):
            documentStore.permanentlyDeleteDocument(id: doc.id)
        case let .meeting(note):
            meetingStore.permanentlyDeleteMeeting(id: note.id)
        }
    }

    // MARK: - Empty States

    private var emptyState: some View {
        ContentUnavailableView {
            Label("废纸篓是空的", systemImage: "trash")
        } description: {
            Text("你删除的项目会显示在这里。")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var searchEmptyState: some View {
        ContentUnavailableView {
            Label("没有结果", systemImage: "magnifyingglass")
        } description: {
            Text("没有与“\(searchText)”匹配的项目")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
