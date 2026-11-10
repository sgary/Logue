import Foundation

// MARK: - Types

/// Somewhere a card can send the reader, for a feature that does not live inside Logue.
struct WhatsNewLink: Equatable, Sendable {
    /// What the button says. A verb, so it is obvious the deck is not the destination.
    let label: String
    let url: URL
}

/// One thing worth telling the user about.
struct WhatsNewFeature: Identifiable, Equatable, Sendable {
    /// Stable slug. Never renamed and never reused — tests and screenshots pin to it.
    let id: String
    /// SF Symbol, shown when the card has no art.
    let symbol: String
    let title: String
    let detail: String
    /// Base names of PNGs in `Logue/Resources`, without the extension. Several play as a
    /// sequence, in the order written. See docs/WHATS_NEW.md.
    let screenshots: [String]
    /// Where to send the reader, for the few features that live outside the app.
    let link: WhatsNewLink?

    init(
        id: String,
        symbol: String,
        title: String,
        detail: String,
        screenshots: [String] = [],
        link: WhatsNewLink? = nil
    ) {
        self.id = id
        self.symbol = symbol
        self.title = title
        self.detail = detail
        self.screenshots = screenshots
        self.link = link
    }

    /// Convenience for the common case of a single still.
    init(
        id: String,
        symbol: String,
        title: String,
        detail: String,
        screenshot: String,
        link: WhatsNewLink? = nil
    ) {
        self.init(
            id: id, symbol: symbol, title: title, detail: detail,
            screenshots: [screenshot], link: link
        )
    }

    var hasArt: Bool {
        !screenshots.isEmpty
    }
}

/// What one release added, in the order it should be read.
struct WhatsNewRelease: Equatable, Sendable {
    let version: AppVersion
    let features: [WhatsNewFeature]
}

// MARK: - Catalog

/// Two lists, because they answer two questions: `tour` is "what is Logue for", `releases`
/// is "what changed". Features are defined once in `Feature` and composed into both, so
/// the copy cannot drift between them. See docs/WHATS_NEW.md.
enum WhatsNewCatalog {
    // MARK: Features

    private enum Feature {
        static let meetings = WhatsNewFeature(
            id: "meeting-transcription",
            symbol: "waveform",
            title: "会议自动转写",
            detail: """
            Logue 同时收听你的麦克风和会议音频，因此适用于任何通话，无需机器人加入房间。\
            转写会在你说话的同时于这台 Mac 上运行，并区分是谁说了什么。
            """,
            screenshot: "whatsnew-transcription"
        )

        static let smartMinutes = WhatsNewFeature(
            id: "smart-minutes",
            symbol: "list.bullet.clipboard",
            title: "会议纪要与待办事项，自动为你写好",
            detail: """
            每段录音都会变成一份摘要，并提炼出关键决策和后续事项。\
            待办事项集中在一个地方，会议中商定的事情不会在会后悄悄消失。
            """,
            screenshot: "whatsnew-smart-minutes"
        )

        static let writingEditor = WhatsNewFeature(
            id: "writing-editor",
            symbol: "square.and.pencil",
            title: "会帮你写作的编辑器",
            detail: """
            改写句子、修正语法、调整语气或核查说法——都不用离开文档。\
            表格、图表和公式可就地渲染，写好的内容还能导出为 PDF 或幻灯片。
            """,
            screenshot: "whatsnew-writing-editor"
        )

        static let askLogue = WhatsNewFeature(
            id: "ask-logue",
            symbol: "sparkles",
            title: "向 Logue 询问你的工作内容",
            detail: """
            这个聊天能真正访问你的会议、文档、日历和提醒事项，并能分多步作答。\
            在做出任何你希望被事先询问的操作前，它都会先征求你的同意。
            """,
            // Where it lives before what it does: the menu bar item is the part nobody
            // finds on their own.
            screenshots: ["whatsnew-asklogue-1-where", "whatsnew-asklogue-2-answer"]
        )

        /// Compile-time constant string — `URL(string:)` will never return nil.
        private static let chromeStore = URL(
            string: "https://chromewebstore.google.com/detail/logue/gaegipceeccdchdffamdphfiegfeenhc"
        )!

        // MARK: Recap, for the release deck only

        /// The back catalogue as two cards instead of four. An upgrading user already owns
        /// the app; re-teaching them transcription card by card buries the thing they opened
        /// the deck for. The tour still introduces these one at a time, because a newcomer
        /// has not seen any of it — the two lists exist to be different.
        static let recapCapture = WhatsNewFeature(
            id: "recap-capture",
            symbol: "waveform",
            title: "你早已熟悉的一切",
            detail: """
            会议会从通话双方自动转写，智能纪要和待办事项根据转写生成，\
            还有一款真正好用的编辑器来处理产出的笔记。
            """,
            screenshot: "whatsnew-transcription"
        )

        static let recapPrivacy = WhatsNewFeature(
            id: "recap-privacy",
            symbol: "lock.shield",
            title: "…而且它从未离开你的 Mac",
            detail: """
            转写、摘要和搜索都在这台机器上、使用你自己的模型运行。\
            空间和 Wiki 链接让笔记始终可查。除非你主动开启会明确提示的功能，\
            否则不会上传任何内容。
            """,
            screenshot: "whatsnew-privacy"
        )

        static let chromeExtension = WhatsNewFeature(
            id: "chrome-extension",
            symbol: "puzzlepiece.extension.fill",
            title: "把浏览器也带进来",
            detail: """
            Logue 扩展把同样的聊天和写作工具带到任意标签页——你可以询问当前页面，\
            答案来自这台 Mac 上的模型，而不是别人的服务器。安装后试一试，\
            再告诉我们体验如何：一条评价能帮助更多人发现它。
            """,
            screenshot: "whatsnew-chrome-extension",
            link: WhatsNewLink(label: UICopy.WhatsNew.chromeExtensionLink, url: chromeStore)
        )

        static let tasks = WhatsNewFeature(
            id: "tasks-and-triage",
            symbol: "checklist",
            title: "任务，以及整理它们的方法",
            detail: """
            Logue 在会议中发现的每个待办事项都会落到真正能处理的地方：\
            一个列表，带截止日期、优先级和标签。输入“明天发送演示文稿 #launch !”，\
            它就会自动归档。
            """
        )

        static let homeSurface = WhatsNewFeature(
            id: "home-agent-surface",
            symbol: "house",
            title: "一个统一的起点",
            detail: """
            首页和 Ask Logue 原本是两个界面做同一件事。现在它们合并为一个统一的落脚点：\
            你的一天、需要继续处理的内容，以及一个能直接进入对话、无需跳转的输入栏。
            """
        )

        static let recordingResilience = WhatsNewFeature(
            id: "recording-resilience",
            symbol: "shield.lefthalf.filled",
            title: "经得起意外的录音",
            detail: """
            通话中拔掉耳机、静音十分钟，甚至直接退出应用——\
            录音都会保留进度，重新打开 Logue 时转写会恢复，\
            而不是在出问题的地方中断。
            """
        )

        static let crossApp = WhatsNewFeature(
            id: "cross-app",
            symbol: "command",
            title: "Logue 在其他应用里也能用",
            detail: """
            在 macOS 的任意位置按 ⌘⌃I 改写选中的内容，\
            或按 ⌥Space 直接提问，无需切换窗口。
            """
        )

        static let spacesAndSearch = WhatsNewFeature(
            id: "spaces-and-search",
            symbol: "square.grid.2x2",
            title: "空间，以及懂你的搜索",
            detail: """
            把工作整理进可嵌套的空间，用 ⌘K 跳到任意位置，\
            并按你的意图而不是原话找到内容。
            """,
            screenshot: "whatsnew-spaces"
        )

        static let privacy = WhatsNewFeature(
            id: "on-device-privacy",
            symbol: "lock.shield.fill",
            title: "任何内容都不会离开你的 Mac",
            detail: """
            模型在你自己的硬件上运行，笔记在磁盘上加密。Logue 还能在你分享内容前\
            标记个人信息。网页搜索和外部 AI 提供商确实存在，但默认关闭，\
            除非你主动开启，否则一直保持关闭。
            """,
            screenshot: "whatsnew-privacy"
        )

        static let externalProviders = WhatsNewFeature(
            id: "external-providers",
            symbol: "cpu",
            title: "使用你自己的模型",
            detail: """
            当你想要比 Mac 能承载的更大的模型时，可以让 Logue 连接 OpenAI、Anthropic、\
            OpenRouter、Ollama 或 LM Studio。你的密钥保存在钥匙串中。
            """
        )

        static let markdownStorage = WhatsNewFeature(
            id: "markdown-storage",
            symbol: "doc.plaintext",
            title: "把文档保存为纯 Markdown",
            detail: """
            把文档以普通 .md 文件保存到 ~/Logue，可用任意编辑器修改、用 git 跟踪，\
            或交给其他工具处理。这个文件夹就是存储位置，而不是副本——\
            编辑、重命名和移动都会双向同步。该功能默认关闭，\
            开启前 Logue 会说明你将放弃哪些加密保护。
            """
        )

        static let wikiLinks = WhatsNewFeature(
            id: "wiki-links",
            symbol: "link",
            title: "用 [[双方括号]] 链接文档",
            detail: """
            输入 [[ 即可链接另一篇文档。链接显示目标的真实名称，重命名后依然有效，\
            每篇文档也会列出所有指向它的链接。
            """,
            screenshot: "whatsnew-wikilinks"
        )

        static let properties = WhatsNewFeature(
            id: "properties-relationships",
            symbol: "tablecells",
            title: "属性与关联",
            detail: """
            为文档添加带类型的字段——文本、数字、日期、选择、复选框——\
            以及指向彼此的具名链接，全部可以从侧边面板编辑。
            """
        )

        static let whatsNew = WhatsNewFeature(
            id: "whats-new",
            symbol: "gift",
            title: "Logue 现在会告诉你有什么变化",
            detail: """
            更新后，Logue 会展示该版本新增的内容——且只显示你尚未看过的版本。\
            你可以随时从“帮助”>“Logue 新功能”重新打开。
            """
        )

        static let savedViews = WhatsNewFeature(
            id: "saved-views-inbox",
            symbol: "tray.full",
            title: "已保存的视图与收件箱",
            detail: """
            把任意筛选条件保存为侧边栏条目，并用键盘驱动的批量操作\
            清空收件箱中未归档的文档。
            """
        )
    }

    // MARK: New installs

    /// What a first install is shown, once the onboarding wizard is done. Hand-picked
    /// rather than derived from `releases`, and it does not change every release — see
    /// docs/WHATS_NEW.md.
    static let tour: [WhatsNewFeature] = [
        Feature.meetings,
        Feature.smartMinutes,
        Feature.writingEditor,
        Feature.privacy,
        Feature.askLogue,
    ]

    // MARK: Upgrades

    /// What each release is worth announcing, ascending by version. A release lists only
    /// what it added; the first card must have art. See docs/WHATS_NEW.md.
    static let releases: [WhatsNewRelease] = [
        // 1.1.0 is a one-off: it introduces What's New, so it carries the whole back
        // catalogue rather than its own additions. Read in two halves — what Logue
        // already does, then what is new, which only means anything against the first.
        //
        // `crossApp` is deliberately not here. "Logue works in every other app too" is
        // true and is not what someone opening a release deck wants to be told: it asks
        // them to learn two shortcuts before they have used the thing in front of them.
        // It stays in the codebase and in the docs; it is the deck it does not earn.
        // `chromeExtension` is the one card that sends the reader somewhere else, which
        // is the point — the extension is not in this build and has to be installed.
        WhatsNewRelease(
            version: AppVersion(major: 1, minor: 1, patch: 0),
            features: [
                // The back catalogue, as two recap cards. It used to be eight, then four;
                // both were the same mistake in different sizes. Someone upgrading opened
                // this to find out what changed, and every card spent on what they already
                // use is one they click past to get there.
                Feature.recapCapture,
                Feature.recapPrivacy,
                // New — what these releases added, one card each. This is the half the deck
                // is for, so it is the half that gets the room.
                Feature.homeSurface,
                Feature.tasks,
                Feature.recordingResilience,
                Feature.chromeExtension,
                Feature.markdownStorage,
                Feature.wikiLinks,
                Feature.properties,
                Feature.savedViews,
                Feature.whatsNew,
            ]
        ),
    ]

    // MARK: - Queries

    /// The newest release this build actually is.
    ///
    /// For the Help menu and Settings, where the user asked to see the notes rather than
    /// being shown them. Bounded by the running version for the same reason the launch
    /// gate is: a development build should not advertise a release that does not exist.
    static func latestRelease(notNewerThan current: AppVersion?) -> WhatsNewRelease? {
        guard let current else { return releases.last }
        return releases.last { $0.version <= current }
    }

    /// Where a feature's bundled art lives, in play order.
    ///
    /// A name that does not resolve is dropped rather than left as a gap, so one missing
    /// file shortens a sequence instead of stalling it on a blank.
    static func screenshotURLs(for feature: WhatsNewFeature, in bundle: Bundle = .main) -> [URL] {
        feature.screenshots.compactMap { bundle.url(forResource: $0, withExtension: "png") }
    }
}
