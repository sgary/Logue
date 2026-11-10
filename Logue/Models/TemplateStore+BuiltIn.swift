// swiftlint:disable file_length force_unwrapping function_body_length
// Note: force_unwrapping is disabled because this file uses 38+ UUID(uuidString:)! calls
// with compile-time constant strings that are guaranteed to be valid UUID format.
import Foundation

extension TemplateStore {
    static func makeBuiltInTemplates() -> [DocumentTemplate] {
        [
            // MARK: Meeting Notes

            meetingNotes(), oneOnOne(), standupNotes(), boardMeetingMinutes(), brainstormingSession(), retrospective(),

            // MARK: Project Management

            projectBrief(), projectPlan(), statusReport(), postMortem(), prd(), sprintPlanning(), releaseNotes(),

            // MARK: Business

            businessProposal(), businessPlan(), swotAnalysis(), competitiveAnalysis(), quarterlyBusinessReview(), executiveSummary(),

            // MARK: Marketing

            contentBrief(), marketingCampaignPlan(), socialMediaPlan(), pressRelease(), brandGuidelines(),

            // MARK: Engineering

            technicalDesignDocument(), bugReport(), rfc(), apiDocumentation(), incidentReport(),

            // MARK: HR & People

            jobDescription(), performanceReview(), onboardingChecklist(), interviewScorecard(), teamCharter(),

            // MARK: Finance

            budgetProposal(), expenseReport(), investmentMemo(),

            // MARK: Academic

            lectureNotes(), researchPaperOutline(), studyGuide(), essayOutline(), labReport(), readingNotes(), groupProjectPlan(), thesisOutline(),

            // MARK: Personal

            weeklyPlanner(), goalTracker(), dailyJournal(), decisionLog(), habitTracker(), travelPlanner(), personalOKRs(),

            // MARK: Communication

            memo(), presentationOutline(), newsletter(),
        ]
    }

    // MARK: - Meeting Notes

    private static func meetingNotes() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000001")!,
            name: "会议纪要",
            category: .meetingNotes,
            icon: "note.text",
            description: "标准会议纪要，包含议程、参会人员、讨论内容和待办事项。",
            body: """
            ## 会议纪要

            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **时间：** 开始 — 结束
            **地点：** 会议室 / 视频会议链接
            **主持人：**

            ---

            ### 参会人员

            | 姓名 | 角色 |
            |------|------|
            |      |      |
            |      |      |
            |      |      |

            ---

            ### 会议议程

            1.
            2.
            3.

            ---

            ### 讨论记录

            #### 议题 1
            - 讨论要点
            - 达成的决议
            - 待确认的问题

            #### 议题 2
            - 讨论要点
            - 达成的决议
            - 待确认的问题

            ---

            ### 待办事项

            - [ ] **[负责人]** — 任务描述（截止日期：）
            - [ ] **[负责人]** — 任务描述（截止日期：）
            - [ ] **[负责人]** — 任务描述（截止日期：）

            ---

            ### 下次会议
            **日期：** 待定
            **议程预告：**
            """,
            isBuiltIn: true
        )
    }

    private static func oneOnOne() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000002")!,
            name: "一对一沟通",
            category: .meetingNotes,
            icon: "person.2",
            description: "定期一对一沟通记录，包含沟通要点、反馈和待办事项。",
            body: """
            ## 一对一沟通

            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **主管：**
            **直接下属：**

            ---

            ### 状态沟通
            - 这周过得怎么样？
            - 有什么值得庆祝的成果或亮点？
            - 有什么想聊的事情？

            ---

            ### 沟通要点（直接下属）

            1.
            2.
            3.

            ### 沟通要点（主管）

            1.
            2.
            3.

            ---

            ### 目标进展
            - **目标 1：** 进展说明
            - **目标 2：** 进展说明
            - **目标 3：** 进展说明

            ---

            ### 反馈

            **正向反馈：**
            -

            **建设性反馈：**
            -

            ---

            ### 职业发展
            - 待提升的技能
            - 即将到来的机会
            - 需要的支持

            ---

            ### 待办事项

            - [ ] **[姓名]** — 任务（截止日期：）
            - [ ] **[姓名]** — 任务（截止日期：）

            ---

            ### 下次沟通记录
            -
            """,
            isBuiltIn: true
        )
    }

    private static func standupNotes() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000003")!,
            name: "每日站会记录",
            category: .meetingNotes,
            icon: "figure.stand",
            description: "每日站会格式，涵盖昨天、今天和阻塞事项。",
            body: """
            ## 每日站会

            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **团队：**

            ---

            ### 团队成员 1：[姓名]

            **昨天：**
            - 完成的任务
            - 推进的功能

            **今天：**
            - 将继续推进
            - 计划开始

            **阻塞事项：**
            - 无 / 描述阻塞点

            ---

            ### 团队成员 2：[姓名]

            **昨天：**
            -

            **今天：**
            -

            **阻塞事项：**
            -

            ---

            ### 团队成员 3：[姓名]

            **昨天：**
            -

            **今天：**
            -

            **阻塞事项：**
            -

            ---

            ### 待议事项
            需要在站会之外进一步讨论的事项：
            -

            ### 关键日期与提醒
            -
            """,
            isBuiltIn: true
        )
    }

    private static func boardMeetingMinutes() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000004")!,
            name: "董事会会议纪要",
            category: .meetingNotes,
            icon: "building.columns",
            description: "正式董事会会议纪要，包含动议、表决和决议。",
            body: """
            ## 董事会会议纪要

            **组织名称：**
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **时间：** 开始 — 结束
            **地点：**
            **会议召集人：**

            ---

            ### 出席情况

            | 姓名 | 职务 | 是否出席 |
            |------|-------|---------|
            |      | 董事长 | 是/否  |
            |      | 董事 | 是/否  |
            |      | 秘书 | 是/否  |
            |      | 财务 | 是/否  |

            **是否达到法定人数：** 是 / 否

            ---

            ### 上次会议纪要的确认
            - 由 [姓名] 提议确认 [日期] 的会议纪要
            - 由 [姓名] 附议
            - **表决：** 通过 / 未通过（赞成：，反对：，弃权：）

            ---

            ### 报告事项

            #### 董事长报告
            -

            #### 财务报告
            - 收入：
            - 支出：
            - 净额：

            ---

            ### 续议事项
            1. [上次会议事项] 的进展

            ### 新增事项

            #### 动议 1：[标题]
            - **提议人：** [姓名]
            - **附议人：** [姓名]
            - **讨论：**
            - **表决：** 通过 / 未通过（赞成：，反对：，弃权：）

            #### 动议 2：[标题]
            - **提议人：** [姓名]
            - **附议人：** [姓名]
            - **讨论：**
            - **表决：** 通过 / 未通过（赞成：，反对：，弃权：）

            ---

            ### 决议
            1.
            2.

            ### 待办事项
            - [ ] **[负责人]** — 任务（截止日期：）

            ### 下次会议
            **日期：**

            **休会时间：** [时间]
            **纪要记录人：** [姓名]
            """,
            isBuiltIn: true
        )
    }

    private static func brainstormingSession() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000005")!,
            name: "头脑风暴会议",
            category: .meetingNotes,
            icon: "lightbulb",
            description: "创意收集记录，包含问题陈述、创意列表和评估矩阵。",
            body: """
            ## 头脑风暴会议

            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **主持人：**
            **参与者：**
            **时长限制：** 60 分钟

            ---

            ### 问题陈述
            我们要解决什么挑战？

            > 在此清晰描述问题或机会。

            ### 约束条件
            - 预算：
            - 时间安排：
            - 技术限制：
            - 其他：

            ---

            ### 基本规则
            1. 没有坏点子
            2. 在他人的想法上继续发挥
            3. 始终围绕问题本身
            4. 一次只讨论一个话题

            ---

            ### 创意

            | # | 创意 | 提出人 | 备注 |
            |---|------|-------------|-------|
            | 1 |      |             |       |
            | 2 |      |             |       |
            | 3 |      |             |       |
            | 4 |      |             |       |
            | 5 |      |             |       |

            ---

            ### 评估矩阵

            | 创意 | 影响力（1-5） | 可行性（1-5） | 投入（1-5） | 总分 |
            |------|--------------|--------------------|--------------|-------|
            |      |              |                    |              |       |
            |      |              |                    |              |       |
            |      |              |                    |              |       |

            ---

            ### 优先探索的 3 个创意
            1. **创意：** — 下一步：
            2. **创意：** — 下一步：
            3. **创意：** — 下一步：

            ### 待办事项
            - [ ] **[负责人]** — 研究 / 制作创意原型（截止日期：）
            - [ ] **[负责人]** — 安排后续会议（截止日期：）
            """,
            isBuiltIn: true
        )
    }

    private static func retrospective() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000006")!,
            name: "回顾会议",
            category: .meetingNotes,
            icon: "arrow.trianglehead.2.clockwise",
            description: "冲刺回顾，涵盖做得好的、待改进的以及改进措施。",
            body: """
            ## 冲刺回顾

            **冲刺：** 第 [#] 个冲刺
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **主持人：**
            **团队：**

            ---

            ### 做得好的地方
            应继续保持的做法：
            -
            -
            -

            ---

            ### 做得不好的地方
            造成摩擦或问题的环节：
            -
            -
            -

            ---

            ### 我们的收获
            新的洞察或发现：
            -
            -

            ---

            ### 改进建议

            | 改进项 | 优先级 | 负责人 |
            |------------|----------|-------|
            |            | 高/中/低 |   |
            |            | 高/中/低 |   |
            |            | 高/中/低 |   |

            ---

            ### 下个冲刺的待办事项
            - [ ] **[负责人]** — 改进措施（截止日期：）
            - [ ] **[负责人]** — 改进措施（截止日期：）
            - [ ] **[负责人]** — 改进措施（截止日期：）

            ---

            ### 团队满意度评分
            给本次冲刺打分（1-5）：⭐️

            ### 上次回顾的跟进
            - [ ] 上次回顾的待办事项 — 状态
            """,
            isBuiltIn: true
        )
    }

    // MARK: - Project Management

    private static func projectBrief() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000007")!,
            name: "项目简介",
            category: .projectManagement,
            icon: "doc.text",
            description: "项目概览，包含目标、范围、时间线和利益相关方。",
            body: """
            ## 项目简介

            **项目名称：**
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **项目负责人：**
            **发起人：**

            ---

            ### 项目概览
            简明描述项目内容及其重要意义。

            ### 业务目标
            这个项目服务于什么业务目标？

            ---

            ### 目标与成功标准

            | 目标 | 成功指标 | 目标值 |
            |------|---------------|--------|
            |      |               |        |
            |      |               |        |

            ---

            ### 范围

            **包含在范围内：**
            -
            -

            **不包含在范围内：**
            -
            -

            ---

            ### 利益相关方

            | 姓名 | 角色 | 职责 |
            |------|------|---------------|
            |      |      | 决策者 |
            |      |      | 参与者 |
            |      |      | 评审人 |

            ---

            ### 时间线

            | 阶段 | 开始 | 结束 | 交付物 |
            |-------|-------|-----|-------------|
            | 探索 |  |  |             |
            | 设计 |  |  |             |
            | 构建 |  |  |             |
            | 上线 |  |  |             |

            ---

            ### 预算
            - 预估成本：
            - 资金来源：

            ### 风险与假设
            - **风险：** 应对方案
            - **假设：**

            ### 审批
            - [ ] 发起人审批
            - [ ] 利益相关方确认
            """,
            isBuiltIn: true
        )
    }

    private static func projectPlan() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000008")!,
            name: "项目计划",
            category: .projectManagement,
            icon: "list.clipboard",
            description: "详细的项目计划，包含里程碑、交付物、依赖关系和负责人。",
            body: """
            ## 项目计划

            **项目名称：**
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **项目经理：**
            **版本：** 1.0

            ---

            ### 项目目标
            1.
            2.
            3.

            ---

            ### 里程碑

            | 里程碑 | 目标日期 | 状态 | 负责人 |
            |-----------|-------------|--------|-------|
            | 项目启动 |             | 未开始 |  |
            | 里程碑 1 |           | 未开始 |  |
            | 里程碑 2 |           | 未开始 |  |
            | 里程碑 3 |           | 未开始 |  |
            | 上线 |             | 未开始 |  |

            ---

            ### 交付物

            | 交付物 | 说明 | 负责人 | 截止日期 | 状态 |
            |------------|-------------|-------|----------|--------|
            |            |             |       |          | 未开始 |
            |            |             |       |          | 未开始 |
            |            |             |       |          | 未开始 |

            ---

            ### 依赖关系

            | 依赖项 | 依赖对象 | 延迟影响 | 负责人 |
            |-----------|-----------|-------------------|-------|
            |           |           |                   |       |
            |           |           |                   |       |

            ---

            ### 团队与角色

            | 姓名 | 角色 | 投入比例（%） |
            |------|------|---------------|
            |      |      |               |
            |      |      |               |

            ---

            ### 沟通计划
            - **每周状态同步：** [星期] [时间]
            - **利益相关方更新：** 每两周一次
            - **升级路径：**

            ### 风险登记表

            | 风险 | 可能性 | 影响 | 应对措施 |
            |------|-----------|--------|------------|
            |      | 高/中/低 | 高/中/低 |    |
            |      | 高/中/低 | 高/中/低 |    |
            """,
            isBuiltIn: true
        )
    }

    private static func statusReport() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000009")!,
            name: "状态报告",
            category: .projectManagement,
            icon: "chart.bar",
            description: "每周状态报告，包含进展、风险、阻塞事项和下一步安排。",
            body: """
            ## 状态报告

            **项目：**
            **报告周期：** \(Date.now.formatted(date: .long, time: .omitted)) 起的一周
            **撰写人：**
            **整体状态：** 🟢 正常推进 / 🟡 存在风险 / 🔴 进度偏离

            ---

            ### 摘要
            本周期进展的简要概述。

            ---

            ### 进展

            | 任务 / 交付物 | 状态 | 完成度 | 备注 |
            |-------------------|--------|-----------|-------|
            |                   | 已完成   | 100%      |       |
            |                   | 进行中 | 60%  |       |
            |                   | 未开始 | 0%   |       |

            ---

            ### 关键成果
            -
            -
            -

            ### 风险与问题

            | 风险 / 问题 | 严重程度 | 状态 | 应对 / 解决方案 |
            |-------------|----------|--------|------------------------|
            |             | 高     | 未解决   |                        |
            |             | 中   | 未解决   |                        |

            ---

            ### 阻塞事项
            - [ ] 阻塞事项描述 — 由 [姓名] 负责，需在 [日期] 前解决

            ---

            ### 下一步安排（下周）
            - [ ] 任务 1 — 负责人
            - [ ] 任务 2 — 负责人
            - [ ] 任务 3 — 负责人

            ### 需要决策的事项
            1. 决策描述 — 需在 [日期] 前确定

            ### 预算 / 资源更新
            - 已使用预算：$X / $Y
            - 资源情况：符合计划 / 需要追加
            """,
            isBuiltIn: true
        )
    }

    private static func postMortem() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000010")!,
            name: "项目复盘",
            category: .projectManagement,
            icon: "flag.checkered",
            description: "项目复盘，包含结果、经验教训和改进建议。",
            body: """
            ## 项目复盘

            **项目：**
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **撰写人：**
            **参与人：**

            ---

            ### 项目摘要
            简要描述项目、其目标和预期结果。

            ---

            ### 结果

            | 目标 | 目标值 | 实际结果 | 是否达成 |
            |------|--------|--------|------|
            |      |        |        | 是/否 |
            |      |        |        | 是/否 |
            |      |        |        | 是/否 |

            **整体结果：** 成功 / 部分成功 / 未成功

            ---

            ### 时间线回顾

            | 里程碑 | 计划日期 | 实际日期 | 偏差 |
            |-----------|-------------|-------------|-------|
            |           |             |             |       |
            |           |             |             |       |

            ---

            ### 做得好的地方
            -
            -
            -

            ### 可以做得更好的地方
            -
            -
            -

            ---

            ### 问题的根本原因
            1. **问题：** 根本原因及促成因素
            2. **问题：** 根本原因及促成因素

            ### 经验教训
            1.
            2.
            3.

            ---

            ### 对后续项目的建议
            - [ ] 流程改进
            - [ ] 工具或资源调整
            - [ ] 沟通改进

            ### 致谢
            感谢团队成员的付出与贡献。
            """,
            isBuiltIn: true
        )
    }

    private static func prd() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000011")!,
            name: "产品需求文档",
            category: .projectManagement,
            icon: "doc.richtext",
            description: "产品需求文档，包含用户故事、验收标准和技术要求。",
            body: """
            ## 产品需求文档

            **产品：**
            **版本：** 1.0
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **撰写人：**
            **状态：** 草稿 / 评审中 / 已批准

            ---

            ### 概览
            这个产品或功能是什么？我们为什么要做它？

            ### 问题陈述
            描述用户痛点或业务需求。

            ### 目标用户
            - **主要用户：** 主要用户画像说明
            - **次要用户：** 次要用户画像说明

            ---

            ### 用户故事

            | ID | 作为…… | 我希望…… | 以便…… | 优先级 |
            |----|---------|-------------|-----------|----------|
            | US-1 |       |             |           | 必须有 |
            | US-2 |       |             |           | 应该有 |
            | US-3 |       |             |           | 可选 |

            ---

            ### 验收标准

            #### US-1：[故事标题]
            - [ ] 假如 [场景]，当 [操作] 时，那么 [结果]
            - [ ] 假如 [场景]，当 [操作] 时，那么 [结果]

            #### US-2：[故事标题]
            - [ ] 假如 [场景]，当 [操作] 时，那么 [结果]

            ---

            ### 技术要求
            - 性能：响应时间低于 X 毫秒
            - 可扩展性：支持最多 N 个并发用户
            - 安全：身份认证、数据加密
            - 兼容性：支持的平台和版本

            ### 非功能性需求
            - 辅助功能：
            - 本地化：
            - 数据分析：

            ---

            ### 设计与线框图
            在此链接设计稿或插入截图。

            ### 依赖关系
            - 外部服务：
            - 内部团队：

            ### 发布标准
            - [ ] 所有优先级为“必须有”的用户故事已完成
            - [ ] 测试验收通过
            - [ ] 性能基准达标
            - [ ] 文档已更新
            """,
            isBuiltIn: true
        )
    }

    private static func sprintPlanning() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000012")!,
            name: "冲刺规划",
            category: .projectManagement,
            icon: "calendar.badge.clock",
            description: "冲刺规划，包含目标、容量规划和承诺的任务列表。",
            body: """
            ## 冲刺规划

            **冲刺：** 第 [#] 个冲刺
            **起止日期：** 开始 — 结束
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **敏捷教练：**
            **产品负责人：**

            ---

            ### 冲刺目标
            本冲刺最重要的单一成果是什么？

            > 在此写明冲刺目标。

            ---

            ### 团队容量

            | 团队成员 | 可用天数 | 备注 |
            |------------|---------------|-------|
            |            |               | 休假 / 部分可用 |
            |            |               |       |
            |            |               |       |
            | **合计**  | **X 天**    |       |

            ---

            ### 承诺完成的任务

            | 工单 | 标题 | 故事点 | 负责人 | 优先级 |
            |--------|-------|--------|----------|----------|
            |        |       |        |          | 高     |
            |        |       |        |          | 高     |
            |        |       |        |          | 中   |
            |        |       |        |          | 中   |
            |        |       |        |          | 低      |

            **承诺的故事点总数：**
            **速率（最近 3 个冲刺）：**

            ---

            ### 弹性目标
            如果容量允许可以纳入的事项：
            1.
            2.

            ---

            ### 依赖与风险
            - **依赖：** 说明 — 状态
            - **风险：** 说明 — 应对措施

            ### 上个冲刺的遗留事项
            - 工单 — 遗留原因

            ### 完成定义
            - [ ] 代码已评审
            - [ ] 测试通过
            - [ ] 文档已更新
            - [ ] 已部署到预发布环境
            """,
            isBuiltIn: true
        )
    }

    private static func releaseNotes() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000013")!,
            name: "版本发布说明",
            category: .projectManagement,
            icon: "shippingbox",
            description: "版本发布说明，记录新功能、缺陷修复和已知问题。",
            body: """
            ## 版本发布说明

            **产品：**
            **版本：**
            **发布日期：** \(Date.now.formatted(date: .long, time: .omitted))

            ---

            ### 亮点
            本次发布最重要变更的简要概述。

            ---

            ### 新功能

            - **功能名称** — 功能说明及使用方法。
            - **功能名称** — 功能说明及使用方法。
            - **功能名称** — 功能说明及使用方法。

            ---

            ### 改进

            - **模块** — 改进说明。
            - **模块** — 改进说明。

            ---

            ### 缺陷修复

            - **已修复：** 已解决问题说明。
            - **已修复：** 已解决问题说明。
            - **已修复：** 已解决问题说明。

            ---

            ### 已知问题

            | 问题 | 严重程度 | 临时方案 |
            |-------|----------|------------|
            |       | 高     |            |
            |       | 中   | 使用 [替代方案] |

            ---

            ### 破坏性变更
            - 说明破坏性变更内容及迁移步骤。

            ### 弃用
            - 功能 / API 已弃用 — 将在版本 X 中移除。

            ### 升级说明
            1. 第一步
            2. 第二步
            3. 第三步

            ---

            ### 贡献者
            感谢所有为本次发布做出贡献的人。
            """,
            isBuiltIn: true
        )
    }

    // MARK: - Business

    private static func businessProposal() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000014")!,
            name: "商业提案",
            category: .business,
            icon: "briefcase",
            description: "专业提案，包含执行摘要、实施方案、报价和时间线。",
            body: """
            ## 商业提案

            **呈交：** [客户 / 组织]
            **编制人：** [你的姓名 / 公司]
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **有效期至：**

            ---

            ### 执行摘要
            简要说明商机、你提出的解决方案以及预期交付的价值。

            ---

            ### 需求理解
            展现你对客户挑战和需求的理解。

            - 挑战 1：
            - 挑战 2：
            - 挑战 3：

            ---

            ### 建议方案

            #### 阶段 1：探索
            - 主要活动与交付物

            #### 阶段 2：实施
            - 主要活动与交付物

            #### 阶段 3：交付与支持
            - 主要活动与交付物

            ---

            ### 时间线

            | 阶段 | 周期 | 开始 | 结束 |
            |-------|----------|-------|-----|
            | 探索 | 2 周 |   |     |
            | 实施 | 6 周 | | |
            | 交付 | 2 周 |     |     |

            ---

            ### 报价

            | 项目 | 说明 | 费用 |
            |------|-------------|------|
            |      |             | $    |
            |      |             | $    |
            |      |             | $    |
            | **合计** |       | **$** |

            **付款条件：**

            ---

            ### 为什么选择我们
            - 差异化优势 1
            - 差异化优势 2
            - 相关经验

            ### 条款与条件
            - 范围边界
            - 变更请求流程
            - 知识产权

            ### 下一步
            1. 审阅提案
            2. 安排答疑通话
            3. 签署协议
            """,
            isBuiltIn: true
        )
    }

    private static func businessPlan() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000015")!,
            name: "商业计划书",
            category: .business,
            icon: "chart.line.uptrend.xyaxis",
            description: "完整的商业计划书，包含市场分析、战略和财务预测。",
            body: """
            ## 商业计划书

            **公司名称：**
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **撰写人：**

            ---

            ### 执行摘要
            用一段话概述业务内容、使命和关键财务预测。

            ### 公司简介
            - **使命：**
            - **愿景：**
            - **法律形式：**
            - **所在地：**

            ---

            ### 市场分析

            #### 行业概览
            描述行业情况、趋势和增长前景。

            #### 目标市场
            - **用户特征：**
            - **市场规模：**
            - **增长率：**

            #### 竞争格局

            | 竞争对手 | 优势 | 劣势 | 市场份额 |
            |-----------|-----------|------------|-------------|
            |           |           |            |             |
            |           |           |            |             |

            ---

            ### 产品与服务
            - 产品与服务说明
            - 价值主张
            - 定价模式

            ### 营销与销售策略
            - 客户获取渠道
            - 销售流程
            - 关键合作伙伴

            ---

            ### 财务预测

            | 年度 | 收入 | 支出 | 净收入 |
            |------|---------|----------|-----------|
            | 第 1 年   | $       | $        | $         |
            | 第 2 年   | $       | $        | $         |
            | 第 3 年   | $       | $        | $         |

            ### 融资需求
            - 所需金额：$
            - 资金用途：
            - 预期投资回报：

            ---

            ### 团队

            | 姓名 | 角色 | 背景 |
            |------|------|-----------|
            |      | CEO  |           |
            |      | CTO  |           |

            ### 里程碑
            - [ ] 里程碑 1 — 目标日期
            - [ ] 里程碑 2 — 目标日期
            """,
            isBuiltIn: true
        )
    }

    private static func swotAnalysis() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000016")!,
            name: "SWOT 分析",
            category: .business,
            icon: "square.grid.2x2",
            description: "战略 SWOT 分析，涵盖优势、劣势、机会和威胁。",
            body: """
            ## SWOT 分析

            **分析对象：** [公司 / 产品 / 举措]
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **编制人：**

            ---

            ### 优势（内部、积极）
            我们有哪些优势？哪些方面做得好？

            -
            -
            -
            -

            ---

            ### 劣势（内部、消极）
            哪些方面可以改进？我们还欠缺什么？

            -
            -
            -
            -

            ---

            ### 机会（外部、积极）
            我们可以借助哪些趋势或变化？

            -
            -
            -
            -

            ---

            ### 威胁（外部、消极）
            我们面临哪些障碍？竞争对手在做什么？

            -
            -
            -
            -

            ---

            ### 战略行动

            | 组合 | 策略 | 优先级 |
            |-----------|----------|----------|
            | 优势 + 机会 | 利用 [优势] 抓住 [机会] | 高 |
            | 优势 + 威胁 | 借助 [优势] 抵御 [威胁] | 中 |
            | 劣势 + 机会 | 改善 [劣势] 以释放 [机会] | 高 |
            | 劣势 + 威胁 | 弥补 [劣势] 以降低 [威胁] 风险 | 关键 |

            ---

            ### 关键结论
            1.
            2.
            3.

            ### 建议的下一步
            - [ ] 行动项 1
            - [ ] 行动项 2
            - [ ] 行动项 3
            """,
            isBuiltIn: true
        )
    }

    private static func competitiveAnalysis() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000017")!,
            name: "竞品分析",
            category: .business,
            icon: "person.3.sequence",
            description: "竞争对手对比，包含功能分析和市场定位。",
            body: """
            ## 竞品分析

            **市场 / 品类：**
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **编制人：**

            ---

            ### 市场概览
            简要描述市场格局和关键趋势。

            ---

            ### 竞争对手概况

            #### 竞争对手 1：[名称]
            - **官网：**
            - **成立时间：**
            - **融资 / 收入：**
            - **目标市场：**
            - **核心差异点：**

            #### 竞争对手 2：[名称]
            - **官网：**
            - **成立时间：**
            - **融资 / 收入：**
            - **目标市场：**
            - **核心差异点：**

            #### 竞争对手 3：[名称]
            - **官网：**
            - **成立时间：**
            - **融资 / 收入：**
            - **目标市场：**
            - **核心差异点：**

            ---

            ### 功能对比

            | 功能 | 我们 | 竞争对手 1 | 竞争对手 2 | 竞争对手 3 |
            |---------|----|-------------|-------------|-------------|
            | 功能 A | 有 | 有 | 无 | 部分 |
            | 功能 B | 有 | 无 | 有 | 有 |
            | 功能 C | 计划中 | 有 | 有 | 无 |
            | 定价 | $X/月 | $Y/月 | $Z/月 | $W/月 |

            ---

            ### 定位图
            描述各竞争对手在关键维度上的位置（例如价格与功能、大型企业与中小企业）。

            ### 与竞争对手相比的优势与劣势
            - **我们的优势：**
            - **他们的优势：**
            - **需要补齐的差距：**

            ### 战略建议
            - [ ] 差异化机会
            - [ ] 需要对齐的功能
            - [ ] 市场定位调整
            """,
            isBuiltIn: true
        )
    }

    private static func quarterlyBusinessReview() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000018")!,
            name: "季度业务回顾",
            category: .business,
            icon: "calendar.badge.checkmark",
            description: "季度业务回顾模板，包含关键指标、成果、挑战和下季度目标。",
            body: """
            ## 季度业务回顾

            **季度：** 第 [1-4] 季度 [年份]
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **汇报人：**

            ---

            ### 执行摘要
            本季度业绩表现与展望的高层概述。

            ---

            ### 关键绩效指标

            | 指标 | 目标 | 实际 | 状态 |
            |-----|--------|--------|--------|
            | 收入 | $ | $ | 🟢/🟡/🔴 |
            | 活跃用户 | | | 🟢/🟡/🔴 |
            | 流失率 | % | % | 🟢/🟡/🔴 |
            | NPS 得分 | | | 🟢/🟡/🔴 |
            | 客户获取成本 | $ | $ | 🟢/🟡/🔴 |

            ---

            ### 主要成果
            -
            -
            -

            ### 挑战与经验
            -
            -
            -

            ---

            ### 产品动态
            - 功能发布：
            - 路线图进展：

            ### 客户亮点
            - 新增客户：
            - 客户扩展：
            - 客户流失：

            ---

            ### 下季度目标

            | 目标 | 负责人 | 目标值 | 优先级 |
            |------|-------|--------|----------|
            |      |       |        | 高     |
            |      |       |        | 中   |
            |      |       |        | 中   |

            ### 资源需求
            -
            -

            ### 自由讨论
            供团队反馈与对齐的话题。
            """,
            isBuiltIn: true
        )
    }

    private static func executiveSummary() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000019")!,
            name: "执行摘要",
            category: .business,
            icon: "star.square.on.square",
            description: "简明的执行摘要，包含关键发现和建议。",
            body: """
            ## 执行摘要

            **主题：**
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **编制人：**
            **读者对象：**

            ---

            ### 目的
            这份文档为何存在，支持哪项决策。

            ---

            ### 背景
            理解这些发现所需的简要背景。

            ---

            ### 关键发现

            1. **发现 1：** 说明及支撑数据
            2. **发现 2：** 说明及支撑数据
            3. **发现 3：** 说明及支撑数据

            ---

            ### 分析摘要

            | 因素 | 现状 | 影响 | 紧急程度 |
            |--------|--------------|--------|---------|
            |        |              | 高   | 立即 |
            |        |              | 中 | 短期 |
            |        |              | 低    | 长期 |

            ---

            ### 建议

            1. **建议 1：** 理由与预期结果
            2. **建议 2：** 理由与预期结果
            3. **建议 3：** 理由与预期结果

            ---

            ### 财务影响
            - 预估成本：
            - 预期收益：
            - 投资回报周期：

            ### 下一步
            - [ ] 需在 [日期] 前做出决策
            - [ ] [日期] 启动实施
            - [ ] [日期] 进行后续复盘

            ### 附录
            引用详细的支撑文档。
            """,
            isBuiltIn: true
        )
    }

    // MARK: - Marketing

    private static func contentBrief() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000020")!,
            name: "内容简报",
            category: .marketing,
            icon: "pencil.and.outline",
            description: "内容简报，包含受众、目标、核心信息和 SEO 关键词。",
            body: """
            ## 内容简报

            **内容标题：**
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **作者：**
            **内容类型：** 博客 / 白皮书 / 视频 / 社交媒体帖子
            **计划发布日期：**

            ---

            ### 目标
            这篇内容的目的是什么？希望读者采取什么行动？

            ### 目标受众
            - **主要用户画像：**
            - **痛点：**
            - **漏斗阶段：** 认知 / 考虑 / 决策

            ---

            ### 核心信息
            1. 要传达的主要信息
            2. 支撑信息
            3. 支撑信息

            ### SEO 关键词

            | 关键词 | 搜索量 | 难度 | 优先级 |
            |---------|--------------|------------|----------|
            |         |              |            | 主要  |
            |         |              |            | 次要 |
            |         |              |            | 次要 |

            ---

            ### 内容大纲
            1. **引言** — 吸引注意并交代背景
            2. **第 1 部分** — 核心观点及支撑依据
            3. **第 2 部分** — 核心观点及支撑依据
            4. **第 3 部分** — 核心观点及支撑依据
            5. **结论** — 总结并发出行动号召

            ---

            ### 语气与风格
            - 语气：专业 / 口语化 / 技术
            - 篇幅：目标字数
            - 参考资料 / 来源：

            ### 分发渠道
            - [ ] 博客
            - [ ] 邮件简报
            - [ ] 社交媒体
            - [ ] 付费推广

            ### 成功指标
            - 目标浏览量：
            - 目标互动量：
            - 转化目标：
            """,
            isBuiltIn: true
        )
    }

    private static func marketingCampaignPlan() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000021")!,
            name: "营销活动计划",
            category: .marketing,
            icon: "megaphone",
            description: "营销活动计划，包含目标、渠道、预算、时间线和衡量指标。",
            body: """
            ## 营销活动计划

            **活动名称：**
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **活动负责人：**
            **持续时间：** 开始 — 结束

            ---

            ### 活动目标
            我们要推动什么具体结果？必须可衡量。

            ### 目标受众
            - **人群特征：**
            - **心理特征：**
            - **细分人群：**

            ---

            ### 核心信息
            - **主标题：**
            - **价值主张：**
            - **行动号召：**

            ---

            ### 渠道策略

            | 渠道 | 策略 | 预算 | 负责人 | 时间安排 |
            |---------|--------|--------|-------|----------|
            | 邮件   |        | $      |       |          |
            | 社交媒体  |        | $      |       |          |
            | 付费广告 |       | $      |       |          |
            | 内容 |        | $      |       |          |
            | 活动  |        | $      |       |          |

            ---

            ### 预算

            | 类别 | 计划 | 实际 |
            |----------|---------|--------|
            | 创意 | $       | $      |
            | 媒介    | $       | $      |
            | 工具    | $       | $      |
            | **合计** | **$**  | **$**  |

            ---

            ### 时间线

            | 周次 | 活动 | 状态 |
            |------|----------|--------|
            | 第 1 周    | 活动筹备与素材制作 | |
            | 第 2 周    | 小范围上线 | |
            | 第 3-4 周  | 全面上线 | |
            | 第 5 周    | 优化调整 | |
            | 第 6 周    | 收尾与汇报 | |

            ### 成功指标

            | 指标 | 目标 | 实际 |
            |--------|--------|--------|
            | 曝光量 | | |
            | 点击率 | | |
            | 转化数 | | |
            | 获客成本 | | |
            | 投资回报率 | | |
            """,
            isBuiltIn: true
        )
    }

    private static func socialMediaPlan() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000022")!,
            name: "社交媒体计划",
            category: .marketing,
            icon: "bubble.left.and.bubble.right",
            description: "社交媒体策略，包含平台规划和内容日历。",
            body: """
            ## 社交媒体计划

            **品牌 / 产品：**
            **周期：** 月度 / 季度
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **负责人：**

            ---

            ### 目标
            1. 互动率提升 X%
            2. 粉丝增长 X
            3. 为网站带来 X 次访问

            ---

            ### 平台策略

            | 平台 | 受众 | 发布频率 | 内容重点 |
            |----------|----------|---------------|---------------|
            | X (Twitter) | | 每周 3-5 次 | 行业洞察、互动交流 |
            | LinkedIn | | 每周 2-3 次 | 观点领导力、公司动态 |
            | Instagram | | 每周 3-4 次 | 视觉内容、幕后花絮 |
            | TikTok | | 每周 2-3 次 | 短视频、热门趋势 |

            ---

            ### 内容支柱
            1. **教育类** — 技巧、操作方法、行业洞察
            2. **推广类** — 产品功能、发布信息、优惠活动
            3. **社区类** — 用户故事、幕后花絮、团队风采
            4. **互动类** — 投票、提问、热门话题

            ---

            ### 每周内容日历

            | 星期 | 平台 | 内容类型 | 主题 | 状态 |
            |-----|----------|-------------|-------|--------|
            | 周一 |          |             |       | 草稿  |
            | 周二 |          |             |       | 草稿  |
            | 周三 |          |             |       | 草稿  |
            | 周四 |          |             |       | 草稿  |
            | 周五 |          |             |       | 草稿  |

            ---

            ### 话题标签策略
            - 品牌标签：
            - 行业标签：
            - 热门标签：

            ### 需跟踪的指标
            - 互动率
            - 粉丝增长
            - 点击率
            - 覆盖与曝光
            """,
            isBuiltIn: true
        )
    }

    private static func pressRelease() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000023")!,
            name: "新闻稿",
            category: .marketing,
            icon: "newspaper",
            description: "标准新闻稿格式，包含标题、电头、正文和公司简介。",
            body: """
            ## 新闻稿

            **即时发布**

            ---

            ### [标题：清晰且有新闻价值的陈述]

            #### [副标题：补充更多背景]

            **[城市，州/省]** — **\(Date.now.formatted(
                date: .long,
                time: .omitted
            ))** — [公司名称]，[简要说明]，今日宣布 \
            [宣布的事项]。这一[产品/举措/合作] \
            将[关键收益或影响]。

            ---

            ### 新闻内容
            展开说明此次公告。它是什么？为什么重要？请包含具体细节、数字和日期。

            ### 相关引述
            “[高管或利益相关方对此次公告意义的评价]，”\
            [公司名称] 的 [职务] [姓名] 表示，\
            “[补充背景或前瞻性表述]。”

            ### 详情与背景
            提供背景信息、运作方式、受益对象以及相关行业背景。请包含支撑报道的数据或统计。

            ### 可获取方式
            [产品 / 服务 / 举措的可用时间与渠道。如适用，请注明价格。]

            ---

            ### 关于 [公司名称]
            [标准公司简介：2-3 句话，包含成立年份、使命、关键信息和官网。]

            ---

            **媒体联系人：**
            [姓名]
            [职务]
            [邮箱]
            [电话]

            ###
            """,
            isBuiltIn: true
        )
    }

    private static func brandGuidelines() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000024")!,
            name: "品牌规范",
            category: .marketing,
            icon: "paintpalette",
            description: "品牌规范，涵盖语气、语调、颜色和使用规则。",
            body: """
            ## 品牌规范

            **品牌：**
            **版本：** 1.0
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **负责人：**

            ---

            ### 品牌使命与价值观
            - **使命：**
            - **愿景：**
            - **核心价值观：**
              1.
              2.
              3.

            ---

            ### 品牌语气与语调

            **语气特征：**
            - 专业而亲和
            - 自信而不自大
            - 清晰简洁

            | 场景 | 语气 | 示例 |
            |---------|------|---------|
            | 营销文案 | 热情、鼓舞人心 | |
            | 客户支持 | 有同理心、乐于帮助 | |
            | 技术文档 | 清晰、准确 | |
            | 社交媒体 | 口语化、友好 | |

            **我们会用的词：**
            -

            **我们会避开的词：**
            -

            ---

            ### 视觉识别

            #### 标志
            - 主标志用法
            - 最小尺寸：Xpx
            - 留白：四周各 X
            - 禁止：拉伸、改色、添加效果

            #### 配色

            | 颜色 | 十六进制 | RGB | 用途 |
            |-------|-----|-----|-------|
            | 主色 |  |  | 标题、行动按钮 |
            | 辅助色 |  |  | 点缀、链接 |
            | 中性色 |  |  | 正文、背景 |
            | 成功色 |  |  | 正面状态 |
            | 警示色 |  |  | 警示状态 |

            #### 字体排印
            - **标题：** 字体名称、字重
            - **正文：** 字体名称、字重
            - **代码 / 等宽：** 字体名称

            ---

            ### 摄影与图像
            - 风格：真实、高质量
            - 题材：人物、产品、工作场景
            - 避免：图库照片的俗套

            ### 使用规范
            - [ ] 始终使用已批准的标志文件
            - [ ] 保持最低对比度
            - [ ] 根据受众场景遵循语气指南
            """,
            isBuiltIn: true
        )
    }

    // MARK: - Engineering

    private static func technicalDesignDocument() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000025")!,
            name: "技术设计文档",
            category: .engineering,
            icon: "wrench.and.screwdriver",
            description: "技术设计文档，包含问题陈述、建议方案和权衡分析。",
            body: """
            ## 技术设计文档

            **标题：**
            **作者：**
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **状态：** 草稿 / 评审中 / 已批准
            **评审人：**

            ---

            ### 问题陈述
            这个设计要解决什么问题？请说明背景和动机。

            ### 目标与非目标

            **目标：**
            -
            -

            **非目标：**
            -
            -

            ---

            ### 背景
            相关的技术背景、现有系统和前期工作。

            ---

            ### 建议方案

            #### 架构概览
            描述高层架构。如有需要，可附上架构图。

            #### 关键组件
            1. **组件 A** — 职责与接口
            2. **组件 B** — 职责与接口
            3. **组件 C** — 职责与接口

            #### 数据模型
            描述新增或修改的数据结构。

            #### API 变更
            描述新增或修改的 API 端点 / 接口。

            ---

            ### 备选方案

            | 方案 | 优点 | 缺点 |
            |--------|------|------|
            | 方案 A（已选定） | | |
            | 方案 B | | |
            | 方案 C | | |

            **选择该方案的理由：**

            ---

            ### 权衡取舍
            - 性能与复杂度
            - 一致性与可用性
            - 自研与采购

            ### 安全考量
            -

            ### 测试策略
            - 单元测试：
            - 集成测试：
            - 性能基准：

            ### 上线计划
            1. 功能开关
            2. 灰度发布
            3. 全量发布

            ### 待确认问题
            - [ ] 问题 1
            - [ ] 问题 2
            """,
            isBuiltIn: true
        )
    }

    private static func bugReport() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000026")!,
            name: "缺陷报告",
            category: .engineering,
            icon: "ladybug",
            description: "缺陷报告，包含复现步骤、预期与实际表现以及环境信息。",
            body: """
            ## 缺陷报告

            **标题：**
            **报告人：**
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **严重程度：** 致命 / 高 / 中 / 低
            **优先级：** P0 / P1 / P2 / P3

            ---

            ### 摘要
            用一句话描述该缺陷。

            ---

            ### 复现步骤
            1. 打开 [页面 / 界面]
            2. 点击 [元素]
            3. 输入 [数据]
            4. 观察结果

            ### 预期行为
            按上述步骤操作时应该发生什么。

            ### 实际行为
            实际发生了什么。如有错误信息请一并提供。

            ---

            ### 环境信息

            | 属性 | 值 |
            |----------|-------|
            | 操作系统 | macOS [版本] |
            | 应用版本 | |
            | 设备 / 硬件 | |
            | 浏览器（如为网页） | |
            | 账户 / 用户 | |

            ---

            ### 截图 / 录屏
            附上相关截图或屏幕录制。

            ### 日志
            ```
            在此粘贴相关日志输出。
            ```

            ---

            ### 补充信息
            - 复现频率：每次 / 有时 / 极少
            - 是否回归：是 / 否 / 未知
            - 是否有临时方案：是 / 否
            - 相关问题：

            ### 排查记录
            -
            """,
            isBuiltIn: true
        )
    }

    private static func rfc() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000027")!,
            name: "RFC",
            category: .engineering,
            icon: "text.bubble",
            description: "意见征求文档（RFC），包含背景、可选方案和建议。",
            body: """
            ## RFC：[标题]

            **作者：**
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **状态：** 征求意见中 / 已接受 / 已拒绝
            **反馈截止日期：**

            ---

            ### 背景
            描述提出这份 RFC 的背景和动机。是什么问题或机会促成了这个提案？

            ---

            ### 现状
            目前系统如何运作？有哪些局限？

            ---

            ### 提案
            详细描述建议的变更。

            #### 方案 A：[名称]
            - **说明：**
            - **优点：**
              -
              -
            - **缺点：**
              -
              -
            - **预估工作量：**

            #### 方案 B：[名称]
            - **说明：**
            - **优点：**
              -
              -
            - **缺点：**
              -
              -
            - **预估工作量：**

            #### 方案 C：[名称]
            - **说明：**
            - **优点：**
              -
              -
            - **缺点：**
              -
              -
            - **预估工作量：**

            ---

            ### 建议
            **推荐方案：** 方案 [X]
            **理由：** 说明为什么优先选择该方案。

            ---

            ### 影响评估
            - **受影响的系统：**
            - **是否需要迁移：**
            - **向后兼容性：**

            ### 待确认问题
            1.
            2.

            ### 反馈

            | 评审人 | 投票 | 意见 |
            |----------|------|----------|
            |          | +1/0/-1 |       |
            |          | +1/0/-1 |       |
            """,
            isBuiltIn: true
        )
    }

    private static func apiDocumentation() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000028")!,
            name: "API 文档",
            category: .engineering,
            icon: "curlybraces",
            description: "API 文档，包含接口、参数、示例和错误码。",
            body: """
            ## API 文档

            **API 名称：**
            **基础 URL：** `https://api.example.com/v1`
            **版本：** 1.0
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **作者：**

            ---

            ### 身份认证
            - **方式：** Bearer Token / API Key / OAuth 2.0
            - **请求头：** `Authorization: Bearer <token>`

            ---

            ### 接口

            #### `GET /resource`
            获取资源列表。

            **参数：**

            | 参数 | 类型 | 是否必填 | 说明 |
            |------|------|----------|-------------|
            | `page` | integer | 否 | 页码（默认：1） |
            | `limit` | integer | 否 | 每页数量（默认：20） |
            | `filter` | string | 否 | 筛选表达式 |

            **响应（200 OK）：**
            ```json
            {
              "data": [
                {
                  "id": "abc123",
                  "name": "Example",
                  "created_at": "2025-01-01T00:00:00Z"
                }
              ],
              "meta": {
                "page": 1,
                "total": 100
              }
            }
            ```

            ---

            #### `POST /resource`
            创建新资源。

            **请求体：**
            ```json
            {
              "name": "New Resource",
              "description": "Details about the resource"
            }
            ```

            **响应（201 Created）：**
            ```json
            {
              "id": "def456",
              "name": "New Resource",
              "created_at": "2025-01-01T00:00:00Z"
            }
            ```

            ---

            ### 错误码

            | 错误码 | 信息 | 说明 |
            |------|---------|-------------|
            | 400 | Bad Request | 参数无效 |
            | 401 | Unauthorized | 缺少令牌或令牌无效 |
            | 403 | Forbidden | 权限不足 |
            | 404 | Not Found | 资源不存在 |
            | 429 | Too Many Requests | 超出请求频率限制 |
            | 500 | Internal Server Error | 服务器内部异常 |

            ### 频率限制
            - **默认：** 每分钟 100 次请求
            - **已认证：** 每分钟 1000 次请求
            """,
            isBuiltIn: true
        )
    }

    private static func incidentReport() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000029")!,
            name: "事故报告",
            category: .engineering,
            icon: "exclamationmark.triangle",
            description: "事故报告，包含时间线、根本原因、影响和整改措施。",
            body: """
            ## 事故报告

            **事故标题：**
            **严重程度：** SEV-1 / SEV-2 / SEV-3 / SEV-4
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **持续时长：** 开始 — 结束（共 X 小时）
            **事故指挥官：**
            **状态：** 已解决 / 监控中 / 处理中

            ---

            ### 摘要
            简要描述事故、受影响范围以及业务影响。

            ---

            ### 时间线（均为 UTC 时间）

            | 时间 | 事件 |
            |------|-------|
            | HH:MM | 首次发现问题 / 触发告警 |
            | HH:MM | 宣布事故，团队集结 |
            | HH:MM | 定位根本原因 |
            | HH:MM | 部署修复 |
            | HH:MM | 服务恢复，事故解决 |

            ---

            ### 影响

            | 指标 | 数值 |
            |--------|-------|
            | 受影响用户 | |
            | 影响时长 | |
            | 收入影响 | $ |
            | 是否违反 SLA | 是 / 否 |

            ---

            ### 根本原因
            详细解释事故的起因。要深入分析促成因素，而不仅是触发点。

            ### 促成因素
            1.
            2.
            3.

            ---

            ### 做得好的地方
            -
            -

            ### 做得不好的地方
            -
            -

            ---

            ### 整改措施

            | 行动 | 负责人 | 优先级 | 截止日期 | 状态 |
            |--------|-------|----------|----------|--------|
            | 立即修复 | | P0 | | 已完成 |
            | 防止再次发生 | | P1 | | 待处理 |
            | 改进监控发现 | | P2 | | 待处理 |
            | 更新操作手册 | | P2 | | 待处理 |

            ### 经验教训
            1.
            2.
            """,
            isBuiltIn: true
        )
    }

    // MARK: - HR & People

    private static func jobDescription() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000030")!,
            name: "职位描述",
            category: .hr,
            icon: "person.badge.plus",
            description: "职位描述，包含岗位概述、职责和任职要求。",
            body: """
            ## 职位描述

            **职位名称：**
            **所属部门：**
            **汇报对象：**
            **工作地点：** 远程 / 混合 / 现场办公
            **用工类型：** 全职 / 兼职 / 合同制
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))

            ---

            ### 关于我们
            简要的公司介绍和使命说明。

            ---

            ### 岗位概述
            用 2-3 句话描述这个岗位。这个人将做什么，为什么重要？

            ---

            ### 主要职责
            - 职责 1
            - 职责 2
            - 职责 3
            - 职责 4
            - 职责 5

            ---

            ### 任职要求
            - 在 [领域] 有 X 年以上经验
            - 熟练使用 [技能 / 工具]
            - 较强的 [软技能]
            - [领域] 学士学位或同等经验

            ### 加分项
            - 有 [具体技术或领域] 经验
            - 熟悉 [方法论或框架]
            - 持有 [相关领域] 认证

            ---

            ### 我们提供
            - 具有竞争力的薪资区间：$X — $Y
            - 医疗、牙科和视力保险
            - 带公司匹配的退休计划
            - 职业发展预算
            - 弹性工作安排
            - 带薪休假

            ---

            ### 申请方式
            请提交简历，并附一封简短的求职信，说明你为什么适合这个岗位。

            **申请截止日期：**
            **联系人：**

            *[公司名称] 是平等机会雇主。*
            """,
            isBuiltIn: true
        )
    }

    private static func performanceReview() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000031")!,
            name: "绩效评估",
            category: .hr,
            icon: "star",
            description: "绩效评估，涵盖目标完成情况、优势和发展方向。",
            body: """
            ## 绩效评估

            **员工：**
            **职位：**
            **主管：**
            **评估周期：**
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))

            ---

            ### 目标完成情况

            | 目标 | 目标值 | 结果 | 评级 |
            |------|--------|--------|--------|
            |      |        |        | 超出 / 达成 / 未达 |
            |      |        |        | 超出 / 达成 / 未达 |
            |      |        |        | 超出 / 达成 / 未达 |

            **总体目标评级：** 超出预期 / 达到预期 / 低于预期

            ---

            ### 核心能力

            | 能力项 | 评分（1-5） | 评语 |
            |-----------|-------------|----------|
            | 技术能力 | | |
            | 沟通能力 | | |
            | 协作能力 | | |
            | 问题解决 | | |
            | 领导力 | | |
            | 主动性 | | |

            ---

            ### 优势
            -
            -
            -

            ### 待发展领域
            -
            -
            -

            ---

            ### 关键成果
            突出评估周期内的显著成就。
            1.
            2.
            3.

            ### 同事反馈
            收到的同事反馈摘要。

            ---

            ### 发展计划

            | 技能 / 领域 | 行动 | 时间安排 | 所需支持 |
            |-------------|--------|----------|---------------|
            |             |        |          |               |
            |             |        |          |               |

            ### 下一周期目标
            1.
            2.
            3.

            ---

            ### 总体评级
            **评级：** 卓越 / 超出预期 / 达到预期 / 有待改进

            **员工签名：** _______________  **日期：**
            **主管签名：** _______________  **日期：**
            """,
            isBuiltIn: true
        )
    }

    private static func onboardingChecklist() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000032")!,
            name: "入职清单",
            category: .hr,
            icon: "checklist",
            description: "新员工入职清单，包含第 1 天、第 1 周和第 1 个月的任务。",
            body: """
            ## 入职清单

            **新员工：**
            **入职日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **职位：**
            **主管：**
            **伙伴 / 导师：**

            ---

            ### 入职前（第 1 天之前）
            - [ ] 发送欢迎邮件并说明入职安排
            - [ ] 准备工位 / 寄送设备
            - [ ] 创建邮箱和账号
            - [ ] 加入团队沟通频道（Slack、Teams 等）
            - [ ] 制定入职日程
            - [ ] 指定伙伴 / 导师

            ---

            ### 第 1 天
            - [ ] 与主管的欢迎会议
            - [ ] 参观办公室 / 线上工作区导览
            - [ ] IT 配置：笔记本电脑、VPN、密码
            - [ ] 阅读员工手册和制度
            - [ ] 完成人事手续和福利登记
            - [ ] 与直属团队见面
            - [ ] 配置开发环境（如为工程岗位）
            - [ ] 与伙伴共进第一顿午餐

            ---

            ### 第 1 周
            - [ ] 参加团队站会和例行会议
            - [ ] 阅读团队文档和知识库
            - [ ] 完成必修的合规培训
            - [ ] 与主管一对一 — 明确初期期望
            - [ ] 与跨职能利益相关方会面
            - [ ] 开始第一个小任务或项目
            - [ ] 周末与主管沟通进展

            ---

            ### 第 1 个月
            - [ ] 完成所有入职培训模块
            - [ ] 产出第一份有价值的成果
            - [ ] 参加公司全员会
            - [ ] 与主管制定 30/60/90 天目标
            - [ ] 与关键协作者安排一对一沟通
            - [ ] 反馈入职体验
            - [ ] 与主管和人事进行 30 天沟通

            ---

            ### 前 90 天
            - [ ] 与主管完成 90 天评估
            - [ ] 展现核心职责的胜任能力
            - [ ] 在组织内建立合作关系
            - [ ] 明确成长与发展方向

            ### 备注
            -
            """,
            isBuiltIn: true
        )
    }

    private static func interviewScorecard() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000033")!,
            name: "面试评分表",
            category: .hr,
            icon: "list.number",
            description: "面试评分表，包含能力评分和结构化记录。",
            body: """
            ## 面试评分表

            **候选人：**
            **应聘职位：**
            **面试官：**
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **面试阶段：** 电话初筛 / 技术面 / 行为面 / 终面

            ---

            ### 评分标准
            - **1** — 不符合要求
            - **2** — 部分符合要求
            - **3** — 符合要求
            - **4** — 超出要求
            - **5** — 显著超出要求

            ---

            ### 能力评估

            | 能力项 | 评分（1-5） | 记录 / 依据 |
            |-----------|-------------|-----------------|
            | 技术能力 | | |
            | 问题解决 | | |
            | 沟通能力 | | |
            | 协作 / 团队合作 | | |
            | 领导潜力 | | |
            | 文化契合 / 价值观一致 | | |
            | 领域知识 | | |
            | 适应能力 | | |

            ---

            ### 主要提问
            1. **问题：** — **回答摘要：**
            2. **问题：** — **回答摘要：**
            3. **问题：** — **回答摘要：**

            ---

            ### 观察到的优势
            -
            -
            -

            ### 疑虑或风险信号
            -
            -

            ---

            ### 总体评价
            **评级：** 强烈推荐录用 / 推荐录用 / 不推荐录用 / 明确不录用

            ### 建议
            简要说明你的建议及任何附加条件。

            ### 补充记录
            -
            """,
            isBuiltIn: true
        )
    }

    private static func teamCharter() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000034")!,
            name: "团队章程",
            category: .hr,
            icon: "flag",
            description: "团队章程，明确使命、价值观、角色和工作约定。",
            body: """
            ## 团队章程

            **团队名称：**
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **团队负责人：**

            ---

            ### 使命宣言
            这个团队为何存在？我们的目的是什么？

            > 我们的使命是……

            ---

            ### 团队价值观
            1. **价值观 1** — 在实践中意味着什么
            2. **价值观 2** — 在实践中意味着什么
            3. **价值观 3** — 在实践中意味着什么

            ---

            ### 团队成员与角色

            | 姓名 | 角色 | 主要职责 |
            |------|------|---------------------|
            |      |      |                     |
            |      |      |                     |
            |      |      |                     |
            |      |      |                     |

            ---

            ### 目标与成功指标

            | 目标 | 指标 | 目标值 |
            |------|--------|--------|
            |      |        |        |
            |      |        |        |

            ---

            ### 工作约定

            **沟通：**
            - 主要渠道：Slack / Teams / 邮件
            - 响应时间要求：X 小时内
            - 升级路径：

            **会议：**
            - 站会：[星期/时间]
            - 规划会：[星期/时间]
            - 回顾会：[星期/时间]

            **决策方式：**
            - 方式：共识 / 多数表决 / 负责人决定
            - 升级：何时以及如何升级

            **工作时段：**
            - 核心工作时段：X — Y
            - 弹性安排：

            ---

            ### 冲突解决
            我们如何处理分歧：
            1. 直接与当事人沟通
            2. 引入中立调解人
            3. 上报给团队负责人

            ### 我们如何庆祝成果
            -

            ### 章程回顾
            本章程将每 [季度 / 6 个月] 回顾并更新一次。
            """,
            isBuiltIn: true
        )
    }

    // MARK: - Finance

    private static func budgetProposal() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000035")!,
            name: "预算提案",
            category: .finance,
            icon: "dollarsign.circle",
            description: "预算提案，包含分项明细、理由说明和预期投资回报。",
            body: """
            ## 预算提案

            **部门 / 项目：**
            **财政周期：**
            **编制人：**
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **需审批人：**

            ---

            ### 执行摘要
            简要说明本预算涵盖的内容及其必要性。

            ---

            ### 预算概览

            | 类别 | 说明 | 金额 |
            |----------|-------------|--------|
            | 人力 | 薪资、外包人员 | $ |
            | 软件与工具 | 许可、订阅 | $ |
            | 硬件 | 设备、基础设施 | $ |
            | 市场营销 | 推广活动、展会 | $ |
            | 培训 | 职业发展 | $ |
            | 差旅 | 会议、客户拜访 | $ |
            | 预备金 | 意外支出（10%） | $ |
            | **合计** | | **$** |

            ---

            ### 明细项目

            #### 人力
            | 项目 | 数量 | 单价 | 合计 | 理由 |
            |------|----------|-----------|-------|--------------|
            |      |          | $         | $     |              |
            |      |          | $         | $     |              |

            #### 软件与工具
            | 项目 | 数量 | 单价 | 合计 | 理由 |
            |------|----------|-----------|-------|--------------|
            |      |          | $         | $     |              |
            |      |          | $         | $     |              |

            ---

            ### 与上一周期对比

            | 类别 | 上期 | 本次提案 | 变化（%） |
            |----------|----------|----------|-----------|
            |          | $        | $        |           |
            |          | $        | $        |           |

            ---

            ### 预期投资回报
            - 预期收入 / 节省：$
            - 投入：$
            - 投资回报率：X%
            - 投资回收期：

            ### 未获批准的风险
            -
            -

            ### 审批
            - [ ] 部门负责人
            - [ ] 财务审核
            - [ ] 高管审批
            """,
            isBuiltIn: true
        )
    }

    private static func expenseReport() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000036")!,
            name: "费用报销单",
            category: .finance,
            icon: "receipt",
            description: "逐项列明的费用报销单，包含分类和审批记录。",
            body: """
            ## 费用报销单

            **员工：**
            **部门：**
            **报销周期：**
            **提交日期：** \(Date.now.formatted(date: .long, time: .omitted))

            ---

            ### 汇总

            | 类别 | 合计 |
            |----------|-------|
            | 差旅 | $ |
            | 餐饮与招待 | $ |
            | 住宿 | $ |
            | 交通 | $ |
            | 办公用品 | $ |
            | 其他 | $ |
            | **总计** | **$** |

            ---

            ### 费用明细

            | 日期 | 说明 | 类别 | 供应商 | 金额 | 收据 |
            |------|-------------|----------|--------|--------|---------|
            |      |             |          |        | $      | 是/否  |
            |      |             |          |        | $      | 是/否  |
            |      |             |          |        | $      | 是/否  |
            |      |             |          |        | $      | 是/否  |
            |      |             |          |        | $      | 是/否  |

            ---

            ### 业务用途
            说明这些费用的业务用途。

            ### 备注
            针对具体费用项的补充说明。

            ---

            ### 审批

            | 角色 | 姓名 | 签名 | 日期 |
            |------|------|-----------|------|
            | 员工 | | | |
            | 主管 | | | |
            | 财务 | | | |

            ### 支付方式
            - [ ] 公司卡
            - [ ] 个人卡（报销）
            - [ ] 现金预支

            ### 附件
            - [ ] 已附全部收据
            - [ ] 里程记录（如适用）
            """,
            isBuiltIn: true
        )
    }

    private static func investmentMemo() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000037")!,
            name: "投资备忘录",
            category: .finance,
            icon: "banknote",
            description: "投资备忘录，涵盖市场机会、财务数据和风险评估。",
            body: """
            ## 投资备忘录

            **公司 / 投资机会：**
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **编制人：**
            **投资阶段：** 种子轮 / A 轮 / B 轮 / 成长期

            ---

            ### 执行摘要
            投资机会的简要概述与投资建议。

            ---

            ### 公司概况
            - **成立时间：**
            - **总部：**
            - **团队规模：**
            - **产品 / 服务：**
            - **商业模式：**

            ---

            ### 市场机会
            - **总潜在市场（TAM）：** $
            - **可服务市场（SAM）：** $
            - **当前市场份额：**
            - **增长率：**

            ### 竞争格局

            | 竞争对手 | 阶段 | 融资 | 差异点 |
            |-----------|-------|---------|----------------|
            |           |       | $       |                |
            |           |       | $       |                |

            ---

            ### 财务概览

            | 指标 | 当前 | 预测（12 个月） | 预测（24 个月） |
            |--------|---------|-------------------|-------------------|
            | 收入 | $ | $ | $ |
            | 资金消耗速度 | $/月 | $/月 | $/月 |
            | 毛利率 | % | % | % |
            | 客户数 | | | |

            ---

            ### 投资条款
            - **金额：** $
            - **估值：** $
            - **投资工具：** SAFE / 可转债 / 定价轮
            - **关键条款：**

            ---

            ### 风险评估

            | 风险 | 可能性 | 影响 | 应对措施 |
            |------|-----------|--------|------------|
            | 市场风险 | | | |
            | 执行风险 | | | |
            | 竞争风险 | | | |
            | 监管风险 | | | |

            ### 机会的优势
            -
            -

            ### 顾虑
            -
            -

            ---

            ### 投资建议
            **投资 / 放弃 / 进一步尽调**

            建议理由。
            """,
            isBuiltIn: true
        )
    }

    // MARK: - Academic

    private static func lectureNotes() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000038")!,
            name: "课堂笔记",
            category: .academic,
            icon: "graduationcap",
            description: "课堂笔记，包含主题概览、核心概念、示例和问题。",
            body: """
            ## 课堂笔记

            **课程：**
            **课次：**
            **主题：**
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **讲师：**

            ---

            ### 概览
            简要概述本节课的内容及其与前面内容的联系。

            ---

            ### 核心概念

            #### 概念 1：[名称]
            - 定义：
            - 解释：
            - 为什么重要：

            #### 概念 2：[名称]
            - 定义：
            - 解释：
            - 为什么重要：

            #### 概念 3：[名称]
            - 定义：
            - 解释：
            - 为什么重要：

            ---

            ### 示例

            **示例 1：**
            - 问题：
            - 解答：

            **示例 2：**
            - 问题：
            - 解答：

            ---

            ### 重要公式 / 定义

            | 术语 / 公式 | 定义 / 解释 |
            |---------------|------------------------|
            |               |                        |
            |               |                        |
            |               |                        |

            ---

            ### 图示与可视化
            画出或描述课堂上的关键图示。

            ### 与其他主题的联系
            - 与 [上次课程主题] 相关：
            - 为 [后续主题] 打下基础：

            ---

            ### 复习问题
            1.
            2.
            3.

            ### 阅读 / 作业
            - [ ] 教材章节：
            - [ ] 习题集：
            - [ ] 拓展阅读：
            """,
            isBuiltIn: true
        )
    }

    private static func researchPaperOutline() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000039")!,
            name: "研究论文大纲",
            category: .academic,
            icon: "doc.text.magnifyingglass",
            description: "研究论文大纲，包含摘要、研究方法、结果和参考文献。",
            body: """
            ## 研究论文大纲

            **标题：**
            **作者：**
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **课程 / 期刊：**
            **指导教师：**

            ---

            ### 摘要
            150-250 字的概述，涵盖研究目的、方法、主要发现和结论。

            ---

            ### 1. 引言
            - 背景与情境
            - 问题陈述
            - 研究问题
            - 研究意义
            - 论点陈述

            ---

            ### 2. 文献综述
            - **主题 1：** 现有研究综述
            - **主题 2：** 现有研究综述
            - **主题 3：** 现有研究综述
            - 现有文献的空白
            - 本文如何填补这些空白

            ---

            ### 3. 研究方法
            - **研究设计：** 定性 / 定量 / 混合
            - **参与者 / 样本：**
            - **数据收集方法：**
            - **数据分析方法：**
            - **研究局限：**

            ---

            ### 4. 研究结果
            - **发现 1：** 说明及支撑数据
            - **发现 2：** 说明及支撑数据
            - **发现 3：** 说明及支撑数据
            - 需包含的图表

            ---

            ### 5. 讨论
            - 结果解读
            - 与现有文献的比较
            - 研究启示
            - 研究局限
            - 未来研究方向

            ---

            ### 6. 结论
            - 主要发现总结
            - 对领域的贡献
            - 总结思考

            ---

            ### 参考文献
            1.
            2.
            3.

            ### 附录
            - 补充数据
            - 调查问卷
            - 补充表格
            """,
            isBuiltIn: true
        )
    }

    private static func studyGuide() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000040")!,
            name: "学习指南",
            category: .academic,
            icon: "book",
            description: "学习指南，包含主题、关键术语、总结和练习题。",
            body: """
            ## 学习指南

            **课程：**
            **考试：**
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **涵盖章节 / 主题：**

            ---

            ### 主题 1：[名称]

            **关键术语：**
            | 术语 | 定义 |
            |------|-----------|
            |      |           |
            |      |           |
            |      |           |

            **总结：**
            用自己的话概括主要观点和概念。

            **练习题：**
            1. 问题：
               答案：
            2. 问题：
               答案：

            ---

            ### 主题 2：[名称]

            **关键术语：**
            | 术语 | 定义 |
            |------|-----------|
            |      |           |
            |      |           |

            **总结：**
            用自己的话概括主要观点和概念。

            **练习题：**
            1. 问题：
               答案：
            2. 问题：
               答案：

            ---

            ### 主题 3：[名称]

            **关键术语：**
            | 术语 | 定义 |
            |------|-----------|
            |      |           |
            |      |           |

            **总结：**
            用自己的话概括主要观点和概念。

            **练习题：**
            1. 问题：
               答案：

            ---

            ### 重要公式 / 定理
            -
            -
            -

            ### 常见错误
            -
            -

            ### 复习清单
            - [ ] 复习全部课堂笔记
            - [ ] 完成练习题
            - [ ] 复习关键术语和定义
            - [ ] 重做课后作业题
            - [ ] 组织学习小组
            - [ ] 保证充足睡眠
            """,
            isBuiltIn: true
        )
    }

    private static func essayOutline() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000041")!,
            name: "文章大纲",
            category: .academic,
            icon: "text.alignleft",
            description: "文章大纲，包含论点、支撑论据和结论。",
            body: """
            ## 文章大纲

            **标题：**
            **作者：**
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **课程：**
            **目标字数：**

            ---

            ### 一、引言
            - **引子：** 吸引读者注意的开篇语句
            - **背景：** 读者需要了解的背景信息
            - **论点陈述：** 你的主要论点或主张

            > 论点：[在此写明你的论点]

            ---

            ### 二、正文第 1 段
            - **主题句：** 支撑论点的第一个要点
            - **论据：** 引文、数据或例子
            - **分析：** 说明论据如何支撑该要点
            - **过渡：** 衔接到下一段

            ---

            ### 三、正文第 2 段
            - **主题句：** 支撑论点的第二个要点
            - **论据：** 引文、数据或例子
            - **分析：** 说明论据如何支撑该要点
            - **过渡：** 衔接到下一段

            ---

            ### 四、正文第 3 段
            - **主题句：** 支撑论点的第三个要点
            - **论据：** 引文、数据或例子
            - **分析：** 说明论据如何支撑该要点
            - **过渡：** 引出结论

            ---

            ### 五、反方观点（可选）
            - **对立观点：** 给出最有力的反方论证
            - **反驳：** 说明你的立场为何更有力

            ---

            ### 六、结论
            - **重申论点：** 结合所列论据重新表述
            - **总结要点：** 简要回顾主要论点
            - **结尾思考：** 更广泛的意义或行动号召

            ---

            ### 来源
            1.
            2.
            3.

            ### 写作检查清单
            - [ ] 论点明确有力
            - [ ] 每段都有论据支撑
            - [ ] 过渡自然顺畅
            - [ ] 检查语法与表达清晰度
            """,
            isBuiltIn: true
        )
    }

    private static func labReport() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000042")!,
            name: "实验报告",
            category: .academic,
            icon: "flask",
            description: "实验报告，包含假设、步骤、数据、分析和结论。",
            body: """
            ## 实验报告

            **实验名称：**
            **课程：**
            **学生：**
            **实验伙伴：**
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **指导教师：**

            ---

            ### 实验目的
            说明本次实验的目的。

            ### 假设
            如果 [改变自变量]，那么 [因变量将……]，因为 [推理]。

            ---

            ### 实验材料
            -
            -
            -
            -

            ---

            ### 实验步骤
            1. 第一步
            2. 第二步
            3. 第三步
            4. 第四步
            5. 第五步

            ---

            ### 实验数据

            | 试验次数 | 变量 1 | 变量 2 | 观察结果 |
            |-------|-----------|-----------|-------------|
            | 1     |           |           |             |
            | 2     |           |           |             |
            | 3     |           |           |             |
            | 4     |           |           |             |
            | 5     |           |           |             |

            ### 计算过程
            列出处理数据所用的关键计算。

            ---

            ### 数据分析
            - 数据中呈现出哪些规律或趋势？
            - 结果支持还是否证了假设？
            - 百分比误差或不确定度是多少？

            ---

            ### 讨论
            - 结合理论解读结果
            - 误差来源及其对结果的影响
            - 实验可以如何改进？

            ---

            ### 结论
            总结发现。假设是否成立？学到了什么？

            ### 参考文献
            1.
            2.
            """,
            isBuiltIn: true
        )
    }

    private static func readingNotes() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000043")!,
            name: "阅读笔记",
            category: .academic,
            icon: "bookmark",
            description: "阅读笔记，包含摘要、关键引文、分析和讨论问题。",
            body: """
            ## 阅读笔记

            **标题：**
            **作者：**
            **阅读日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **课程 / 背景：**
            **页码 / 章节：**

            ---

            ### 摘要
            简明概括主要论点或叙事内容。

            ---

            ### 核心主题
            1. **主题 1：** 说明
            2. **主题 2：** 说明
            3. **主题 3：** 说明

            ---

            ### 关键引文

            > “文中的引文”（第 X 页）
            - **为什么重要：**

            > “文中的引文”（第 X 页）
            - **为什么重要：**

            > “文中的引文”（第 X 页）
            - **为什么重要：**

            ---

            ### 重要术语 / 概念

            | 术语 | 定义 / 背景 |
            |------|---------------------|
            |      |                     |
            |      |                     |
            |      |                     |

            ---

            ### 分析与感想
            - 哪些论证最有说服力？为什么？
            - 你对哪些观点不认同？为什么？
            - 这与其它阅读材料或概念有何联系？

            ---

            ### 关联
            - **与 [其它文本 / 概念] 相关：**
            - **建立在 [此前阅读] 之上：**
            - **与 [其他来源] 相矛盾：**

            ### 讨论问题
            1.
            2.
            3.

            ### 词汇
            - 词语：
            - 词语：
            """,
            isBuiltIn: true
        )
    }

    private static func groupProjectPlan() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000044")!,
            name: "小组项目计划",
            category: .academic,
            icon: "person.3",
            description: "小组项目计划，包含成员分工、截止时间和协作约定。",
            body: """
            ## 小组项目计划

            **项目名称：**
            **课程：**
            **截止日期：**
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))

            ---

            ### 小组成员

            | 姓名 | 角色 | 联系方式 | 优势 |
            |------|------|---------|-----------|
            |      | 组长 |         |           |
            |      | 调研 |  |           |
            |      | 撰稿 |     |           |
            |      | 编辑 |     |           |

            ---

            ### 项目概览
            简要描述作业要求与交付物。

            ### 项目目标
            1.
            2.
            3.

            ---

            ### 任务分解

            | 任务 | 负责人 | 开始 | 截止 | 状态 |
            |------|----------|-------|-----|--------|
            | 资料调研 |  |  |  | 未开始 |
            | 大纲 |  |  |  | 未开始 |
            | 撰写第 1 部分 |  |  |  | 未开始 |
            | 撰写第 2 部分 |  |  |  | 未开始 |
            | 撰写第 3 部分 |  |  |  | 未开始 |
            | 汇总与编辑 |  |  |  | 未开始 |
            | 最终审阅 |  |  |  | 未开始 |
            | 提交 |  |  |  | 未开始 |

            ---

            ### 沟通计划
            - **主要工具：** Slack / Discord / 群聊
            - **会议安排：** 每周 [星期] [时间]
            - **文件共享：** Google Drive / Dropbox / GitHub

            ---

            ### 基本约定
            - 24 小时内回复消息
            - 无法按期完成时立即通知小组
            - 建设性地审阅彼此的成果
            - 参加所有既定会议，否则提前告知

            ---

            ### 里程碑
            - [ ] 调研完成 — [日期]
            - [ ] 完成初稿 — [日期]
            - [ ] 同伴互评 — [日期]
            - [ ] 最终提交 — [日期]

            ### 应急预案
            如有成员进度落后或退出，该如何处理。
            """,
            isBuiltIn: true
        )
    }

    private static func thesisOutline() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000045")!,
            name: "学位论文大纲",
            category: .academic,
            icon: "text.book.closed",
            description: "学位论文大纲，包含章节、文献综述、研究方法和时间安排。",
            body: """
            ## 学位论文大纲

            **标题：**
            **作者：**
            **学位：** 文学硕士 / 理学硕士 / 博士
            **院系：**
            **指导教师：**
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))

            ---

            ### 研究问题
            写出论文要解决的核心问题。

            ### 论点陈述
            你的主要论点或假设。

            ---

            ### 第 1 章：引言
            - 背景与动机
            - 问题陈述
            - 研究目标
            - 范围与局限
            - 论文结构

            ---

            ### 第 2 章：文献综述
            - **2.1 节：** 历史背景与基础研究
            - **2.2 节：** 当前研究现状
            - **2.3 节：** 文献中的空白
            - **2.4 节：** 理论框架

            ---

            ### 第 3 章：研究方法
            - 研究设计
            - 数据来源与收集
            - 分析方法
            - 伦理考量
            - 效度与信度

            ---

            ### 第 4 章：研究结果 / 发现
            - 数据呈现
            - 按研究问题组织的关键发现
            - 图表

            ---

            ### 第 5 章：讨论
            - 发现解读
            - 与现有文献的比较
            - 启示（理论与实践）
            - 研究局限

            ---

            ### 第 6 章：结论
            - 贡献总结
            - 建议
            - 未来研究方向

            ---

            ### 时间安排

            | 阶段 | 开始 | 结束 | 状态 |
            |-------|-------|-----|--------|
            | 文献综述 | | | |
            | 研究设计 | | | |
            | 数据收集 | | | |
            | 数据分析 | | | |
            | 论文撰写 | | | |
            | 评审与修订 | | | |
            | 答辩 | | | |

            ### 参考文献
            在此开始整理参考文献。
            1.
            2.
            3.
            """,
            isBuiltIn: true
        )
    }

    // MARK: - Personal

    private static func weeklyPlanner() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000046")!,
            name: "每周计划",
            category: .personal,
            icon: "calendar",
            description: "每周计划，包含重点事项、每日任务和周末复盘。",
            body: """
            ## 每周计划

            **本周起始：** \(Date.now.formatted(date: .long, time: .omitted))

            ---

            ### 本周重点
            1.
            2.
            3.

            ---

            ### 周一
            - [ ] 任务
            - [ ] 任务
            - [ ] 任务

            ### 周二
            - [ ] 任务
            - [ ] 任务
            - [ ] 任务

            ### 周三
            - [ ] 任务
            - [ ] 任务
            - [ ] 任务

            ### 周四
            - [ ] 任务
            - [ ] 任务
            - [ ] 任务

            ### 周五
            - [ ] 任务
            - [ ] 任务
            - [ ] 任务

            ### 周末
            - [ ] 个人事务
            - [ ] 个人事务

            ---

            ### 预约与约定

            | 星期 | 时间 | 事项 |
            |-----|------|-------|
            |     |      |       |
            |     |      |       |
            |     |      |       |

            ---

            ### 保持的习惯
            - [ ] 运动（本周 3 次）
            - [ ] 阅读（每天 30 分钟）
            - [ ] 冥想
            - [ ] 写日志

            ---

            ### 周末复盘
            **做得好的地方：**
            -

            **可以改进的地方：**
            -

            **顺延到下周：**
            -
            """,
            isBuiltIn: true
        )
    }

    private static func goalTracker() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000047")!,
            name: "目标追踪",
            category: .personal,
            icon: "target",
            description: "目标追踪，包含目标、关键结果和里程碑进度。",
            body: """
            ## 目标追踪

            **周期：** 第 [1-4] 季度 [年份]
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))

            ---

            ### 目标 1：[标题]

            **为什么重要：**

            **关键结果：**
            - [ ] KR 1：具体、可衡量的目标 — 进度：/
            - [ ] KR 2：具体、可衡量的目标 — 进度：/
            - [ ] KR 3：具体、可衡量的目标 — 进度：/

            **里程碑：**

            | 里程碑 | 目标日期 | 状态 |
            |-----------|-------------|--------|
            |           |             | 未开始 |
            |           |             | 未开始 |
            |           |             | 未开始 |

            ---

            ### 目标 2：[标题]

            **为什么重要：**

            **关键结果：**
            - [ ] KR 1：具体、可衡量的目标 — 进度：/
            - [ ] KR 2：具体、可衡量的目标 — 进度：/

            **里程碑：**

            | 里程碑 | 目标日期 | 状态 |
            |-----------|-------------|--------|
            |           |             | 未开始 |
            |           |             | 未开始 |

            ---

            ### 目标 3：[标题]

            **为什么重要：**

            **关键结果：**
            - [ ] KR 1：具体、可衡量的目标 — 进度：/
            - [ ] KR 2：具体、可衡量的目标 — 进度：/

            ---

            ### 月度回顾

            | 月份 | 目标 1 进度 | 目标 2 进度 | 目标 3 进度 | 备注 |
            |-------|----------------|----------------|----------------|-------|
            | 第 1 个月 | % | % | % | |
            | 第 2 个月 | % | % | % | |
            | 第 3 个月 | % | % | % | |

            ### 障碍与调整
            -
            -

            ### 反思
            -
            """,
            isBuiltIn: true
        )
    }

    private static func dailyJournal() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000048")!,
            name: "每日日志",
            category: .personal,
            icon: "book.closed",
            description: "每日日志，包含感恩、亮点和反思。",
            body: """
            ## 每日日志

            **日期：** \\(Date.now.formatted(date: .long, time: .omitted))

            ---

            ### 感恩
            今天让我心怀感激的三件事：
            1.
            2.
            3.

            ---

            ### 早晨意图
            今天我想完成什么，或专注于什么？
            -
            -
            -

            ### 今天我希望自己处于什么状态？


            ---

            ### 今日亮点
            今天最美好的时刻是什么？
            -
            -
            -

            ---

            ### 我的收获
            今天的新洞察、新想法或新经验。
            -

            ### 挑战
            今天有什么困难？我如何应对？
            -

            ---

            ### 晚间反思
            **今天哪些事情进展顺利？**
            -

            **哪些事情可以做得更好？**
            -

            **明天我要改变的一件事：**
            -

            ---

            ### 状态自评
            此刻的感受如何？（1-10）：

            ### 备注
            自由记录想法、灵感或任何在想的事情。
            """,
            isBuiltIn: true
        )
    }

    private static func decisionLog() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000049")!,
            name: "决策记录",
            category: .personal,
            icon: "arrow.triangle.branch",
            description: "决策记录，包含可选方案、优缺点和选择理由。",
            body: """
            ## 决策记录

            **日期：** \(Date.now.formatted(date: .long, time: .omitted))

            ---

            ### 决策 1：[标题]

            **背景：** 是什么促成了这个决定？

            **可选方案：**

            | 方案 | 优点 | 缺点 |
            |--------|------|------|
            | 方案 A | | |
            | 方案 B | | |
            | 方案 C | | |

            **决定：** 方案 [X]
            **理由：** 为什么选择该方案。
            **预期结果：**
            **复盘日期：** 何时评估该决定。

            ---

            ### 决策 2：[标题]

            **背景：** 是什么促成了这个决定？

            **可选方案：**

            | 方案 | 优点 | 缺点 |
            |--------|------|------|
            | 方案 A | | |
            | 方案 B | | |

            **决定：** 方案 [X]
            **理由：**
            **预期结果：**
            **复盘日期：**

            ---

            ### 决策 3：[标题]

            **背景：**

            **可选方案：**

            | 方案 | 优点 | 缺点 |
            |--------|------|------|
            | 方案 A | | |
            | 方案 B | | |

            **决定：** 方案 [X]
            **理由：**
            **预期结果：**
            **复盘日期：**

            ---

            ### 过往决策复盘

            | 决策 | 做出日期 | 结果 | 经验 |
            |----------|-----------|---------|---------|
            |          |           | 好 / 差 / 一般 |  |
            |          |           | 好 / 差 / 一般 |  |
            """,
            isBuiltIn: true
        )
    }

    private static func habitTracker() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000050")!,
            name: "习惯追踪",
            category: .personal,
            icon: "checkmark.circle",
            description: "每周习惯追踪，包含连续天数记录和反思。",
            body: """
            ## 习惯追踪

            **本周起始：** \(Date.now.formatted(date: .long, time: .omitted))

            ---

            ### 每周习惯

            | 习惯 | 周一 | 周二 | 周三 | 周四 | 周五 | 周六 | 周日 | 连续天数 |
            |-------|-----|-----|-----|-----|-----|-----|-----|--------|
            | 运动 | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | 天 |
            | 阅读 30 分钟 | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | 天 |
            | 冥想 | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | 天 |
            | 喝 8 杯水 | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | 天 |
            | 写日志 | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | 天 |
            | 中午前不刷社交媒体 | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | 天 |
            | 睡满 8 小时 | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | 天 |

            ---

            ### 习惯目标

            | 习惯 | 每周目标 | 实际 | 是否达标 |
            |-------|--------------|--------|-----------|
            | 运动 | 5 次 | | 是 / 否 |
            | 阅读 30 分钟 | 7 次 | | 是 / 否 |
            | 冥想 | 7 次 | | 是 / 否 |

            ---

            ### 每周反思

            **本周坚持得好的习惯：**
            -

            **本周坚持困难的习惯：**
            -

            **哪些因素让它变容易 / 变困难？**
            -

            **下周的调整：**
            -

            ---

            ### 月度概览

            | 周次 | 完成率 | 备注 |
            |------|----------------|-------|
            | 第 1 周 | % | |
            | 第 2 周 | % | |
            | 第 3 周 | % | |
            | 第 4 周 | % | |
            """,
            isBuiltIn: true
        )
    }

    private static func travelPlanner() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000051")!,
            name: "旅行计划",
            category: .personal,
            icon: "airplane",
            description: "旅行计划，包含行程、行李清单、预订信息和预算。",
            body: """
            ## 旅行计划

            **目的地：**
            **出行日期：** 出发 — 返回
            **同行人：**
            **计划创建日期：** \(Date.now.formatted(date: .long, time: .omitted))

            ---

            ### 预订信息

            | 项目 | 详情 | 确认号 | 费用 |
            |------|---------|---------------|------|
            | 去程航班 | | | $ |
            | 返程航班 | | | $ |
            | 酒店 / 住宿 | | | $ |
            | 租车 | | | $ |
            | 旅行保险 | | | $ |

            ---

            ### 行程安排

            #### 第 1 天 — [日期]
            - **上午：**
            - **下午：**
            - **晚上：**
            - **晚餐预订：**

            #### 第 2 天 — [日期]
            - **上午：**
            - **下午：**
            - **晚上：**

            #### 第 3 天 — [日期]
            - **上午：**
            - **下午：**
            - **晚上：**

            ---

            ### 预算

            | 类别 | 预算 | 实际 |
            |----------|----------|--------|
            | 机票 | $ | $ |
            | 住宿 | $ | $ |
            | 餐饮 | $ | $ |
            | 活动 | $ | $ |
            | 交通 | $ | $ |
            | 购物 | $ | $ |
            | **合计** | **$** | **$** |

            ---

            ### 行李清单

            **必需品：**
            - [ ] 护照 / 身份证件
            - [ ] 登机牌
            - [ ] 钱包 / 现金 / 银行卡
            - [ ] 手机 + 充电器
            - [ ] 药品

            **衣物：**
            - [ ] 上衣
            - [ ] 下装
            - [ ] 外套
            - [ ] 鞋子
            - [ ] 睡衣

            **洗漱用品：**
            - [ ] 牙刷 / 牙膏
            - [ ] 防晒霜
            - [ ] 个人护理用品

            ---

            ### 重要信息
            - **紧急联系人：**
            - **使领馆地址：**
            - **当地紧急电话：**
            - **WiFi / SIM 卡方案：**
            """,
            isBuiltIn: true
        )
    }

    private static func personalOKRs() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000052")!,
            name: "个人 OKR",
            category: .personal,
            icon: "scope",
            description: "季度个人目标与关键结果，帮助你聚焦目标设定。",
            body: """
            ## 个人 OKR

            **季度：** 第 [1-4] 季度 [年份]
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))

            ---

            ### 目标 1：[职业 / 专业]
            *我想达成的目标以及它的意义。*

            **关键结果：**
            - [ ] KR 1.1：[可衡量的结果] — 当前：/ 目标：
            - [ ] KR 1.2：[可衡量的结果] — 当前：/ 目标：
            - [ ] KR 1.3：[可衡量的结果] — 当前：/ 目标：

            **行动举措：**
            - 为推动 KR 1.1 将采取的行动
            - 为推动 KR 1.2 将采取的行动

            ---

            ### 目标 2：[健康 / 身心]
            *我想达成的目标以及它的意义。*

            **关键结果：**
            - [ ] KR 2.1：[可衡量的结果] — 当前：/ 目标：
            - [ ] KR 2.2：[可衡量的结果] — 当前：/ 目标：
            - [ ] KR 2.3：[可衡量的结果] — 当前：/ 目标：

            **行动举措：**
            -
            -

            ---

            ### 目标 3：[个人成长 / 人际关系]
            *我想达成的目标以及它的意义。*

            **关键结果：**
            - [ ] KR 3.1：[可衡量的结果] — 当前：/ 目标：
            - [ ] KR 3.2：[可衡量的结果] — 当前：/ 目标：

            **行动举措：**
            -
            -

            ---

            ### 评分说明
            - **0.0 – 0.3：** 没有实质进展
            - **0.4 – 0.6：** 有进展但未达标
            - **0.7 – 1.0：** 达成（0.7 已是好成绩）

            ### 季度末复盘

            | 目标 | KR 平均分 | 反思 |
            |-----------|-------------|------------|
            | 目标 1 | /1.0 | |
            | 目标 2 | /1.0 | |
            | 目标 3 | /1.0 | |

            ### 本季度的收获
            -

            ### 下季度的调整
            -
            """,
            isBuiltIn: true
        )
    }

    // MARK: - Communication

    private static func memo() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000053")!,
            name: "备忘录",
            category: .communication,
            icon: "envelope",
            description: "内部备忘录，采用标准的收件人、发件人、日期、主题和正文格式。",
            body: """
            ## 备忘录

            **收件人：**
            **发件人：**
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **主题：**

            ---

            ### 目的
            用一两句话说明本备忘录的缘由。

            ---

            ### 背景
            提供理解本备忘录所需的背景信息。发生了什么或有哪些变化促成了这次沟通？

            ---

            ### 要点

            1. **要点 1：** 说明及支撑细节
            2. **要点 2：** 说明及支撑细节
            3. **要点 3：** 说明及支撑细节

            ---

            ### 影响
            谁受影响，如何受影响？大家应预期哪些变化？

            ### 建议行动
            - [ ] 行动项 1
            - [ ] 行动项 2
            - [ ] 行动项 3

            ---

            ### 时间安排
            - **生效日期：**
            - **回复 / 行动截止日期：**

            ### 疑问或顾虑
            如有疑问，请联系 [姓名]（[邮箱 / 电话]）。

            ---

            *本备忘录为机密文件，仅供所列收件人查阅。*
            """,
            isBuiltIn: true
        )
    }

    private static func presentationOutline() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000054")!,
            name: "演示大纲",
            category: .communication,
            icon: "rectangle.on.rectangle.angled",
            description: "演示大纲，包含核心信息、幻灯片流程和演讲备注。",
            body: """
            ## 演示大纲

            **标题：**
            **演讲人：**
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **受众：**
            **时长：** X 分钟

            ---

            ### 目标
            本次演示结束后，受众应当知道什么、感受什么或采取什么行动？

            ### 核心信息
            最重要的单一要点。

            ---

            ### 幻灯片流程

            #### 幻灯片 1：封面页
            - 标题、副标题、演讲人姓名、日期

            #### 幻灯片 2：议程
            - 将涵盖的主题概览

            #### 幻灯片 3：问题 / 背景
            - **要点：**
            - **演讲备注：**

            #### 幻灯片 4：方案 / 提案
            - **要点：**
            - **演讲备注：**

            #### 幻灯片 5：依据 / 数据
            - **要点：**
            - **视觉素材：** 图表 / 图形 / 表格
            - **演讲备注：**

            #### 幻灯片 6：细节 / 深入展开
            - **要点：**
            - **演讲备注：**

            #### 幻灯片 7：时间线 / 下一步
            - **要点：**
            - **演讲备注：**

            #### 幻灯片 8：行动号召
            - **要点：**
            - **演讲备注：**

            #### 幻灯片 9：问答
            - 开放提问

            ---

            ### 设计说明
            - 配色方案：
            - 字体：
            - 图片风格：

            ### 准备清单
            - [ ] 完成所有幻灯片
            - [ ] 添加演讲备注
            - [ ] 完整演练（计时）
            - [ ] 测试音视频设备
            - [ ] 为演示 / 现场环节准备备份
            - [ ] 打印讲义（如需）
            """,
            isBuiltIn: true
        )
    }

    private static func newsletter() -> DocumentTemplate {
        DocumentTemplate(
            id: UUID(uuidString: "B0000001-0000-0000-0000-000000000055")!,
            name: "简报",
            category: .communication,
            icon: "tray.full",
            description: "简报模板，包含动态、亮点和行动号召。",
            body: """
            ## 简报

            **期号：** [年 月] / 第 # 期
            **日期：** \(Date.now.formatted(date: .long, time: .omitted))
            **作者：**

            ---

            ### 开篇语
            简短的开幕致辞，为本期定下基调。

            ---

            ### 头条：[标题]
            以最重要或最有趣的动态开篇。提供足够的细节吸引读者，并附上了解更多信息的链接。

            ---

            ### 动态与更新

            #### 动态 1：[标题]
            简要描述该动态。发生了什么、为什么重要、接下来会怎样。

            #### 动态 2：[标题]
            简要描述该动态。

            #### 动态 3：[标题]
            简要描述该动态。

            ---

            ### 亮点与成果
            - 值得庆祝的成果或里程碑
            - 表彰团队或个人的贡献
            - 有趣的指标或数据

            ---

            ### 即将举行的活动

            | 活动 | 日期 | 地点 | 详情 |
            |-------|------|----------|---------|
            |       |      |          |         |
            |       |      |          |         |

            ---

            ### 精选内容
            - **文章：** [标题及链接]
            - **视频：** [标题及链接]
            - **资源：** [标题及链接]

            ---

            ### 行动号召
            你希望读者接下来做什么？

            - [ ] 报名参加 [活动]
            - [ ] 阅读 [文章]
            - [ ] 通过 [链接] 反馈意见

            ---

            ### 联系我们
            - 官网：
            - 社交媒体：
            - 联系邮箱：

            *如需退订或修改订阅偏好，请点击 [此处]。*
            """,
            isBuiltIn: true
        )
    }
}

// swiftlint:enable file_length force_unwrapping function_body_length
