import SwiftUI

// MARK: - Toolbar

extension DocumentWorkspaceView {
    @ToolbarContentBuilder
    func documentToolbarContent(doc: WritingDocument) -> some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            Button {
                let doc = store.createDocument()
                store.selectedDocumentID = doc.id
            } label: {
                Image(systemName: "square.and.pencil")
                    .accessibilityLabel("新建文档")
            }
            .help("新建文档")
        }

        ToolbarItem(placement: .primaryAction) {
            moreOptionsMenu(doc: doc)
        }

        ToolbarItem(placement: .primaryAction) {
            Button {
                focusState.enter()
            } label: {
                Image(systemName: "rectangle.center.inset.filled")
            }
            .help("进入专注模式（⇧⌘F）")
            .accessibilityLabel("进入专注模式")
        }

        ToolbarItem(placement: .primaryAction) {
            Button {
                withAnimation(.spring(duration: 0.25, bounce: 0.1)) {
                    isSidebarCollapsed.toggle()
                }
            } label: {
                Image(systemName: "sidebar.right")
            }
            .help(isSidebarCollapsed ? "显示工具侧边栏" : "隐藏工具侧边栏")
        }
    }

    /// Minimal toolbar shown in Focus Mode — only an exit button.
    @ToolbarContentBuilder
    var focusModeToolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                focusState.exit()
            } label: {
                Label("退出专注", systemImage: "xmark.circle")
            }
            .help("退出专注模式（Esc）")
            .accessibilityLabel("退出专注模式")
        }
    }

    @ViewBuilder
    func moreMenuItems(doc: WritingDocument) -> some View {
        Button("撤销") {
            NSApp.sendAction(Selector(("undo:")), to: nil, from: nil)
        }
        Button("重做") {
            NSApp.sendAction(Selector(("redo:")), to: nil, from: nil)
        }
        Toggle("字数统计", isOn: $showWordCount)
        Button {
            var updated = doc
            updated.widthMode = doc.widthMode.toggled
            store.updateDocument(updated)
        } label: {
            Label(doc.widthMode.toggled.label, systemImage: doc.widthMode.toggled.symbolName)
        }
        Divider()
        Button {
            titleGenerationTask?.cancel()
            titleGenerationTask = Task {
                await store.regenerateAITitle(for: doc.id)
            }
        } label: {
            Label("生成标题", systemImage: "sparkles")
        }
        .disabled(doc.body.trimmingCharacters(in: .whitespacesAndNewlines).count < 20 || LLMEngineStatus.shared.isBusy)
        Button {
            renameText = doc.title
            showRenameAlert = true
        } label: {
            Label("重命名", systemImage: "pencil")
        }
        Button {
            showIconPicker = true
        } label: {
            Label(doc.icon == nil ? "添加图标" : "更改图标", systemImage: "face.smiling")
        }
        Button {
            showTagPopover = true
        } label: {
            Label("添加标签", systemImage: "tag")
        }
        Button {
            showSaveAsTemplate = true
        } label: {
            Label("存为模板", systemImage: "doc.on.doc")
        }
        exportMenu(doc: doc)
        Divider()
        Button(role: .destructive) {
            store.deleteDocument(id: doc.id)
        } label: {
            Label("删除文档", systemImage: "trash")
        }
    }

    /// Split out of `moreMenuItems` only to keep that function within the body-length limit.
    private func exportMenu(doc: WritingDocument) -> some View {
        Menu("导出") {
            Button {
                PDFExportService.export(document: doc)
            } label: {
                Label("导出为 PDF", systemImage: "arrow.down.doc")
            }
            Button {
                exportAsMarkdown(doc: doc)
            } label: {
                Label("导出为 Markdown", systemImage: "doc.plaintext")
            }
        }
    }

    func moreOptionsMenu(doc: WritingDocument) -> some View {
        Menu {
            moreMenuItems(doc: doc)
        } label: {
            Label("更多", systemImage: "ellipsis.circle")
        }
        .help("更多选项")
        .popover(isPresented: $showTagPopover, arrowEdge: .bottom) {
            tagPopoverContent(doc: doc)
        }
        .popover(isPresented: $showIconPicker, arrowEdge: .bottom) {
            DocumentIconPicker(currentIcon: doc.icon) { icon in
                var updated = doc
                // Already sanitised by the picker; `icon` is never raw input here.
                updated.icon = icon
                store.updateDocument(updated)
                showIconPicker = false
            }
        }
        .alert("重命名文档", isPresented: $showRenameAlert) {
            TextField("标题", text: $renameText)
            Button("重命名") {
                store.renameDocument(id: doc.id, newTitle: renameText)
            }
            Button("取消", role: .cancel) {}
        }
    }
}
