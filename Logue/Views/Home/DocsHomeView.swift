import SwiftUI

// MARK: - DocsHomeView

/// Minimal fallback view - should rarely be shown due to auto-select
struct DocsHomeView: View {
    @Environment(DocumentStore.self) private var store
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack {
            ProgressView()
                .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppThemeConstants.contentBackground)
        .navigationTitle("文档")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    let doc = store.createDocument()
                    store.selectedDocumentID = doc.id
                } label: {
                    Image(systemName: "square.and.pencil")
                        .accessibilityLabel("新建文档")
                }
                .help("新建文档")
            }
        }
    }
}
