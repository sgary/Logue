import Foundation

// MARK: - Writing Mode

/// Represents the type of writing operation for cross-app and in-app writing features.
enum WritingMode: String, CaseIterable, Identifiable {
    // Core
    case improve
    case rewrite
    case moreFormal = "more_formal"
    case shorter
    case expand
    case grammar

    // Content
    case article
    case brainstorm
    case conclusion
    case formalLetter = "formal_letter"

    // Text Editing
    case fullParagraph = "full_paragraph"
    case outline
    case paragraphRewriter = "paragraph_rewriter"
    case rewording
    case sentenceRewriter = "sentence_rewriter"
    case summarizing
    case title
    case sentences

    // Job Search
    case coverLetter = "cover_letter"
    case linkedinHeadline = "linkedin_headline"
    case resumeObjective = "resume_objective"
    case resumeSkills = "resume_skills"

    // Work
    case businessPlan = "business_plan"
    case businessReport = "business_report"
    case email
    case executiveSummary = "executive_summary"
    case jobDescription = "job_description"
    case resignationLetter = "resignation_letter"
    case valueProposition = "value_proposition"

    // Marketing
    case blogPost = "blog_post"
    case blogPostTitle = "blog_post_title"
    case businessName = "business_name"
    case headline
    case instagramCaption = "instagram_caption"
    case linkedinPost = "linkedin_post"
    case metaDescription = "meta_description"
    case metaTitle = "meta_title"
    case productDescription = "product_description"
    case slogan

    // Students
    case abstract
    case essayTitle = "essay_title"
    case personalStatement = "personal_statement"
    case poem
    case thesisStatement = "thesis_statement"
    case topicSentences = "topic_sentences"

    var id: String {
        rawValue
    }

    /// Core quick-action modes shown as chips in the floating panel.
    static var quickActions: [WritingMode] {
        [.improve, .rewrite, .moreFormal, .shorter, .expand, .grammar]
    }

    /// Featured modes shown as cards in the floating panel.
    static var featured: [WritingMode] {
        [.article, .brainstorm, .conclusion, .formalLetter]
    }

    var displayName: String {
        switch self {
        case .improve: "改进"
        case .rewrite: "重写"
        case .moreFormal: "更正式"
        case .shorter: "精简"
        case .expand: "扩写"
        case .grammar: "语法"
        case .article: "文章草稿"
        case .brainstorm: "头脑风暴"
        case .conclusion: "结尾"
        case .formalLetter: "正式信函"
        case .fullParagraph: "整段撰写"
        case .outline: "大纲"
        case .paragraphRewriter: "段落改写"
        case .rewording: "换词表达"
        case .sentenceRewriter: "句子改写"
        case .summarizing: "摘要"
        case .title: "标题生成"
        case .sentences: "句子生成"
        case .coverLetter: "求职信"
        case .linkedinHeadline: "LinkedIn 标题"
        case .resumeObjective: "简历目标"
        case .resumeSkills: "简历技能"
        case .businessPlan: "商业计划"
        case .businessReport: "商业报告"
        case .email: "邮件"
        case .executiveSummary: "执行摘要"
        case .jobDescription: "职位描述"
        case .resignationLetter: "辞职信"
        case .valueProposition: "价值主张"
        case .blogPost: "博客文章"
        case .blogPostTitle: "博客标题"
        case .businessName: "品牌命名"
        case .headline: "吸睛标题"
        case .instagramCaption: "Instagram 文案"
        case .linkedinPost: "LinkedIn 帖子"
        case .metaDescription: "元描述"
        case .metaTitle: "元标题"
        case .productDescription: "产品描述"
        case .slogan: "标语"
        case .abstract: "论文摘要"
        case .essayTitle: "论文标题"
        case .personalStatement: "个人陈述"
        case .poem: "诗歌"
        case .thesisStatement: "论点陈述"
        case .topicSentences: "主题句"
        }
    }

    var description: String {
        switch self {
        case .improve: "Enhance clarity and readability"
        case .rewrite: "Complete rewrite with fresh perspective"
        case .moreFormal: "Adjust tone to be more professional"
        case .shorter: "Condense while keeping key points"
        case .expand: "Add detail and depth"
        case .grammar: "Fix grammar and punctuation"
        case .article: "Generate a structured article draft"
        case .brainstorm: "Generate ideas and suggestions"
        case .conclusion: "Create an impactful closing"
        case .formalLetter: "Draft a professional letter"
        case .fullParagraph: "Write entire paragraphs from scratch"
        case .outline: "Structure your ideas into an outline"
        case .paragraphRewriter: "Rephrase entire paragraphs"
        case .rewording: "Reword text quickly"
        case .sentenceRewriter: "Rephrase individual sentences"
        case .summarizing: "Turn complex ideas into concise summaries"
        case .title: "Craft compelling titles"
        case .sentences: "Create well-structured sentences"
        case .coverLetter: "Personalized cover letters"
        case .linkedinHeadline: "Standout LinkedIn headlines"
        case .resumeObjective: "Compelling resume objective"
        case .resumeSkills: "Compelling list of skills"
        case .businessPlan: "Goal-oriented business plan"
        case .businessReport: "Formatted business report"
        case .email: "Clear and personable emails"
        case .executiveSummary: "Draft an executive summary"
        case .jobDescription: "Standout job descriptions"
        case .resignationLetter: "Navigate transitions smoothly"
        case .valueProposition: "Compelling value proposition"
        case .blogPost: "Polished blog post"
        case .blogPostTitle: "Perfect blog title"
        case .businessName: "Unique, brand-ready names"
        case .headline: "Attention-grabbing headlines"
        case .instagramCaption: "Engaging caption instantly"
        case .linkedinPost: "Professional LinkedIn posts"
        case .metaDescription: "SEO-friendly meta descriptions"
        case .metaTitle: "Click-worthy meta titles"
        case .productDescription: "High-converting descriptions"
        case .slogan: "Catchy slogan for your brand"
        case .abstract: "Summarize key points"
        case .essayTitle: "Thought-provoking essay titles"
        case .personalStatement: "Compelling application essays"
        case .poem: "Beautiful, AI-crafted poems"
        case .thesisStatement: "Strong thesis statements"
        case .topicSentences: "Focused topic sentences"
        }
    }

    var iconName: String {
        switch self {
        case .improve: "sparkles"
        case .rewrite: "arrow.triangle.2.circlepath"
        case .moreFormal: "person.fill"
        case .shorter: "scissors"
        case .expand: "arrow.up.left.and.arrow.down.right"
        case .grammar: "textformat.abc"
        case .article: "doc.text"
        case .brainstorm: "lightbulb.fill"
        case .conclusion: "flag.checkered"
        case .formalLetter: "envelope.fill"
        case .fullParagraph: "paragraphsign"
        case .outline: "list.bullet.rectangle"
        case .paragraphRewriter: "arrow.2.squarepath"
        case .rewording: "text.cursor"
        case .sentenceRewriter: "character.cursor.ibeam"
        case .summarizing: "arrow.down.right.and.arrow.up.left"
        case .title: "textformat.size"
        case .sentences: "lineweight"
        case .coverLetter: "doc.richtext"
        case .linkedinHeadline: "person.text.rectangle"
        case .resumeObjective: "target"
        case .resumeSkills: "star.circle"
        case .businessPlan: "chart.bar.doc.horizontal"
        case .businessReport: "doc.plaintext"
        case .email: "envelope.badge"
        case .executiveSummary: "doc.on.clipboard"
        case .jobDescription: "person.badge.plus"
        case .resignationLetter: "arrow.right.square"
        case .valueProposition: "gift"
        case .blogPost: "newspaper"
        case .blogPostTitle: "text.format.superscript"
        case .businessName: "building.2"
        case .headline: "megaphone"
        case .instagramCaption: "camera.macro"
        case .linkedinPost: "network"
        case .metaDescription: "link"
        case .metaTitle: "text.magnifyingglass"
        case .productDescription: "cart"
        case .slogan: "quote.bubble"
        case .abstract: "doc.text.magnifyingglass"
        case .essayTitle: "graduationcap"
        case .personalStatement: "person.crop.circle.badge.checkmark"
        case .poem: "heart.text.square"
        case .thesisStatement: "bolt.horizontal"
        case .topicSentences: "text.alignleft"
        }
    }

    /// Builds the full LLM prompt for this writing mode.
    /// Sourced from `PromptRegistry.Writing`.
    func buildPrompt(for text: String, params: [String: String] = [:]) -> String {
        PromptRegistry.Writing.prompt(for: self, text: text, params: params)
    }
}

// MARK: - Letter Mode

enum LetterMode: String, CaseIterable, Identifiable {
    case businessFormal = "business_formal"
    case friendlyFormal = "friendly_formal"
    case complaint
    case application
    case thankYou = "thank_you"

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .businessFormal: "商务正式"
        case .friendlyFormal: "友好正式"
        case .complaint: "投诉"
        case .application: "申请"
        case .thankYou: "感谢"
        }
    }
}

// MARK: - Writing Context

/// Context passed to a writing feature for processing.
struct WritingContext {
    var originalText: String
    var selectedText: String
    var mode: WritingMode
    var additionalParams: [String: String]

    init(
        originalText: String,
        selectedText: String = "",
        mode: WritingMode = .improve,
        additionalParams: [String: String] = [:]
    ) {
        self.originalText = originalText
        self.selectedText = selectedText.isEmpty ? originalText : selectedText
        self.mode = mode
        self.additionalParams = additionalParams
    }
}

// MARK: - Writing Result

/// Result returned by a writing feature.
struct WritingResult {
    var improvedText: String
    var alternatives: [String]
    var confidence: Double
    var featureId: String
    var metadata: [String: String]

    init(
        improvedText: String,
        alternatives: [String] = [],
        confidence: Double = 0.8,
        featureId: String = "",
        metadata: [String: String] = [:]
    ) {
        self.improvedText = improvedText
        self.alternatives = alternatives
        self.confidence = confidence
        self.featureId = featureId
        self.metadata = metadata
    }
}

// MARK: - Writing Feature Error

enum WritingFeatureError: Error, LocalizedError {
    case emptyInput
    case unsupportedMode(WritingMode)
    case modelNotLoaded
    case responseParseError(String)
    case timeout
    case cancelled

    var errorDescription: String? {
        switch self {
        case .emptyInput:
            "没有可供处理的文本。"
        case let .unsupportedMode(mode):
            "不支持“\(mode.displayName)”模式。"
        case .modelNotLoaded:
            "尚未加载 AI 模型。请在设置中下载并启用模型。"
        case let .responseParseError(detail):
            "解析 AI 响应失败：\(detail)"
        case .timeout:
            "请求超时。"
        case .cancelled:
            "请求已取消。"
        }
    }
}

// MARK: - Processing State

enum WritingProcessingState {
    case idle
    case processing(feature: String)
    case streaming(partial: String)
    case completed(WritingResult)
    case failed(String)

    var isProcessing: Bool {
        switch self {
        case .processing, .streaming: true
        default: false
        }
    }
}
