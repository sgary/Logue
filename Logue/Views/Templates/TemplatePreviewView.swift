import SwiftUI
import Textual

struct TemplatePreviewView: View {
    let template: DocumentTemplate
    @Environment(DocumentStore.self) private var documentStore
    @Environment(TemplateStore.self) private var templateStore
    @Environment(\.dismiss) private var dismiss

    @State private var showDeleteConfirmation = false
    @State private var templateToEdit: DocumentTemplate?

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header

            HStack(alignment: .center, spacing: 14) {
                Image(systemName: template.icon)
                    .font(.system(size: 32))
                    .foregroundStyle(AppThemeConstants.accent)

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(template.name)
                            .font(.title3)
                            .fontWeight(.semibold)

                        if !template.isBuiltIn {
                            Text("自定义")
                                .font(.caption2)
                                .foregroundStyle(AppThemeConstants.accent)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(AppThemeConstants.accent.opacity(AppThemeConstants.opacityLight))
                                )
                        }
                    }

                    if !template.description.isEmpty {
                        Text(template.description)
                            .font(.subheadline)
                            .foregroundStyle(AppThemeConstants.mutedText)
                            .lineLimit(2)
                    }
                }

                Spacer()

                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, AppThemeConstants.paddingLarge)
            .padding(.vertical, AppThemeConstants.paddingMedium)

            Divider()

            // MARK: - Markdown Body Preview

            ScrollView {
                StructuredText(markdown: Self.renderCheckboxes(template.body))
                    .font(.callout)
                    .textual.structuredTextStyle(.gitHub)
                    .textual.inlineStyle(.gitHub)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(AppThemeConstants.paddingLarge)
            }

            Divider()

            // MARK: - Bottom Bar

            HStack {
                if template.isBuiltIn {
                    Button {
                        duplicateAsCustom()
                    } label: {
                        Label("复制为自定义模板", systemImage: "doc.on.doc")
                    }
                } else {
                    Button {
                        templateToEdit = template
                    } label: {
                        Label("编辑", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("删除", systemImage: "trash")
                    }
                }

                Spacer()

                Button {
                    let doc = documentStore.createDocument(title: template.name, body: template.body)
                    documentStore.selectedDocumentID = doc.id
                    dismiss()
                } label: {
                    Label("使用模板", systemImage: "doc.badge.plus")
                }
                .buttonStyle(.borderedProminent)
                .tint(AppThemeConstants.accent)
            }
            .padding(AppThemeConstants.paddingLarge)
        }
        .frame(minWidth: 600, maxWidth: 600, minHeight: 500, maxHeight: 700)
        .background(AppThemeConstants.contentBackground)
        .alert("删除模板", isPresented: $showDeleteConfirmation) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                templateStore.deleteTemplate(id: template.id)
                dismiss()
            }
        } message: {
            Text("确定要删除“\(template.name)”吗？此操作无法撤销。")
        }
        .sheet(item: $templateToEdit) { tmpl in
            EditTemplateSheet(template: tmpl)
                .environment(templateStore)
        }
    }

    private func duplicateAsCustom() {
        templateStore.createTemplate(
            name: "\(template.name)（副本）",
            category: template.category,
            icon: template.icon,
            description: template.description,
            body: template.body
        )
        dismiss()
    }

    /// Converts markdown task list syntax to unicode checkboxes for rendering.
    private static func renderCheckboxes(_ markdown: String) -> String {
        markdown
            .replacingOccurrences(of: "- [x]", with: "- ☑")
            .replacingOccurrences(of: "- [X]", with: "- ☑")
            .replacingOccurrences(of: "- [ ]", with: "- ☐")
    }
}
