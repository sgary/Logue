import Foundation

/// Centralized consumer-tone microcopy for the chat-first surfaces.
///
/// This is a Swift namespace rather than a `.strings` bundle for now —
/// it gives compile-time safety on string IDs, easy refactoring, and a
/// single grep target ("`UICopy.`") to audit tone. We can move to
/// `Localizable.strings` when we ship a second language.
///
/// **Tone rules** (enforce on PR review):
/// - Warm, verb-first, never developer-y.
/// - 1–2 word buttons.
/// - Confirmations use the chosen verb ("Delete?" not "Are you sure?").
/// - Errors include a recovery action.
/// - Status varies with inferred work, not a constant "Thinking…".
enum UICopy {
    // MARK: - Empty states

    enum Empty {
        // The chat hero copy that used to live here went with `AgentChatEmptyState`. Home's
        // landing greets by time of day and derives its chips from the workspace, so there
        // is no fixed hero string left to name.

        static let dailyTipPrefix = "试试"
    }

    // MARK: - Input bar

    enum Input {
        static let placeholder = "问点什么…"
        static let attach = "附件"
        static let voice = "语音输入"
        static let send = "发送"
        static let stop = "停止"
        /// Chip titles. Shared because the island and the main window render the same
        /// `ModeChip` for the same mode, and were spelling it two ways.
        static let webSearch = "搜索"
        static let deepResearch = "深度研究"
        /// The `+` menu's items. One definition, because both composers mount the same
        /// menu and two copies of a label is how the surfaces start naming one action
        /// two different things.
        static let addFiles = "添加照片和文件"
        static let searchTheWeb = "联网搜索"
        static let deepResearchMenu = "深度研究"
        static let toolSettings = "工具设置…"
        static let composerMenuHelp = "附件、搜索、深度研究…"
        static let composerMenuLabel = "更多操作"
        static let reasoning = "推理"
        static let footerPrivacy = "本地模型 · 可离线使用 · 数据不会离开这台 Mac"
        static let charLimitNear = "接近上下文上限"
        static let charLimitOver = "已超出上下文上限，较早的内容将被裁剪"
    }

    // MARK: - Status (vary with inferred work — never static "Thinking…")

    enum Status {
        static let thinking = "思考中…"
        static let reading = "读取中…"
        static let searching = "正在联网搜索…"
        static let drafting = "正在起草回复…"
        static let analyzing = "分析中…"
        static let researching = "研究中…"
        static let summarizing = "总结中…"
        static let executing = "正在运行工具…"
        /// Shown when a send is refused because another conversation holds the engine.
        static let busyElsewhere = "Logue 正在处理另一个对话"

        /// Pick a status string based on what the agent is currently doing.
        /// Falls back to "Thinking…" when no signal is available.
        static func describe(toolName: String?) -> String {
            guard let toolName else { return thinking }
            let lower = toolName.lowercased()
            if lower.contains("search") {
                return searching
            }
            if lower.contains("read") || lower.contains("get_") {
                return reading
            }
            if lower.contains("summar") {
                return summarizing
            }
            if lower.contains("research") {
                return researching
            }
            if lower.contains("analy") || lower.contains("detect") {
                return analyzing
            }
            if lower.contains("draft") || lower.contains("compose") || lower.contains("write") {
                return drafting
            }
            return executing
        }
    }

    // MARK: - Hover toolbar actions

    enum Action {
        static let copy = "复制"
        static let copied = "已复制"
        static let regenerate = "重新生成"
        static let edit = "编辑"
        static let editAndResend = "编辑并重新发送"
        static let branch = "从此处分支"
        static let readAloud = "朗读"
        static let stopReading = "停止"
        static let thumbsUp = "标记为有帮助"
        static let thumbsDown = "标记为无帮助"
        static let exportConversation = "导出对话"
        static let pin = "置顶"
        static let unpin = "取消置顶"
        static let archive = "归档"
        static let restore = "恢复"
        static let rename = "重命名"
        static let delete = "删除"
    }

    // MARK: - Confirmations

    enum Confirm {
        static let deleteConversation = "删除这个对话？"
        static let deleteConversationDetail = "它会被移到“已归档”保留 30 天，然后永久删除。"
        static let archiveConversation = "归档这个对话？"
        static let eraseAllData = "抹除这台 Mac 上的所有数据？"
        static let eraseAllDataDetail = "长按以确认。这将删除所有对话、附件和已索引的文档。"
    }

    // MARK: - Toasts

    enum Toast {
        static let copied = "已复制"
        static let saved = "已保存"
        static let exported = "已导出到“下载”文件夹"
        static let pinned = "已置顶"
        static let unpinned = "已取消置顶"
        static let archived = "已归档"
        static let restored = "已恢复"
        static let reminderCreated = "已创建提醒事项"
        static let eventCreated = "已添加到日历"
        static let modelSwitched = "已切换模型"
    }

    // MARK: - Errors (always include a recovery action)

    enum Error {
        static let modelUnreachable = "无法连接到模型，要重试吗？"
        static let networkOffline = "你处于离线状态，将跳过联网工具。"
        static let attachmentTooLarge = "文件太大，请选择小于 25 MB 的文件。"
        static let attachmentUnsupported = "Logue 暂时无法读取这种文件类型。"
        static let permissionDenied = "需要权限，请打开设置授予访问权限。"
        static let toolFailed = "工具未能运行，请换个说法或跳过该操作。"
        static let inferenceBusy = "模型正在完成上一个请求，请稍后再试。"
    }

    // MARK: - Trust signals

    enum Trust {
        static let local = "本地"
        static let onDevice = "设备端"
        static let networkUsed = "使用了网络"
        static let networkUsedDetail = "此回复使用了联网工具，其他内容始终保留在这台 Mac 上。"
        static let bannerFull = "本地模型 · 可离线使用 · 数据不会离开这台 Mac"
    }

    // MARK: - Onboarding (3-card flow)

    enum Onboarding {
        static let card1Title = "一切都留在你的 Mac 上"
        static let card1Subtitle = "无需账号、不上传云端、不记录日志。Logue 完全在你的设备上运行。"
        static let card1Continue = "好的"

        static let card2Title = "选择模型"
        static let card2Subtitle = "较小的模型速度更快，较大的模型推理能力更强。你随时可以切换。"
        static let card2Skip = "稍后再设置"

        static let card3Title = "随处一键唤起"
        static let card3Subtitle = "在任意应用中按 ⌥Space 即可询问 Logue。你可以在设置中修改。"
        static let card3Continue = "开始吧"
    }

    // MARK: - What's New / feature tour

    enum WhatsNew {
        /// Fresh install, after the onboarding wizard.
        static let discoverTitle = "认识 Logue"
        /// One or more releases the user has not seen yet.
        static let updatedTitle = "新功能"

        static let back = "返回"
        static let next = "继续"
        static let skip = "跳过"
        /// Leaving release notes part-read. Every deck needs a way out that is not
        /// clicking through all of it.
        static let close = "关闭"
        /// Last card of the first-run tour.
        static let finishTour = "开始使用 Logue"
        /// Last card of a release's notes.
        static let finishNotes = "完成"

        /// Badge on a notes card, so a user catching up across releases can tell
        /// which version brought what.
        static func versionBadge(_ version: String) -> String {
            "\(version) 新功能"
        }

        /// Help menu. Says where it goes, because it leaves the app.
        static let chromeExtensionMenuItem = "获取 Chrome 扩展"
        /// The card's button. A verb, so the deck is plainly not the destination.
        static let chromeExtensionLink = "获取 Chrome 扩展"

        /// Help menu. Named for the app because it sits among app-wide items.
        static let menuItem = "Logue 新功能"
        /// Settings → General, beside "Show welcome tour".
        static let settingsButton = "新功能"
    }
}
