// swiftlint:disable file_length
import Foundation

// MARK: - Seed Data

// swiftlint:disable line_length function_body_length
extension DocumentStore {
    static func makeSeedDocuments() -> [WritingDocument] {
        let now = Date()
        let cal = Calendar.current

        /// Date helper — spread documents across the last week
        func daysAgo(_ days: Int, hour: Int = 10) -> Date {
            cal.date(byAdding: .hour, value: hour, to: cal.date(byAdding: .day, value: -days, to: cal.startOfDay(for: now)) ?? Date()) ?? Date()
        }

        return [
            makeDoc1(date: daysAgo(0, hour: 9)),
            makeDoc2(date: daysAgo(1, hour: 14)),
            makeDoc3(date: daysAgo(2, hour: 11)),
            makeDoc4(date: daysAgo(3, hour: 15)),
            makeDoc5(date: daysAgo(5, hour: 10)),
            makeDoc6(date: daysAgo(7, hour: 13)),
            makeDoc7(date: daysAgo(1, hour: 10)),
            makeDoc8(date: daysAgo(3, hour: 9)),
            makeDoc9(date: daysAgo(0, hour: 14)),
            makeDoc10(date: daysAgo(2, hour: 16)),
        ]
    }

    // MARK: - Doc 1: Q3 Campaign Brief

    private static func makeDoc1(date: Date) -> WritingDocument {
        var doc = WritingDocument()
        doc.title = "Q3 营销活动简报"
        doc.goalMode = .business
        doc.tags = ["市场营销", "Q3"]
        doc.spaceID = SeedSpaceID.clientProjects
        doc.isPinned = true
        doc.createdAt = date
        doc.modifiedAt = date
        doc.score = WritingScore(overall: 88, correctness: 91, clarity: 85, engagement: 84, delivery: 90)
        doc.body = """
        # Q3 营销活动简报 — Acme Corp

        ## 概览

        本文档阐述 Acme Corp 第三季度产品发布的战略营销活动。活动横跨 7 月至 9 月，面向现有客户以及中大型企业市场中的新细分客户。

        ## 目标

        - **主要目标：** 在 Q3 结束前为新的 Analytics Pro 档位带来 2,500 条合格线索
        - **次要目标：** 将开发者工具品类中的品牌知名度提升 30%
        - **第三目标：** 所有付费渠道实现 4:1 的广告支出回报率

        ## 目标受众

        我们的主要受众是员工规模 200–2,000 人的公司中的工程经理和技术总监。次要受众包括在其组织内影响采购决策的独立开发者。

        **关键人物画像：**
        - *决策者 Dana* — 工程副总裁，掌握预算，关注 ROI 与团队效率
        - *评估者 Eric* — 高级工程师，动手测试者，重视文档与 API 质量

        ## 核心信息

        活动围绕主题 **“更快构建，更聪明地交付。”** 核心信息包括：

        1. 与旧工具相比，Analytics Pro 将调试时间缩短 40%
        2. 与现有 CI/CD 流水线无缝集成——10 分钟内完成设置
        3. 企业级安全，符合 SOC 2 Type II

        ## 时间线

        | 阶段 | 日期 | 重点 |
        |-------|-------|-------|
        | 预热期 | 7 月 1–14 日 | 悬念内容、意见领袖种子投放 |
        | 发布期 | 7 月 15–31 日 | 产品公告、媒体沟通 |
        | 持续期 | 8 月 1 日–9 月 15 日 | 付费媒体、网络研讨会、案例研究 |
        | 收尾期 | 9 月 16–30 日 | 再营销、促销优惠 |

        ## 预算概览

        总预算：**185,000 美元**

        - 付费媒体（Google、LinkedIn）：78,000 美元（42%）
        - 内容制作：35,000 美元（19%）
        - 活动与网络研讨会：28,000 美元（15%）
        - 意见领袖合作：24,000 美元（13%）
        - 应急储备：20,000 美元（11%）

        ## 成功指标

        我们将每周跟踪仪表盘，涵盖线索量、每条线索成本、各漏斗阶段的转化率以及管道归因。8 月 8 日安排一次活动中期复盘，评估表现并在需要时重新分配预算。
        """
        return doc
    }

    // MARK: - Doc 2: Weekly Status Update

    private static func makeDoc2(date: Date) -> WritingDocument {
        var doc = WritingDocument()
        doc.title = "每周状态更新"
        doc.goalMode = .casual
        doc.tags = ["状态", "每周"]
        doc.spaceID = SeedSpaceID.internal
        doc.isPinned = false
        doc.createdAt = date
        doc.modifiedAt = date
        doc.score = WritingScore(overall: 79, correctness: 83, clarity: 80, engagement: 72, delivery: 78)
        doc.body = """
        # 每周状态更新 — 3 月 10–14 日

        ## 已完成

        - 完成新用户引导流程改版，并移交工程团队实现
        - 为 Q3 营销活动管道发布了两篇博客文章（均安排在下周）
        - 完成用户访谈——共 8 场，综合文档已分享至 #research
        - 修复了定价页面上损坏的分析事件（此前导致 15% 的漏计）

        ## 进行中

        - **仪表盘迁移：** 将旧图表迁移到新组件库。已完成约 60%，目标周三前完成
        - **API 文档重写：** 覆盖身份验证和 Webhook 章节。初稿已提交评审
        - **招聘：** 高级前端岗位的电话初筛——3 位候选人进入下一轮

        ## 阻碍

        - 等待法务审阅更新后的服务条款，之后才能上线数据导出功能。周四已跟进，预计周一收到回复
        - 自基础设施迁移以来，预发环境一直不稳定。已向平台团队提交工单，但尚无预计时间

        ## 备注

        - 周三下午因牙医预约不在办公室
        - 提醒：团队回顾会周四下午 2 点，请提前在共享看板上添加议题
        """
        return doc
    }

    // MARK: - Doc 3: CS 301 — Lecture Notes: Graphs

    private static func makeDoc3(date: Date) -> WritingDocument {
        var doc = WritingDocument()
        doc.title = "CS 301 — 课堂笔记：图"
        doc.goalMode = .academic
        doc.tags = ["课堂", "算法"]
        doc.spaceID = SeedSpaceID.cs301
        doc.isPinned = false
        doc.createdAt = date
        doc.modifiedAt = date
        doc.score = WritingScore(overall: 85, correctness: 92, clarity: 82, engagement: 78, delivery: 86)
        doc.body = """
        # 图算法 — 第 12 讲

        ## 图的表示

        图可以存储为 **邻接矩阵**（O(V²) 空间，O(1) 边查询）或 **邻接表**（O(V + E) 空间，O(度数) 边查询）。对于稀疏图，几乎总是优先使用邻接表。

        ## 广度优先搜索（BFS）

        BFS 逐层探索顶点，因此非常适合在无权图中寻找最短路径。

        ```
        BFS(G, s):
            for each vertex u in V - {s}:
                u.color = WHITE, u.d = INF, u.parent = NIL
            s.color = GRAY, s.d = 0, s.parent = NIL
            Q = empty queue
            ENQUEUE(Q, s)
            while Q is not empty:
                u = DEQUEUE(Q)
                for each v in Adj[u]:
                    if v.color == WHITE:
                        v.color = GRAY, v.d = u.d + 1, v.parent = u
                        ENQUEUE(Q, v)
                u.color = BLACK
        ```

        **复杂度：** O(V + E) 时间，队列和已访问集合占用 O(V) 空间。

        ## 深度优先搜索（DFS）

        DFS 沿每条分支尽可能深入，然后回溯。它自然产生 DFS 森林，并记录发现/完成时间戳，可用于拓扑排序。

        ```
        DFS(G):
            for each vertex u in V:
                u.color = WHITE, u.parent = NIL
            time = 0
            for each vertex u in V:
                if u.color == WHITE:
                    DFS-VISIT(G, u)

        DFS-VISIT(G, u):
            time = time + 1, u.d = time, u.color = GRAY
            for each v in Adj[u]:
                if v.color == WHITE:
                    v.parent = u
                    DFS-VISIT(G, v)
            u.color = BLACK, time = time + 1, u.f = time
        ```

        **复杂度：** O(V + E) 时间，O(V) 空间（最坏情况下的递归栈）。

        ## 最短路径 — Dijkstra 算法

        对于 **边权非负** 的图，Dijkstra 算法使用优先队列求解单源最短路径。

        ```
        DIJKSTRA(G, w, s):
            INITIALIZE-SINGLE-SOURCE(G, s)
            S = empty set
            Q = min-priority queue of V keyed by d
            while Q is not empty:
                u = EXTRACT-MIN(Q)
                S = S ∪ {u}
                for each v in Adj[u]:
                    RELAX(u, v, w)   // update v.d if u.d + w(u,v) < v.d
        ```

        **复杂度：** 使用二叉堆为 O((V + E) log V)，使用简单数组为 O(V² + E)。

        ## 关键要点

        - BFS → 无权图中的最短路径、层序遍历
        - DFS → 拓扑排序、环检测、连通分量
        - Dijkstra → 非负权重下的最短路径；遇到负边会失效（改用 Bellman-Ford）
        - 三者均运行在 O(V + E) 或接近线性的时间内，适合大规模图问题
        """
        return doc
    }

    // MARK: - Doc 4: Business Ethics Case Study

    private static func makeDoc4(date: Date) -> WritingDocument {
        var doc = WritingDocument()
        doc.title = "商业伦理案例研究"
        doc.goalMode = .academic
        doc.tags = ["案例研究", "伦理"]
        doc.spaceID = SeedSpaceID.businessEthics
        doc.isPinned = false
        doc.createdAt = date
        doc.modifiedAt = date
        doc.score = WritingScore(overall: 83, correctness: 86, clarity: 81, engagement: 80, delivery: 84)
        doc.body = """
        # 案例研究：DataVault Inc. 与用户隐私

        ## 背景

        DataVault Inc. 是一家中型分析公司，为电商平台提供行为追踪工具。2025 年，一次内部审计发现，DataVault 一直在未经明确同意的情况下收集终端用户的精细位置数据，并将其打包进受众画像出售给第三方广告商。尽管其服务条款包含宽泛的数据使用表述，但从未向用户具体披露位置追踪或第三方销售。

        ## 利益相关方分析

        - **终端用户：** 主要受影响方。位置数据在未获知情同意的情况下被收集，侵犯了合理的隐私预期。面临监视、画像分析和身份暴露的风险。
        - **电商客户：** 善意集成 DataVault 的 SDK。如今面临声誉损害，并可能因在其平台上纵容未经同意的数据收集而承担监管责任。
        - **DataVault 员工：** 开发期间提出疑虑的工程师被告知该功能“在法律允许范围内”。这形成了一种重合规、轻伦理的文化。
        - **广告商：** 从丰富的受众画像中获益，但若数据被认定非法获取，可能面临审查。
        - **监管机构：** GDPR 与 CCPA 监管机构有调查和执法的职责，罚款可能高达年收入的 4%。

        ## 伦理框架分析

        **功利主义视角：** 数据收集带来了收入和更精准的广告，但对数百万用户的总体伤害——隐私丧失、信任侵蚀——远远超过这些商业利益。

        **义务论视角：** 康德的绝对命令要求绝不将个人仅仅作为实现目的的手段。未经同意收集并出售个人位置数据，等于将用户视为商品，侵犯了他们的自主与尊严。

        **美德伦理视角：** 有德性的公司会优先考虑透明与诚实。DataVault 刻意模糊其做法，反映的是组织层面的品格缺陷——这种缺陷侵蚀了整个科技生态的信任。

        ## 建议

        DataVault 应立即停止第三方位置数据销售，发布透明的公开披露，通知所有受影响用户，并实施真正的选择加入同意框架。公司应委托独立隐私审计，设立含外部成员的伦理审查委员会，并对工程与产品团队进行合乎伦理的数据实践再培训。主动配合监管机构将减轻处罚，并表明真正致力于改革而非损害控制。
        """
        return doc
    }

    // MARK: - Doc 5: Travel Itinerary — Japan

    private static func makeDoc5(date: Date) -> WritingDocument {
        var doc = WritingDocument()
        doc.title = "旅行行程 — 日本"
        doc.goalMode = .casual
        doc.tags = ["旅行", "规划"]
        doc.spaceID = SeedSpaceID.personal
        doc.isPinned = true
        doc.createdAt = date
        doc.modifiedAt = date
        doc.score = WritingScore(overall: 76, correctness: 78, clarity: 79, engagement: 75, delivery: 73)
        doc.body = """
        # 日本之旅 — 四月 10 天

        ## 概览

        - **日期：** 4 月 5–15 日
        - **路线：** 东京（4 晚）→ 京都（3 晚）→ 大阪（2 晚）→ 东京（1 晚，乘机离开）
        - **预算：** 总计约 3,200 美元（不含机票）

        ## 东京 — 第 1–4 天

        - **第 1 天：** 抵达成田机场，入住新宿的酒店。傍晚在思出横丁散步，吃烤鸡串、喝啤酒。
        - **第 2 天：** 筑地场外市场吃早餐。上午去 TeamLab Borderless。下午逛涩谷十字路口、原宿和明治神宫。在惠比寿吃晚餐。
        - **第 3 天：** 镰仓一日游——大佛、长谷寺、小町通。返回东京，在秋叶原吃晚餐。
        - **第 4 天：** 浅草（浅草寺）、上野公园和东京国立博物馆。晚上：如果樱花还在开，去新宿御苑。收拾行李准备去京都。

        **住宿：** 新宿格拉斯丽酒店 — 每晚 130 美元

        ## 京都 — 第 5–7 天

        - **第 5 天：** 乘新干线前往京都（2 小时 15 分）。入住祇园附近。傍晚人流散去时去伏见稻荷。
        - **第 6 天：** 清晨去岚山竹林。天龙寺。猴子公园。下午：锦市场。
        - **第 7 天：** 金阁寺（金色阁楼）、龙安寺石庭和二条城。晚上在祇园体验茶道。

        **住宿：** Piece Hostel Sanjo — 每晚 75 美元

        ## 大阪 — 第 8–9 天

        - **第 8 天：** 乘火车去大阪（15 分钟）。上午参观大阪城。去道顿堀吃街头小吃——章鱼烧、大阪烧、炸串。晚上：新世界街区。
        - **第 9 天：** 奈良一日游——鹿公园、东大寺。返回大阪，在当地居酒屋吃最后一顿晚餐。

        **住宿：** 大阪十字酒店 — 每晚 110 美元

        ## 第 10 天 — 返程

        上午乘新干线回东京。在东京站做最后的采购。下午 6 点从成田机场乘机离开。

        ## 预算明细

        | 类别 | 预估 |
        |----------|----------|
        | 住宿 | 1,235 美元 |
        | JR Pass（14 天） | 380 美元 |
        | 餐饮 | 900 美元 |
        | 活动与门票 | 250 美元 |
        | 杂项与纪念品 | 435 美元 |
        | **总计** | **约 3,200 美元** |

        ## 行李备注

        - 舒适的步行鞋（每天预计步行 1.5 万步以上）
        - 随身 Wi-Fi 或 eSIM——抵达时在机场租用
        - 轻薄分层衣物——四月天气温和，但可能下雨
        """
        return doc
    }

    // MARK: - Doc 6: Meeting Prep — Acme Review

    private static func makeDoc6(date: Date) -> WritingDocument {
        var doc = WritingDocument()
        doc.title = "会议准备 — Acme 评审"
        doc.goalMode = .business
        doc.tags = ["会议准备", "Acme"]
        doc.spaceID = SeedSpaceID.clientProjects
        doc.isPinned = false
        doc.createdAt = date
        doc.modifiedAt = date
        doc.score = WritingScore(overall: 81, correctness: 84, clarity: 82, engagement: 76, delivery: 80)
        doc.body = """
        # 季度评审 — Acme Corp

        ## 会议详情

        - **日期：** 2026 年 3 月 21 日，下午 2:00–3:30
        - **参会者：** Sarah Chen（Acme 产品副总裁）、Mike Torres（Acme 工程负责人）、我方团队（Priya、James、我）
        - **形式：** 视频会议，幻灯片提前异步分享

        ## 议程

        1. **Q1 表现回顾**（20 分钟）——过一遍 KPI 仪表盘，突出亮点与改进空间
        2. **路线图更新**（15 分钟）——预览 Q2 交付物，就优先级达成一致
        3. **未决问题**（15 分钟）——处理三个未解决的缺陷和 API 限流请求
        4. **合同续约讨论**（20 分钟）——当前协议 5 月 31 日到期，提出续约条款
        5. **问答与下一步**（20 分钟）

        ## 要展示的 KPI

        - **正常运行时间：** 99.94%（目标 99.9%）——12 周中有 11 周超出 SLA
        - **API 响应时间：** P95 为 142ms，较合作初期的 210ms 有所下降
        - **支持工单解决：** 平均解决时间从 18 小时降至 6.5 小时
        - **功能交付：** 计划 16 项功能中 14 项按时上线；2 项因 Acme 批准的范围变更推迟到 Q2

        ## 要问的问题

        - 团队对新仪表盘的反馈如何？数据上还有他们需要的缺口吗？
        - Acme 那边近期有产品发布会影响我们的集成时间线吗？
        - 他们内部的预算周期是怎样的——需要在特定日期前提交方案吗？
        - 他们是否愿意做案例研究或联合营销？

        ## 准备清单

        - [ ] 定稿幻灯片，周三下班前分享
        - [ ] 从分析仪表盘拉取最新 KPI 数据
        - [ ] 审阅三个未解决的缺陷工单，准备好状态更新
        - [ ] 起草续约方案，包含两种定价选项（年度固定费率 vs. 按用量计费）
        - [ ] 通话前 15 分钟测试屏幕共享和视频设置
        """
        return doc
    }

    // MARK: - Doc 7: Client Engagement Agreement (Legal)

    private static func makeDoc7(date: Date) -> WritingDocument {
        var doc = WritingDocument()
        doc.title = "客户委托协议"
        doc.goalMode = .business
        doc.tags = ["合同", "委托", "法务"]
        doc.spaceID = SeedSpaceID.legal
        doc.isPinned = true
        doc.createdAt = date
        doc.modifiedAt = date
        doc.score = WritingScore(overall: 90, correctness: 93, clarity: 88, engagement: 86, delivery: 92)
        doc.body = """
        # 客户委托协议

        **协议编号：** LEG-2026-0347
        **生效日期：** 2026 年 3 月 15 日
        **双方：** Logue Legal Partners LLP（“律所”）与 Meridian Technologies Inc.（“客户”）

        ---

        ## 1. 委托范围

        律所同意向客户提供以下法律服务：

        - **主要：** C 轮融资的公司治理咨询
        - **次要：** 知识产权审查与专利申请协调
        - **第三：** 监管合规评估（SEC、FTC）

        > **备注：** 本委托不包括诉讼、税务咨询或移民事务，除非依据下文第 8 条以书面形式明确修订。

        ### 1.1 交付物

        1. 现有知识产权组合的尽职调查报告
           - 专利格局分析
           - 商标冲突评估
           - 商业秘密审计
        2. 面向投资者治理的公司重组备忘录
           - 董事会构成建议
           - 股票期权计划审查
           - ~~股东协议红线稿~~ *（移至第二阶段）*
        3. 含差距分析的监管合规检查清单

        ## 2. 费用表

        | 服务类别 | 计费方式 | 费率 | 预计工时 | 上限 |
        |-----------------|-----------|------|----------------|-----|
        | 合伙人咨询 | 按小时 | 650 美元/小时 | 40 | 26,000 美元 |
        | 律师助理研究 | 按小时 | 375 美元/小时 | 120 | 45,000 美元 |
        | 专利申请 | 固定费用 | 8,500 美元/件 | 3 件 | 25,500 美元 |
        | 监管审查 | 混合计费 | 450 美元/小时 | 60 | 27,000 美元 |
        | **预计总计** | | | | **123,500 美元** |

        > 所有费用均不含政府申请费、诉讼费和第三方费用，这些费用按成本加 5% 管理费计收。

        ## 3. 付款条款

        - [x] 每月 1 日开具 Net-30 发票
        - [x] 10 天内付款享 2% 早付折扣
        - [ ] 逾期付款按月息 1.5% 计息
        - [ ] 签署时支付 15,000 美元预付款

        ## 4. 保密

        双方同意对本委托期间交换的所有信息严格保密。该义务在协议终止后继续有效 **五 (5) 年**。

        ```
        保密分级：
        第 1 级 — 公开：营销材料、新闻稿
        第 2 级 — 内部：财务预测、组织架构图
        第 3 级 — 受限：知识产权申请、商业秘密、源代码
        第 4 级 — 特权：律师与客户之间的沟通
        ```

        ## 5. 终止

        任何一方均可提前 **30 天书面通知** 终止本协议。终止时：

        1. 所有未付费用立即到期
        2. 截至终止时已完成的工作成果应交付客户
        3. 保密义务按第 4 条继续有效

        ---

        *本协议构成双方之间关于本主题的完整理解，并取代此前所有相关谈判、陈述或协议。*
        """
        doc.reviewGrade = OverallGrade(
            averageScore: 88,
            letterGrade: "A-",
            summary: "结构清晰的法律文档，条款明确。费用表透明。终止条款的具体性仍需小幅改进。",
            grades: [
                Grade(
                    category: .thesis,
                    score: 90,
                    letterGrade: "A",
                    feedback: "委托范围与限制陈述清晰。",
                    strengths: ["明确列出排除事项", "交付物定义清晰"],
                    improvements: ["为每项交付物添加时间线"]
                ),
                Grade(
                    category: .evidence,
                    score: 85,
                    letterGrade: "B+",
                    feedback: "费用表详细并设有上限。付款条款可以更具体。",
                    strengths: ["逐项费用明细", "费率上限保护客户"],
                    improvements: ["明确发票争议处理流程"]
                ),
                Grade(
                    category: .organization,
                    score: 92,
                    letterGrade: "A",
                    feedback: "从范围到费用再到终止，章节逻辑流畅。",
                    strengths: ["章节编号", "层级清晰"],
                    improvements: []
                ),
                Grade(
                    category: .style,
                    score: 86,
                    letterGrade: "B+",
                    feedback: "专业语气适合法律文档。",
                    strengths: ["格式一致", "法律语域恰当"],
                    improvements: ["简化部分复合句"]
                ),
                Grade(
                    category: .grammar,
                    score: 90,
                    letterGrade: "A",
                    feedback: "行文干净，无语法错误。",
                    strengths: ["文本无错误", "标点正确"],
                    improvements: []
                ),
                Grade(
                    category: .clarity,
                    score: 87,
                    letterGrade: "B+",
                    feedback: "多数条款定义清晰。保密分级是很好的加分项。",
                    strengths: ["分级体系清晰", "终止步骤有编号"],
                    improvements: ["明确“书面通知”的定义——邮件、挂号信，还是两者皆可？"]
                ),
            ]
        )
        doc.reviewReactions = [
            SectionReaction(
                sectionTitle: "委托范围",
                sectionText: "律所同意提供以下法律服务……",
                dominantEmotion: .engaged,
                emotionScores: [.engaged: 75, .inspired: 15, .bored: 10],
                explanation: "清晰、有条理的范围陈述有效设定预期。"
            ),
            SectionReaction(
                sectionTitle: "费用表",
                sectionText: "服务类别 | 计费方式 | 费率……",
                dominantEmotion: .skeptical,
                emotionScores: [.skeptical: 45, .engaged: 35, .confused: 20],
                explanation: "费率偏高，读者可能质疑价值。费用上限提供了一定安心感。"
            ),
            SectionReaction(
                sectionTitle: "保密",
                sectionText: "双方同意对本委托期间交换的所有信息严格保密……",
                dominantEmotion: .inspired,
                emotionScores: [.inspired: 50, .engaged: 40, .bored: 10],
                explanation: "分级体系是超出标准模板的用心设计。"
            ),
        ]
        doc.vocabSuggestions = [
            VocabSuggestion(
                original: "严格保密",
                suggestion: "绝对保密",
                explanation: "在保密条款中，“绝对”比“严格”具有更强的法律分量。",
                category: "精确性"
            ),
            VocabSuggestion(
                original: "在协议终止后继续有效",
                suggestion: "在协议终止或到期后继续有效",
                explanation: "标准的法律起草会同时涵盖终止和自然到期。",
                category: "完整性"
            ),
            VocabSuggestion(
                original: "立即到期",
                suggestion: "立即到期并应付款",
                explanation: "“到期并应付款”是加速付款义务的标准法律表述。",
                category: "法律惯例"
            ),
        ]
        return doc
    }

    // MARK: - Doc 8: Regulatory Compliance Checklist (Legal)

    private static func makeDoc8(date: Date) -> WritingDocument {
        var doc = WritingDocument()
        doc.title = "监管合规检查清单"
        doc.goalMode = .technical
        doc.tags = ["合规", "GDPR", "CCPA", "清单"]
        doc.spaceID = SeedSpaceID.legal
        doc.isPinned = false
        doc.createdAt = date
        doc.modifiedAt = date
        doc.score = WritingScore(overall: 84, correctness: 89, clarity: 83, engagement: 78, delivery: 85)
        doc.body = """
        # 监管合规检查清单 — 数据隐私

        **最后更新：** 2026 年 3 月
        **适用法规：** GDPR（欧盟）、CCPA/CPRA（加州）、PIPEDA（加拿大）
        **合规负责人：** Rebecca Torres，法学博士

        ## GDPR 合规

        ### 处理的合法依据

        - [x] 为每项处理活动记录合法依据
        - [x] 同意机制满足 GDPR 要求（自由给出、具体、知情、明确）
        - [ ] 完成非同意处理的正当利益评估
        - [x] 与所有处理者签署数据处理协议

        > **GDPR 第 6(1) 条：** 仅在至少满足以下一项的情况下，处理才是合法的：(a) 同意，(b) 合同履行，(c) 法律义务，(d) 重大利益，(e) 公共任务，(f) 正当利益。

        ### 数据主体权利

        | 权利 | GDPR 条款 | 实施状态 | 响应 SLA |
        |-------|-------------|----------------------|-------------|
        | 访问 | 第 15 条 | **已完成** | 30 天 |
        | 更正 | 第 16 条 | **已完成** | 30 天 |
        | 删除 | 第 17 条 | **进行中** | 30 天 |
        | 可携带 | 第 20 条 | **已计划** | 30 天 |
        | 反对 | 第 21 条 | **已完成** | 30 天 |

        ### 数据保护影响评估

        ```
        需要 DPIA 的情形：
        ├── 对公共区域的系统性监控
        ├── 大规模处理敏感数据
        ├── 具有法律效力的自动化决策
        └── 影响个人数据的新技术部署

        DPIA 模板参考：DPIA-TEMPLATE-v3.2
        已完成 DPIA：4/7 项处理活动
        下次审查：2026 年 Q2
        ```

        ## CCPA/CPRA 合规

        ### 消费者权利实施

        - [x] 所有面向客户的页面提供“请勿出售我的个人信息”链接
        - [x] 隐私政策已更新，包含 CCPA 要求的披露
        - [ ] 敏感个人信息选择退出机制
        - [ ] 按 CPRA 类别年度刷新数据清单
        - [x] 服务提供商协议已更新 CCPA 附录

        ### 数据类别清单

        ```
        类别 A — 标识符：姓名、邮箱、IP 地址、账户 ID
        类别 B — 个人记录：账单地址、电话号码
        类别 C — 受保护分类：年龄、性别（自愿提供）
        类别 D — 商业信息：购买历史、偏好
        类别 F — 互联网活动：浏览历史、搜索词
        类别 G — 地理位置：城市级大致位置
        ```

        ## PIPEDA 合规（加拿大）

        - [x] 隐私政策提供英文和法文版本
        - [ ] 跨境数据传输文档
        - [x] 已建立泄露通知程序（72 小时窗口）
        - [ ] 年度隐私影响评估

        ## 未决事项与风险登记

        | 事项 | 法规 | 风险等级 | 负责人 | 截止日期 |
        |------|-----------|-----------|-------|----------|
        | 删除 API 端点 | GDPR 第 17 条 | **高** | 工程 | 4 月 15 日 |
        | 数据可携带导出 | GDPR 第 20 条 | **中** | 工程 | 5 月 30 日 |
        | 敏感数据选择退出 | CPRA | **高** | 产品 | 4 月 1 日 |
        | 跨境文档 | PIPEDA | **中** | 法务 | 4 月 30 日 |
        | Cookie 同意刷新 | ePrivacy | **低** | 市场 | 6 月 1 日 |
        """
        doc.factChecks = [
            FactCheck(
                claim: "GDPR 第 6(1) 条列出六项处理的合法依据",
                status: .verified,
                explanation: "GDPR 第 6(1)(a)-(f) 条恰好列出六项合法依据：同意、合同、法律义务、重大利益、公共任务和正当利益。",
                sources: ["EU General Data Protection Regulation, Article 6(1)"],
                confidence: 98
            ),
            FactCheck(
                claim: "GDPR 要求对数据主体请求在 30 天内响应",
                status: .verified,
                explanation: "第 12(3) 条规定，控制者必须“不得无故拖延，且在任何情况下应在收到请求后一个月内”作出回应。",
                sources: ["GDPR Article 12(3)"],
                confidence: 95
            ),
            FactCheck(
                claim: "PIPEDA 要求 72 小时泄露通知窗口",
                status: .uncertain,
                explanation: "PIPEDA 的泄露通知法规要求在确定泄露后“尽快可行地”通知。72 小时窗口是 GDPR 的要求（第 33 条），而非 PIPEDA。",
                sources: ["PIPEDA Breach of Security Safeguards Regulations", "GDPR Article 33"],
                confidence: 40
            ),
            FactCheck(
                claim: "CCPA 要求提供“请勿出售我的个人信息”链接",
                status: .verified,
                explanation: "《加州民法典》§1798.135(a) 要求企业在互联网主页上提供标题为“请勿出售我的个人信息”的清晰醒目链接。",
                sources: ["California Civil Code §1798.135(a)"],
                confidence: 97
            ),
        ]
        doc.chatMessages = [
            ChatMessage(role: .user, content: "删除端点是否也需要处理备份中存储的数据？"),
            ChatMessage(
                role: .assistant,
                content: "根据 GDPR 第 17 条，删除权适用于数据的所有副本，包括备份。不过，ICO 指南指出，如果从备份中删除在技术上不可行，你可以保留备份数据，前提是采取措施确保这些数据不会被主动处理，并在备份周期结束时删除。请在 DPIA 中记录这一做法。"
            ),
        ]
        return doc
    }

    // MARK: - Doc 9: Patient Intake Summary (Healthcare — PII showcase)

    private static func makeDoc9(date: Date) -> WritingDocument {
        var doc = WritingDocument()
        doc.title = "患者接诊摘要 — Maria Santos"
        doc.goalMode = .business
        doc.tags = ["患者", "接诊", "机密"]
        doc.spaceID = SeedSpaceID.healthcare
        doc.isPinned = true
        doc.createdAt = date
        doc.modifiedAt = date
        doc.score = WritingScore(overall: 82, correctness: 88, clarity: 80, engagement: 74, delivery: 84)
        doc.body = """
        # 患者接诊摘要

        **就诊日期：** 2026 年 3 月 20 日
        **接诊医生：** Angela Chen 医生，医学博士 — 内科
        **机构：** Bayside Medical Center，204 室

        ---

        ## 人口统计信息

        | 字段 | 详情 |
        |-------|---------|
        | **全名** | Maria Elena Santos |
        | **出生日期** | 1983 年 7 月 14 日 |
        | **年龄** | 42 |
        | **性别** | 女 |
        | **SSN** | 478-22-9163 |
        | **MRN** | BMC-2026-081447 |
        | **地址** | 2847 Lakeshore Drive, Apt 6B, San Mateo, CA 94401 |
        | **电话** | (650) 555-0193 |
        | **邮箱** | maria.santos83@example.com |
        | **紧急联系人** | Carlos Santos（配偶）— (650) 555-0247 |

        ## 保险信息

        | 字段 | 详情 |
        |-------|---------|
        | **主保险** | Blue Shield of California |
        | **保单号** | BSC-4478291-A |
        | **团体号** | GRP-887421 |
        | **投保人** | Maria Elena Santos |
        | **补充保险** | 无 |
        | **自付额** | 35 美元 |

        ## 主诉

        患者主诉持续疲劳及双手间歇性关节疼痛 6 周。报告每日晨僵持续约 45 分钟。近期无外伤或损伤。

        ## 病史

        ### 当前用药

        | 药物 | 剂量 | 频次 | 开具者 |
        |-----------|--------|-----------|-----------|
        | 左甲状腺素 | 75 mcg | 每日早晨 | Chen 医生 |
        | 维生素 D3 | 2000 IU | 每日 | 非处方 |
        | 布洛芬 | 400 mg | 按需 | 非处方 |

        ### 既往病史

        - 甲状腺功能减退（2019 年确诊）
        - 季节性过敏
        - 阑尾切除术（2005 年）
        - ~~妊娠期糖尿病（2014 年）~~ — 产后缓解

        ### 家族史

        - **母亲：** 类风湿关节炎、2 型糖尿病
        - **父亲：** 高血压、冠状动脉疾病
        - **姐妹：** 狼疮（SLE）

        ## 生命体征

        | 测量项 | 数值 | 正常范围 |
        |------------|-------|-------------|
        | 血压 | 128/82 mmHg | <120/80 |
        | 心率 | 76 bpm | 60–100 |
        | 体温 | 98.4°F | 97.8–99.1 |
        | 体重 | 148 lbs | — |
        | BMI | 25.3 | 18.5–24.9 |
        | SpO2 | 98% | 95–100% |

        ## 评估与计划

        1. **疲劳伴关节疼痛** — 鉴别诊断包括早期类风湿关节炎、狼疮或甲状腺替代不足
           - 检查：CBC、CMP、ESR、CRP、ANA、RF、抗 CCP、TSH
           - 若 ANA 或 RF 阳性，转诊风湿科
        2. **甲状腺功能减退** — 上次检查 TSH 为 8 个月前
           - 随上述化验复查 TSH 和游离 T4
           - 可能需要调整左甲状腺素剂量
        3. **BMI 偏高** — 超重边缘
           - 已提供饮食咨询
           - 4 周后带化验结果复诊

        > **HIPAA 提示：** 本文档包含受保护健康信息（PHI）。根据 45 CFR 第 160 和 164 部分，未经授权披露是被禁止的。

        ---

        *下次预约：2026 年 4 月 17 日上午 10:30 — Chen 医生*
        *患者门户：bayside-medical.com/portal — 用户名：msantos2026*
        """
        doc.piiFindings = [
            PIIFinding(
                category: .identity,
                text: "Maria Elena Santos",
                detail: "完整患者姓名在人口统计和保险部分多次出现"
            ),
            PIIFinding(category: .identity, text: "July 14, 1983", detail: "患者出生日期——与姓名结合可导致身份盗用"),
            PIIFinding(category: .governmentIDs, text: "478-22-9163", detail: "社会安全号码——风险最高的 PII，可用于金融欺诈"),
            PIIFinding(category: .contact, text: "(650) 555-0193", detail: "患者电话号码"),
            PIIFinding(category: .contact, text: "maria.santos83@example.com", detail: "患者邮箱地址"),
            PIIFinding(category: .contact, text: "2847 Lakeshore Drive, Apt 6B, San Mateo, CA 94401", detail: "完整家庭住址"),
            PIIFinding(category: .health, text: "BSC-4478291-A", detail: "健康保险保单号——可用于保险欺诈"),
            PIIFinding(category: .health, text: "BMC-2026-081447", detail: "病历号——可关联到完整患者病史"),
            PIIFinding(category: .identity, text: "Carlos Santos", detail: "紧急联系人姓名——透露家庭关系"),
            PIIFinding(category: .contact, text: "(650) 555-0247", detail: "紧急联系人电话号码"),
            PIIFinding(
                category: .credentials,
                text: "msantos2026",
                detail: "患者门户用户名——可能导致未经授权的病历访问"
            ),
        ]
        return doc
    }

    // MARK: - Doc 10: Clinical Research Protocol (Healthcare)

    private static func makeDoc10(date: Date) -> WritingDocument {
        var doc = WritingDocument()
        doc.title = "临床研究方案 — II 期试验"
        doc.goalMode = .academic
        doc.tags = ["研究", "临床试验", "方案"]
        doc.spaceID = SeedSpaceID.healthcare
        doc.isPinned = false
        doc.createdAt = date
        doc.modifiedAt = date
        doc.score = WritingScore(overall: 87, correctness: 92, clarity: 84, engagement: 80, delivery: 89)
        doc.body = """
        # II 期临床试验方案

        **方案编号：** BTC-RA-2026-Phase2
        **申办方：** Bayside Therapeutics Corp.
        **主要研究者：** James Nakamura 医生，医学博士、理学博士
        **IND 编号：** IND-182934

        ---

        ## 1. 研究概览

        > *“本 II 期试验的目标是评估 BTC-4501——一种新型 JAK1 选择性抑制剂——在对甲氨蝶呤应答不足的中重度类风湿关节炎患者中的疗效与安全性。”*

        ### 1.1 主要目标

        确定第 12 周时达到 ACR20 应答的患者比例，并与安慰剂比较。

        ### 1.2 次要目标

        1. 评估第 12 周和第 24 周的 ACR50 和 ACR70 应答率
        2. 评估 DAS28-CRP 相对基线的变化
        3. 描述安全性与耐受性特征
           - 不良事件频率与严重程度
           - 实验室异常（肝脏、血液）
           - 感染率

        ## 2. 研究设计

        随机、双盲、安慰剂对照、平行分组研究。

        | 参数 | 详情 |
        |-----------|---------|
        | **入组目标** | 240 名患者（每组 80 名） |
        | **随机化** | 1:1:1（低剂量 : 高剂量 : 安慰剂） |
        | **治疗时长** | 24 周 |
        | **随访** | 治疗后 4 周 |
        | **中心** | 美国及加拿大 18 个中心 |

        ### 2.1 给药方案

        | 组别 | 药物 | 剂量 | 给药途径 | 频次 |
        |-----|------|------|-------|-----------|
        | A | BTC-4501 | 5 mg | 口服 | 每日一次 |
        | B | BTC-4501 | 15 mg | 口服 | 每日一次 |
        | C | 安慰剂 | — | 口服 | 每日一次 |

        > **21 CFR 312.23(a)(6)：** 方案必须包含剂型、给药途径和治疗时长的描述。

        ## 3. 统计分析计划

        ### 3.1 样本量论证

        假设 ACR20 应答率为 55%（治疗组）对 30%（安慰剂组），α = 0.05（双侧）、把握度 90%：

        ```
        n = (Z_α/2 + Z_β)² × (p₁(1-p₁) + p₂(1-p₂)) / (p₁ - p₂)²
        n = (1.96 + 1.28)² × (0.55×0.45 + 0.30×0.70) / (0.55 - 0.30)²
        n = 10.4976 × (0.2475 + 0.21) / 0.0625
        n = 10.4976 × 0.4575 / 0.0625
        n ≈ 77 per arm → 80 per arm (accounting for ~5% dropout)
        ```

        ### 3.2 主要终点分析

        ```python
        # Primary analysis — logistic regression
        from scipy import stats

        def primary_analysis(treatment, placebo):
            # Cochran-Mantel-Haenszel test stratified by region
            # and prior biologic use
            odds_ratio, p_value = stats.fisher_exact(
                [[responders_tx, non_responders_tx],
                 [responders_pl, non_responders_pl]]
            )
            return odds_ratio, p_value

        # Missing data: multiple imputation (m=20)
        # Sensitivity: tipping point analysis
        ```

        ### 3.3 终点汇总

        | 终点 | 指标 | 时间点 | 分析方法 |
        |----------|---------|-----------|----------------|
        | **主要** | ACR20 应答 | 第 12 周 | CMH 检验，分层 |
        | 次要 | ACR50/70 应答 | 第 12、24 周 | 逻辑回归 |
        | 次要 | DAS28-CRP 变化 | 第 12、24 周 | MMRM |
        | 安全性 | AE 发生率 | 持续 | 描述性统计 |
        | 探索性 | ~~HAQ-DI 变化~~ | ~~第 24 周~~ | *已修订：根据 DSMB 建议移除* |

        ## 4. 入选 / 排除标准

        ### 4.1 入选标准

        - 18–75 岁成人，依据 2010 ACR/EULAR 标准确诊 RA
        - 活动性疾病：筛查时 DAS28-CRP ≥ 3.2
        - 对甲氨蝶呤应答不足（≥ 15 mg/周，持续 ≥ 12 周）
        - 随机化前甲氨蝶呤剂量稳定 ≥ 4 周

        ### 4.2 排除标准

        - 既往使用任何 JAK 抑制剂
        - 活动性或潜伏性结核
        - 5 年内恶性肿瘤史（非黑色素瘤皮肤癌除外）
        - ~~eGFR < 40 mL/min~~ → *根据方案修订 2 改为 eGFR < 30 mL/min*
        - 妊娠或哺乳

        ## 5. 监管参考

        > **ICH E6(R2) §4.5.1：** *“研究者应确保临床试验按照方案开展。”*

        > **《赫尔辛基宣言》（2013）§25：** *“每项涉及人类受试者的研究，其设计与实施必须在研究方案中清晰描述并说明理由。”*
        """
        doc.aiDetectionResult = "AI 可能性：12% — 本文档似乎主要由人类撰写。方案设计的技术具体性、监管引用和统计公式与专家科学写作一致。概览部分的措辞中检测到少量类似 AI 的模式。"
        doc.plagiarismResult = "相似度：8% — 低风险。匹配内容仅限于标准监管引用（ICH E6、《赫尔辛基宣言》）和常规临床试验术语。与参考数据库中的已发表方案无实质性重叠。"
        doc.rewriteResult = RewriteResult(
            style: "通俗语言摘要",
            originalText: "确定第 12 周时达到 ACR20 应答的患者比例，并与安慰剂比较。",
            rewrittenText: "了解与服用糖丸的患者相比，接受 BTC-4501 治疗 12 周后，有多少患者的类风湿关节炎症状出现有意义的改善。"
        )
        return doc
    }
}

// swiftlint:enable line_length function_body_length
