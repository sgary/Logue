import SwiftUI

/// Common icons for template creation — curated subset of SF Symbols.
private let templateIconOptions: [(name: String, symbol: String)] = [
    ("文档", "doc.text"),
    ("笔记", "note.text"),
    ("列表", "list.bullet"),
    ("清单", "checklist"),
    ("剪贴板", "clipboard"),
    ("书籍", "book"),
    ("灯泡", "lightbulb"),
    ("星标", "star"),
    ("旗帜", "flag"),
    ("图表", "chart.bar"),
    ("人物", "person"),
    ("日历", "calendar"),
    ("文件夹", "folder"),
    ("齿轮", "gearshape"),
    ("铅笔", "pencil.and.outline"),
    ("代码", "chevron.left.forwardslash.chevron.right"),
]

/// Sheet for saving an existing document as a reusable template.
struct SaveAsTemplateSheet: View {
    let document: WritingDocument
    @Environment(TemplateStore.self) private var templateStore
    @Environment(\.dismiss) private var dismiss

    @State private var templateName: String = ""
    @State private var selectedCategory: TemplateCategory = .personal
    @State private var selectedIcon: String = "doc.text"
    @State private var templateDescription: String = ""

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("保存为模板")
                    .font(.headline)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(AppThemeConstants.paddingLarge)

            Divider()

            // Form
            Form {
                TextField("模板名称", text: $templateName)

                Picker("分类", selection: $selectedCategory) {
                    ForEach(TemplateCategory.allCases) { category in
                        Label(category.displayName, systemImage: category.icon)
                            .tag(category)
                    }
                }

                TextField("描述（可选）", text: $templateDescription)

                LabeledContent("图标") {
                    iconPicker
                }
            }
            .formStyle(.grouped)
            .scrollDisabled(true)

            Divider()

            // Actions
            HStack {
                Button("取消") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button("保存模板") {
                    let name = templateName.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !name.isEmpty else { return }
                    templateStore.saveDocumentAsTemplate(
                        title: name,
                        body: document.body,
                        category: selectedCategory,
                        icon: selectedIcon,
                        description: templateDescription
                    )
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(AppThemeConstants.accent)
                .keyboardShortcut(.defaultAction)
                .disabled(templateName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(AppThemeConstants.paddingLarge)
        }
        .frame(minWidth: 450, maxWidth: 450, minHeight: 380, maxHeight: 440)
        .background(AppThemeConstants.contentBackground)
        .onAppear {
            templateName = document.title
        }
    }

    // MARK: - Icon Picker

    private var iconPicker: some View {
        let columns = Array(repeating: GridItem(.fixed(28), spacing: 6), count: 8)
        return LazyVGrid(columns: columns, spacing: 6) {
            ForEach(templateIconOptions, id: \.symbol) { option in
                Button {
                    selectedIcon = option.symbol
                } label: {
                    Image(systemName: option.symbol)
                        .font(.callout)
                        .frame(width: 28, height: 28)
                        .foregroundStyle(selectedIcon == option.symbol ? .white : .primary)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(selectedIcon == option.symbol
                                    ? AppThemeConstants.accent
                                    : AppThemeConstants.quaternaryFill)
                        )
                }
                .buttonStyle(.plain)
                .help(option.name)
            }
        }
    }
}
