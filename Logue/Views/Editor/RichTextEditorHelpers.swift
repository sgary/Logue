import AppKit
import SwiftUI

// MARK: - Menu Icon Helper

private extension NSImage {
    /// Creates a symbol image sized for menus using the shared `menuIconPointSize` token.
    static func menuIcon(systemName: String, description: String) -> NSImage? {
        NSImage(systemSymbolName: systemName, accessibilityDescription: description)?
            .withSymbolConfiguration(.init(pointSize: AppThemeConstants.menuIconPointSize, weight: .regular))
    }
}

// MARK: - BlockType

/// Block types available in the + (add block) and "Turn into" menus.
enum BlockType: String, CaseIterable {
    case text
    case heading1, heading2, heading3
    case bulletList, numberedList, todoList
    case quote, divider, codeBlock, table
    case mermaid, math, callout

    var displayName: String {
        switch self {
        case .mermaid: "图表"
        case .math: "公式"
        case .callout: "标注"
        case .text: "正文"
        case .heading1: "标题 1"
        case .heading2: "标题 2"
        case .heading3: "标题 3"
        case .bulletList: "项目符号列表"
        case .numberedList: "编号列表"
        case .todoList: "待办列表"
        case .quote: "引用"
        case .divider: "分隔线"
        case .codeBlock: "代码块"
        case .table: "表格"
        }
    }

    var iconName: String {
        switch self {
        case .mermaid: "flowchart"
        case .math: "function"
        case .callout: "exclamationmark.bubble"
        case .text: "text.alignleft"
        case .heading1: "textformat.size.larger"
        case .heading2: "textformat.size"
        case .heading3: "textformat.size.smaller"
        case .bulletList: "list.bullet"
        case .numberedList: "list.number"
        case .todoList: "checklist"
        case .quote: "text.quote"
        case .divider: "minus"
        case .codeBlock: "chevron.left.forwardslash.chevron.right"
        case .table: "tablecells"
        }
    }

    var description: String {
        switch self {
        case .mermaid: "以 Markdown 保存的 Mermaid 图表"
        case .math: "LaTeX 公式块"
        case .callout: "提示、建议或警告块"
        case .text: "普通文本段落"
        case .heading1: "大号章节标题"
        case .heading2: "中号章节标题"
        case .heading3: "小号章节标题"
        case .bulletList: "无序列表项"
        case .numberedList: "有序列表项"
        case .todoList: "复选框条目"
        case .quote: "高亮引用块"
        case .divider: "水平分隔线"
        case .codeBlock: "语法高亮代码"
        case .table: "由行和列组成的表格"
        }
    }

    enum Category: String, CaseIterable {
        case text = "Text"
        case lists = "Lists"
        case advanced = "Advanced"

        var displayName: String {
            switch self {
            case .text: "文本"
            case .lists: "列表"
            case .advanced: "高级"
            }
        }
    }

    var category: Category {
        switch self {
        case .text, .heading1, .heading2, .heading3: .text
        case .bulletList, .numberedList, .todoList: .lists
        case .quote, .divider, .codeBlock, .table, .mermaid, .math, .callout: .advanced
        }
    }

    /// Builds the `Block` this menu entry inserts, carrying any existing text into
    /// the new block's source so converting a paragraph does not discard it.
    func makeBlock(id: BlockID, text: String) -> Block {
        switch self {
        case .mermaid:
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            // Start from a usable template rather than an empty diagram.
            return trimmed.isEmpty ? .mermaid(id: id, source: Self.mermaidTemplate)
                : .mermaid(id: id, source: trimmed)
        case .math:
            return .math(id: id, latex: text.trimmingCharacters(in: .whitespacesAndNewlines))
        case .heading1:
            return .heading(id: id, level: 1, text: text)
        case .heading2:
            return .heading(id: id, level: 2, text: text)
        case .heading3:
            return .heading(id: id, level: 3, text: text)
        case .bulletList:
            return .bulletList(id: id, items: [BlockListItem(text: text)])
        case .numberedList:
            return .numberedList(id: id, items: [BlockListItem(text: text)])
        case .todoList:
            return .checkboxList(id: id, items: [CheckboxItem(text: text)])
        case .quote:
            return .blockQuote(id: id, text: text)
        case .callout:
            // Any existing text becomes the body, not the title: converting a paragraph should
            // keep what was written where it reads the same, and the title is decoration.
            return .callout(id: id, kind: .note, title: "", body: text)
        case .codeBlock:
            // Starts at the language last picked from a code block's menu, so a document
            // full of snippets in one language does not need choosing block by block.
            return .codeBlock(id: id, language: CodeBlockLanguageMemory.suggestedLanguage, code: text)
        case .divider:
            return .divider(id: id)
        case .table:
            return .emptyTable()
        case .text:
            return .paragraph(id: id, text: text)
        }
    }

    private static let mermaidTemplate = "flowchart LR\n  A --> B"

    /// Block types grouped by category, preserving order.
    static var groupedByCategory: [(category: Category, types: [BlockType])] {
        Category.allCases.compactMap { cat in
            let types = allCases.filter { $0.category == cat }
            return types.isEmpty ? nil : (cat, types)
        }
    }

    var markdownPrefix: String {
        switch self {
        case .text: ""
        case .heading1: "# "
        case .heading2: "## "
        case .heading3: "### "
        case .bulletList: "- "
        case .numberedList: "1. "
        case .todoList: "- [ ] "
        case .quote: "> "
        case .callout: "> [!NOTE]\n> "
        case .divider: "---"
        case .codeBlock: "```"
        case .table: ""
        case .mermaid: "```mermaid"
        case .math: "$$"
        }
    }

    /// Block types that can be used in "Turn into" (excludes divider/codeBlock/table).
    static var turnIntoTypes: [BlockType] {
        [.text, .heading1, .heading2, .heading3, .bulletList, .numberedList, .todoList, .quote]
    }

    /// Creates a new empty block of this type.
    func makeEmptyBlock() -> Block {
        makeBlock(id: UUID(), text: "")
    }
}

// MARK: - Add Block Menu (+)

extension WritingNSTextView {
    @objc
    func showAddBlockMenu() {
        let menu = NSMenu()
        menu.autoenablesItems = false

        let groups: [[BlockType]] = [
            [.text, .heading1, .heading2, .heading3],
            [.bulletList, .numberedList, .todoList],
            [.quote, .divider, .codeBlock, .table],
        ]

        for (groupIndex, group) in groups.enumerated() {
            if groupIndex > 0 {
                menu.addItem(.separator())
            }
            for blockType in group {
                let item = NSMenuItem(
                    title: blockType.displayName,
                    action: #selector(handleAddBlock(_:)),
                    keyEquivalent: ""
                )
                item.target = self
                item.isEnabled = true
                item.representedObject = blockType.rawValue
                item.image = .menuIcon(systemName: blockType.iconName, description: blockType.displayName)
                menu.addItem(item)
            }
        }

        menu.popUp(positioning: menu.items.first, at: addBlockButton.frame.origin, in: self)
    }

    @objc
    private func handleAddBlock(_ sender: NSMenuItem) {
        guard let rawValue = sender.representedObject as? String,
              let blockType = BlockType(rawValue: rawValue)
        else { return }
        insertBlock(blockType, at: hoveredCharIndex)
    }

    /// Inserts a new block below the line at `charIndex`.
    func insertBlock(_ blockType: BlockType, at charIndex: Int) {
        let nsString = string as NSString
        let lr = safeLineRange(at: charIndex)
        let insertAt = min(NSMaxRange(lr), nsString.length)
        let needsNewline = insertAt > 0 && !nsString.substring(with: NSRange(location: insertAt - 1, length: 1)).hasSuffix("\n")

        switch blockType {
        case .divider:
            let text = (needsNewline ? "\n" : "") + "---\n"
            replaceRange(NSRange(location: insertAt, length: 0), with: text)
            let caretPos = insertAt + text.utf16.count
            setSelectedRange(NSRange(location: caretPos, length: 0))

        case .codeBlock:
            let text = (needsNewline ? "\n" : "") + "```\n\n```\n"
            replaceRange(NSRange(location: insertAt, length: 0), with: text)
            // Place cursor inside the code block (after first ```)
            let offset = (needsNewline ? 1 : 0) + 4 // "```\n" = 4
            setSelectedRange(NSRange(location: insertAt + offset, length: 0))

        case .table:
            insertTableBlock(at: charIndex)

        default:
            let prefix = blockType.markdownPrefix
            let text = (needsNewline ? "\n" : "") + prefix
            replaceRange(NSRange(location: insertAt, length: 0), with: text)
            let caretPos = insertAt + text.utf16.count
            setSelectedRange(NSRange(location: caretPos, length: 0))
        }
    }
}

// MARK: - Block Options Menu (⋮⋮)

extension WritingNSTextView {
    @objc
    func showBlockOptionsMenu() {
        let menu = NSMenu()
        menu.autoenablesItems = false

        // Turn into submenu
        let turnIntoItem = NSMenuItem(title: "转换为", action: nil, keyEquivalent: "")
        turnIntoItem.image = .menuIcon(systemName: "arrow.triangle.swap", description: "转换为")
        let turnIntoMenu = NSMenu()
        for blockType in BlockType.turnIntoTypes {
            let item = NSMenuItem(
                title: blockType.displayName,
                action: #selector(handleTurnInto(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.isEnabled = true
            item.representedObject = blockType.rawValue
            item.image = NSImage(systemSymbolName: blockType.iconName, accessibilityDescription: blockType.displayName)?
                .withSymbolConfiguration(.init(pointSize: 13, weight: .regular))
            turnIntoMenu.addItem(item)
        }
        turnIntoItem.submenu = turnIntoMenu
        menu.addItem(turnIntoItem)

        menu.addItem(.separator())

        // Move
        let upItem = NSMenuItem(title: "上移", action: #selector(moveLineUp), keyEquivalent: "")
        upItem.target = self; upItem.isEnabled = true
        upItem.image = .menuIcon(systemName: "arrow.up", description: "上移")
        menu.addItem(upItem)

        let downItem = NSMenuItem(title: "下移", action: #selector(moveLineDown), keyEquivalent: "")
        downItem.target = self; downItem.isEnabled = true
        downItem.image = .menuIcon(systemName: "arrow.down", description: "下移")
        menu.addItem(downItem)

        menu.addItem(.separator())

        // Duplicate
        let dupItem = NSMenuItem(title: "创建副本", action: #selector(duplicateLine), keyEquivalent: "")
        dupItem.target = self; dupItem.isEnabled = true
        dupItem.image = .menuIcon(systemName: "plus.square.on.square", description: "创建副本")
        menu.addItem(dupItem)

        // Copy
        let copyItem = NSMenuItem(title: "复制", action: #selector(copyLine), keyEquivalent: "")
        copyItem.target = self; copyItem.isEnabled = true
        copyItem.image = .menuIcon(systemName: "doc.on.doc", description: "复制")
        menu.addItem(copyItem)

        // Delete
        let delItem = NSMenuItem(title: "删除", action: #selector(deleteLine), keyEquivalent: "")
        delItem.target = self; delItem.isEnabled = true
        delItem.image = .menuIcon(systemName: "trash", description: "删除")
        menu.addItem(delItem)

        menu.popUp(positioning: menu.items.first, at: blockOptionsButton.frame.origin, in: self)
    }

    @objc
    private func handleTurnInto(_ sender: NSMenuItem) {
        guard let rawValue = sender.representedObject as? String,
              let blockType = BlockType(rawValue: rawValue)
        else { return }
        setMarkdownLinePrefix(blockType.markdownPrefix, at: hoveredCharIndex)
    }
}

// MARK: - Line Operations

extension WritingNSTextView {
    func safeLineRange(at charIndex: Int) -> NSRange {
        let nsString = string as NSString
        guard nsString.length > 0 else { return NSRange(location: 0, length: 0) }
        let safe = min(max(0, charIndex), nsString.length - 1)
        return nsString.lineRange(for: NSRange(location: safe, length: 0))
    }

    func replaceRange(_ range: NSRange, with replacement: String) {
        guard shouldChangeText(in: range, replacementString: replacement) else { return }
        replaceCharacters(in: range, with: replacement)
        didChangeText()
    }

    @objc
    func moveLineUp() {
        let nsString = string as NSString
        let lr = safeLineRange(at: hoveredCharIndex)
        guard lr.location > 0 else { return }
        let prevLR = nsString.lineRange(for: NSRange(location: lr.location - 1, length: 0))
        let lineText = nsString.substring(with: lr)
        let prevText = nsString.substring(with: prevLR)
        let swapRange = NSRange(location: prevLR.location, length: prevLR.length + lr.length)
        replaceRange(swapRange, with: lineText + prevText)
        setSelectedRange(NSRange(location: prevLR.location, length: 0))
    }

    @objc
    func moveLineDown() {
        let nsString = string as NSString
        let lr = safeLineRange(at: hoveredCharIndex)
        let nextStart = NSMaxRange(lr)
        guard nextStart < nsString.length else { return }
        let nextLR = nsString.lineRange(for: NSRange(location: nextStart, length: 0))
        let lineText = nsString.substring(with: lr)
        let nextText = nsString.substring(with: nextLR)
        let swapRange = NSRange(location: lr.location, length: lr.length + nextLR.length)
        replaceRange(swapRange, with: nextText + lineText)
        setSelectedRange(NSRange(location: lr.location + nextLR.length, length: 0))
    }

    @objc
    func insertLineAbove() {
        let lr = safeLineRange(at: hoveredCharIndex)
        replaceRange(NSRange(location: lr.location, length: 0), with: "\n")
        setSelectedRange(NSRange(location: lr.location, length: 0))
    }

    @objc
    func insertLineBelow() {
        let nsString = string as NSString
        let lr = safeLineRange(at: hoveredCharIndex)
        let insertAt = min(NSMaxRange(lr), nsString.length)
        replaceRange(NSRange(location: insertAt, length: 0), with: "\n")
        setSelectedRange(NSRange(location: insertAt + 1, length: 0))
    }

    @objc
    func duplicateLine() {
        let nsString = string as NSString
        let lr = safeLineRange(at: hoveredCharIndex)
        let lineText = nsString.substring(with: lr)
        let insertAt = min(NSMaxRange(lr), nsString.length)
        let toInsert = lineText.hasSuffix("\n") ? lineText : "\n" + lineText
        replaceRange(NSRange(location: insertAt, length: 0), with: toInsert)
    }

    @objc
    func deleteLine() {
        replaceRange(safeLineRange(at: hoveredCharIndex), with: "")
    }

    @objc
    func copyLine() {
        let nsString = string as NSString
        let lr = safeLineRange(at: hoveredCharIndex)
        let lineText = nsString.substring(with: lr)
        let trimmed = lineText.hasSuffix("\n") ? String(lineText.dropLast()) : lineText
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(trimmed, forType: .string)
    }
}

// MARK: - Markdown Line Prefix

extension WritingNSTextView {
    /// All known markdown line prefixes, ordered longest-first for greedy matching.
    private static let knownPrefixes = [
        "### ", "## ", "# ",
        "- [x] ", "- [ ] ",
        "- ", "* ", "+ ",
        "> ",
    ]

    /// Regex to match numbered list prefixes like `1. `, `12) `.
    private static let numberedListRegex = try? NSRegularExpression(pattern: #"^\d+[.)]\s+"#)

    /// Replaces any existing markdown prefix on the line with the new one.
    /// Pass `""` to remove the prefix (Normal paragraph).
    func setMarkdownLinePrefix(_ newPrefix: String, at charIndex: Int) {
        let lr = safeLineRange(at: charIndex)
        guard lr.length > 0 else { return }
        let nsString = string as NSString
        let lineText = nsString.substring(with: lr)

        // Preserve leading whitespace (nesting indentation)
        let leadingSpaces = String(lineText.prefix(while: { $0 == " " }))
        var strippedLine = String(lineText.dropFirst(leadingSpaces.count))

        // Strip known static prefixes
        if let matched = Self.knownPrefixes.first(where: { strippedLine.hasPrefix($0) }) {
            strippedLine = String(strippedLine.dropFirst(matched.count))
        } else {
            // Strip numbered list prefix (e.g., "1. ", "12) ")
            let lineNS = strippedLine as NSString
            let lineRange = NSRange(location: 0, length: lineNS.length)
            if let match = Self.numberedListRegex?.firstMatch(in: strippedLine, range: lineRange) {
                strippedLine = String(strippedLine.dropFirst(match.range.length))
            }
        }

        let newLine = leadingSpaces + newPrefix + strippedLine
        guard newLine != lineText else { return }
        replaceRange(lr, with: newLine)

        // Place caret after the new prefix (including leading spaces)
        let caretPos = lr.location + leadingSpaces.utf16.count + newPrefix.utf16.count
        setSelectedRange(NSRange(location: caretPos, length: 0))
    }
}

// MARK: - SelectionToolbarView

struct SelectionToolbarView: View {
    let formattingState: FormattingState
    let onAction: (FormattingAction) -> Void

    var body: some View {
        HStack(spacing: 0) {
            FormatButton(symbol: "bold", tooltip: "粗体", isActive: formattingState.isBold, action: { onAction(.bold) })
            FormatButton(symbol: "italic", tooltip: "斜体", isActive: formattingState.isItalic, action: { onAction(.italic) })
            FormatButton(symbol: "underline", tooltip: "下划线", isActive: formattingState.isUnderlined, action: { onAction(.underline) })
            toolbarDivider
            FormatButton(
                symbol: "strikethrough",
                tooltip: "删除线",
                isActive: formattingState.isStrikethrough,
                action: { onAction(.strikethrough) }
            )
            FormatButton(symbol: "chevron.left.forwardslash.chevron.right", tooltip: "行内代码", action: { onAction(.inlineCode) })
            toolbarDivider
            FormatButton(symbol: "link", tooltip: "链接", action: { onAction(.link) })
            FormatButton(symbol: "doc.on.doc", tooltip: "复制", action: { onAction(.copySelection) })
            toolbarDivider
            rewriteButton
            askAIButton
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 6)
        .fixedSize()
        .background(
            .regularMaterial,
            in: RoundedRectangle(cornerRadius: AppThemeConstants.radiusLarge, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppThemeConstants.radiusLarge, style: .continuous)
                .strokeBorder(.separator, lineWidth: 0.5)
        )
        .shadow(
            color: .black.opacity(AppThemeConstants.panelShadowOpacity),
            radius: AppThemeConstants.panelShadowRadius,
            x: 0,
            y: AppThemeConstants.panelShadowY
        )
        .padding(10)
    }

    private var toolbarDivider: some View {
        Divider()
            .frame(height: 18)
            .padding(.horizontal, 3)
    }

    private var askAIButton: some View {
        Button { onAction(.askAI) } label: {
            HStack(spacing: 4) {
                Image(systemName: "sparkles")
                    .font(.system(size: 11, weight: .semibold))
                Text("询问 AI")
                    .font(.system(size: 12, weight: .semibold))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                AppThemeConstants.brandPrimary.opacity(AppThemeConstants.activeOpacity),
                in: RoundedRectangle(cornerRadius: AppThemeConstants.radiusSmall, style: .continuous)
            )
            .foregroundStyle(AppThemeConstants.brandPrimary)
        }
        .buttonStyle(.plain)
        .padding(.leading, 2)
        .help("就所选内容询问 AI")
    }

    /// Triggers in-place rewrite of the selection with a user-provided instruction.
    /// Distinct from "Ask AI" which opens a side-panel chat — Rewrite edits the
    /// selected text directly with an accept/reject diff, matching the Granola-style
    /// inline editing pattern.
    private var rewriteButton: some View {
        Button { onAction(.rewrite) } label: {
            HStack(spacing: 4) {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 11, weight: .semibold))
                Text("重写")
                    .font(.system(size: 12, weight: .semibold))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                AppThemeConstants.accent.opacity(AppThemeConstants.activeOpacity),
                in: RoundedRectangle(cornerRadius: AppThemeConstants.radiusSmall, style: .continuous)
            )
            .foregroundStyle(AppThemeConstants.accent)
        }
        .buttonStyle(.plain)
        .padding(.trailing, 2)
        .help("用 AI 重写所选内容（⌘⇧E）")
    }
}

// MARK: - FormatButton

struct FormatButton: View {
    let symbol: String
    let tooltip: String
    var isActive: Bool = false
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .medium))
                .frame(width: 30, height: 30)
                .foregroundStyle(isActive ? AppThemeConstants.brandPrimary : Color.primary)
                .background(
                    RoundedRectangle(cornerRadius: AppThemeConstants.radiusSmall, style: .continuous)
                        .fill(isActive ? AppThemeConstants.brandPrimary
                            .opacity(0.18) : (isHovered ? Color.primary.opacity(AppThemeConstants.opacityLight) : Color.clear))
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
        .help(tooltip)
    }
}
