import SwiftUI

/// Grammarly-style document card shown in the Docs home grid.
struct DocumentCardView: View {
    @Environment(DocumentStore.self) private var store
    let document: WritingDocument

    @State private var showMenu = false
    @State private var showDeleteConfirmation = false
    @State private var showRenameAlert = false
    @State private var renameText = ""

    var body: some View {
        HomeCardShell(
            action: { store.selectedDocumentID = document.id },
            content: { isHovered in cardBody(isHovered: isHovered) },
            contextMenu: { contextMenuItems }
        )
        .alert("删除文档？", isPresented: $showDeleteConfirmation) {
            Button("删除", role: .destructive) {
                store.deleteDocument(id: document.id)
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("“\(document.title)”将被永久删除。")
        }
        .alert("重命名文档", isPresented: $showRenameAlert) {
            TextField("标题", text: $renameText)
            Button("重命名") {
                store.renameDocument(id: document.id, newTitle: renameText)
            }
            Button("取消", role: .cancel) {}
        }
    }

    // MARK: - Card Body

    private func cardBody(isHovered: Bool) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Preview area
            ZStack(alignment: .topLeading) {
                AppThemeConstants.chromeBackground
                    .frame(maxWidth: .infinity)
                    .frame(height: 110)

                if !document.snippet.isEmpty {
                    Text(document.snippet)
                        .font(.caption2)
                        .foregroundStyle(AppThemeConstants.mutedText)
                        .lineLimit(10)
                        .padding(AppThemeConstants.paddingSmall)
                }
            }

            Divider()

            // Footer
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    DocumentIconLabel(
                        icon: document.icon,
                        fallbackSymbol: "doc.text.fill",
                        font: .caption2,
                        fallbackStyle: AppThemeConstants.accent
                    )
                    Text(document.title)
                        .font(.subheadline.weight(.medium))
                        .lineLimit(1)
                        .foregroundStyle(.primary)
                        .help(document.title)
                    Spacer()
                    if isHovered {
                        Button {
                            showMenu = true
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.caption)
                                .padding(4)
                                .background(.quaternary, in: RoundedRectangle(cornerRadius: AppThemeConstants.radiusXSmall))
                        }
                        .buttonStyle(.plain)
                        .help("文档选项")
                        .accessibilityLabel("文档选项")
                        .popover(isPresented: $showMenu, arrowEdge: .bottom) {
                            cardMenuContent
                        }
                    }
                }
                Text("编辑于 \(document.modifiedAt.formatted(.relative(presentation: .named)))")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, AppThemeConstants.paddingSmall)
            .padding(.vertical, AppThemeConstants.paddingSmall)
        }
    }

    // MARK: - Popover Menu

    private var cardMenuContent: some View {
        VStack(alignment: .leading, spacing: 2) {
            Button {
                store.togglePin(id: document.id)
                showMenu = false
            } label: {
                Label(
                    document.isPinned ? "取消置顶" : "置顶",
                    systemImage: document.isPinned ? "pin.slash" : "pin"
                )
                .font(.subheadline)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)

            Button {
                showMenu = false
                renameText = document.title
                showRenameAlert = true
            } label: {
                Label("重命名", systemImage: "pencil")
                    .font(.subheadline)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)

            Divider()

            Button(role: .destructive) {
                showMenu = false
                showDeleteConfirmation = true
            } label: {
                Label("移到废纸篓", systemImage: "trash")
                    .font(.subheadline)
                    .foregroundStyle(AppThemeConstants.error)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
        .padding(.vertical, 6)
        .frame(minWidth: 180)
    }

    // MARK: - Context Menu

    @ViewBuilder
    private var contextMenuItems: some View {
        Button {
            store.selectedDocumentID = document.id
        } label: {
            Label("打开", systemImage: "doc.text")
        }
        Button {
            store.togglePin(id: document.id)
        } label: {
            Label(
                document.isPinned ? "取消置顶" : "置顶",
                systemImage: document.isPinned ? "pin.slash" : "pin"
            )
        }
        Button {
            renameText = document.title
            showRenameAlert = true
        } label: {
            Label("重命名", systemImage: "pencil")
        }
        Divider()
        Button(role: .destructive) {
            showDeleteConfirmation = true
        } label: {
            Label("移到废纸篓", systemImage: "trash")
        }
    }
}
