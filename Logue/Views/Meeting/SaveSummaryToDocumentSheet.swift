import SwiftUI

/// Sheet for saving a meeting's Smart Minutes as a markdown document.
struct SaveSummaryToDocumentSheet: View {
    @Binding var isPresented: Bool
    let meeting: MeetingNote
    /// Called after a successful save with the document ID.
    var onSaved: ((UUID) -> Void)?

    @Environment(DocumentStore.self) private var documentStore
    @Environment(SpaceStore.self) private var spaceStore

    // Selection state
    @State private var selectedSpaceID: UUID?
    @State private var documentTarget: DocumentTarget = .newDocument
    @State private var selectedDocumentID: UUID?
    @State private var newDocTitle = ""

    // New space inline creation
    @State private var showNewSpaceField = false
    @State private var newSpaceName = ""
    @FocusState private var isNewSpaceFocused: Bool

    enum DocumentTarget {
        case newDocument
        case existingDocument
    }

    // MARK: - Available Documents

    private var availableDocuments: [WritingDocument] {
        if let spaceID = selectedSpaceID {
            return documentStore.documents(inSpace: spaceID)
        }
        return documentStore.activeDocuments
    }

    private var canSave: Bool {
        switch documentTarget {
        case .newDocument:
            true
        case .existingDocument:
            selectedDocumentID != nil
        }
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.down.on.square")
                    .font(.title3)
                    .foregroundStyle(AppThemeConstants.accent)
                Text("保存到文档")
                    .font(.title3.bold())
            }

            // Space picker
            spaceSection

            // Document target
            targetSection

            // Conditional detail
            switch documentTarget {
            case .newDocument:
                titleField
            case .existingDocument:
                documentPicker
            }

            // Action buttons
            HStack {
                Button("取消") {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)
                .accessibilityLabel("取消")
                .accessibilityHint("关闭保存面板且不保存")

                Spacer()

                Button("保存") {
                    performSave()
                }
                .buttonStyle(.borderedProminent)
                .tint(AppThemeConstants.accent)
                .keyboardShortcut(.defaultAction)
                .disabled(!canSave)
                .accessibilityLabel("保存摘要")
                .accessibilityHint("将会议摘要保存到所选文档")
            }
        }
        .padding(24)
        .frame(width: 420)
        .onAppear {
            newDocTitle = "\(meeting.title) — 会议纪要"
        }
    }

    // MARK: - Space Section

    private var spaceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("空间")
                .font(.subheadline.weight(.medium))

            Picker("", selection: $selectedSpaceID) {
                Text("无空间").tag(UUID?.none)
                ForEach(spaceStore.topLevelSpaces) { space in
                    Label(space.name, systemImage: space.icon ?? "folder")
                        .tag(Optional(space.id))
                }
            }
            .labelsHidden()

            if showNewSpaceField {
                HStack(spacing: 8) {
                    Image(systemName: "folder.badge.plus")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    TextField("空间名称", text: $newSpaceName, onCommit: {
                        createNewSpace()
                    })
                    .textFieldStyle(.roundedBorder)
                    .focused($isNewSpaceFocused)
                    .onExitCommand {
                        showNewSpaceField = false
                        newSpaceName = ""
                    }
                    Button("添加") {
                        createNewSpace()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppThemeConstants.accent)
                    .controlSize(.small)
                    .disabled(newSpaceName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityLabel("添加空间")
                    .accessibilityHint("使用输入的名称创建新空间")
                }
            } else {
                Button {
                    newSpaceName = ""
                    showNewSpaceField = true
                    Task {
                        try? await Task.sleep(for: AppConstants.Delays.focusActivation)
                        isNewSpaceFocused = true
                    }
                } label: {
                    Label("新建空间", systemImage: "plus")
                        .font(.callout)
                        .foregroundStyle(AppThemeConstants.accent)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("新建空间")
                .accessibilityHint("显示用于创建新空间的输入框")
            }
        }
    }

    private func createNewSpace() {
        let trimmed = newSpaceName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard let space = spaceStore.createSpace(name: trimmed) else { return }
        selectedSpaceID = space.id
        showNewSpaceField = false
        newSpaceName = ""
    }

    // MARK: - Target Section

    private var targetSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("保存到")
                .font(.subheadline.weight(.medium))

            SelectableOptionCard(
                icon: "doc.badge.plus",
                title: "新建文档",
                description: "创建一个包含摘要的新文档",
                isSelected: documentTarget == .newDocument
            ) {
                documentTarget = .newDocument
            }

            SelectableOptionCard(
                icon: "doc.text",
                title: "现有文档",
                description: "将摘要追加到现有文档",
                isSelected: documentTarget == .existingDocument
            ) {
                documentTarget = .existingDocument
            }
        }
    }

    // MARK: - New Document Title

    private var titleField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("标题")
                .font(.subheadline.weight(.medium))
            TextField("文档标题", text: $newDocTitle)
                .textFieldStyle(.roundedBorder)
        }
    }

    // MARK: - Existing Document Picker

    private var documentPicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("文档")
                .font(.subheadline.weight(.medium))

            if availableDocuments.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Text(selectedSpaceID != nil ? "此空间中没有文档" : "没有可用的文档")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: AppThemeConstants.radiusMedium)
                        .fill(Color.primary.opacity(AppThemeConstants.opacitySubtle))
                )
            } else {
                Picker("", selection: $selectedDocumentID) {
                    Text("选择文档…").tag(UUID?.none)
                    ForEach(availableDocuments) { doc in
                        Text(doc.title).tag(Optional(doc.id))
                    }
                }
                .labelsHidden()
            }
        }
    }

    // MARK: - Save

    private func performSave() {
        let markdown = meeting.smartMinutesMarkdown()

        if documentTarget == .newDocument {
            let title = newDocTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? "\(meeting.title) — 会议纪要"
                : newDocTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            let doc = documentStore.createDocument(title: title, inSpace: selectedSpaceID)
            var updated = doc
            updated.body = markdown
            documentStore.updateDocument(updated)
            onSaved?(doc.id)
            isPresented = false
        } else if let existingID = selectedDocumentID,
                  let existing = documentStore.activeDocuments.first(where: { $0.id == existingID })
        {
            var updated = existing
            let separator = updated.body.isEmpty ? "" : "\n\n---\n\n"
            updated.body += separator + markdown
            documentStore.updateDocument(updated)
            onSaved?(existing.id)
            isPresented = false
        }
    }
}
