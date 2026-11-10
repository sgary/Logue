// swiftlint:disable file_length
import Foundation
import SwiftUI

// MARK: - Seed Data for Website Screenshots

// swiftlint:disable line_length force_unwrapping function_body_length

extension MeetingStore {
    static func makeSeedMeetings() -> [MeetingNote] {
        let now = Date()
        let cal = Calendar.current

        func daysAgo(_ days: Int, hour: Int = 10) -> Date {
            cal.date(
                byAdding: .hour,
                value: hour,
                to: cal.date(byAdding: .day, value: -days, to: cal.startOfDay(for: now))!
            )!
        }

        return [
            makeMeeting1(date: daysAgo(0, hour: 10)),
            makeMeeting2(date: daysAgo(1, hour: 14)),
            makeMeeting3(date: daysAgo(2, hour: 11)),
            makeMeeting4(date: daysAgo(4, hour: 10)),
            makeMeeting5(date: daysAgo(6, hour: 15)),
            makeMeeting6(date: daysAgo(1, hour: 9)),
            makeMeeting7(date: daysAgo(3, hour: 16)),
            makeMeeting8(date: daysAgo(0, hour: 13)),
            makeMeeting9(date: daysAgo(2, hour: 15)),
        ]
    }

    // MARK: - Helper

    private static func seg(_ text: String, start: TimeInterval, end: TimeInterval, speaker: String, confidence: Double = 0.95) -> TranscriptSegment {
        TranscriptSegment(text: text, startTime: start, endTime: end, speakerLabel: speaker, confidence: confidence)
    }

    private static func spkSeg(_ speakerId: String, start: TimeInterval, end: TimeInterval, text: String) -> SpeakerSegment {
        SpeakerSegment(speakerId: speakerId, startTime: start, endTime: end, text: text)
    }

    /// Due date helper — days from now (positive = future, negative = overdue).
    private static func due(_ daysFromNow: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: daysFromNow, to: Calendar.current.startOfDay(for: .now))!
    }

    // MARK: - Meeting 1: Acme Q3 Kickoff

    private static func makeMeeting1(date: Date) -> MeetingNote {
        let sp1 = "speaker-sarah", sp2 = "speaker-james", sp3 = "speaker-priya"
        let speakers = [
            Speaker(id: sp1, name: "Sarah", color: AppThemeConstants.speakerBlurple),
            Speaker(id: sp2, name: "James", color: AppThemeConstants.speakerGreen),
            Speaker(id: sp3, name: "Priya", color: AppThemeConstants.speakerOrange),
        ]
        let segments = [
            seg(
                "大家好，感谢参加。我们开始 Acme 的 Q3 营销活动规划吧。",
                start: 0,
                end: 12,
                speaker: "Sarah"
            ),
            seg(
                "谢谢 Sarah。我们这边本季度最重要的任务是 8 月的产品品牌重塑发布。",
                start: 12,
                end: 26,
                speaker: "James"
            ),
            seg(
                "这和我们的想法很一致。Priya，能带我们过一遍创意方向吗？",
                start: 26,
                end: 38,
                speaker: "Sarah"
            ),
            seg(
                "好的。我们想走干净、现代的美学风格——从厚重的插画风转向以摄影为主的版式。",
                start: 38,
                end: 55,
                speaker: "Priya"
            ),
            seg(
                "我很喜欢这个方向。我们内部的品牌团队一直在推动这样的转变。",
                start: 55,
                end: 68,
                speaker: "James"
            ),
            seg(
                "很好。交付物方面，包括落地页、社交媒体素材和一支发布视频。周期是六周。",
                start: 68,
                end: 85,
                speaker: "Sarah"
            ),
            seg(
                "六周有点紧，但如果本周内敲定创意简报，还是可行的。",
                start: 85,
                end: 98,
                speaker: "Priya"
            ),
            seg(
                "同意。James，我们之前谈的 4.5 万美元预算你那边还能接受吗？",
                start: 98,
                end: 112,
                speaker: "Sarah"
            ),
            seg(
                "可以，内部已经批准了。我周四前把签好的工作说明书发过来。",
                start: 112,
                end: 125,
                speaker: "James"
            ),
            seg(
                "太好了。我们把设计评审安排在下周二，保持推进节奏。我今天就发出邀请。",
                start: 125,
                end: 142,
                speaker: "Sarah"
            ),
            seg(
                "没问题。到时候我会准备好初步的情绪板和风格样稿。",
                start: 142,
                end: 155,
                speaker: "Priya"
            ),
            seg(
                "进展很不错。期待看到第一批概念方案。谢谢大家。",
                start: 155,
                end: 168,
                speaker: "James"
            ),
        ]
        let speakerSegments = [
            spkSeg(sp1, start: 0, end: 12, text: "大家好，感谢参加。我们开始 Acme 的 Q3 营销活动规划吧。"),
            spkSeg(
                sp2,
                start: 12,
                end: 26,
                text: "谢谢 Sarah。我们这边本季度最重要的任务是 8 月的产品品牌重塑发布。"
            ),
            spkSeg(
                sp1,
                start: 26,
                end: 38,
                text: "这和我们的想法很一致。Priya，能带我们过一遍创意方向吗？"
            ),
            spkSeg(
                sp3,
                start: 38,
                end: 55,
                text: "好的。我们想走干净、现代的美学风格——从厚重的插画风转向以摄影为主的版式。"
            ),
            spkSeg(sp2, start: 55, end: 68, text: "我很喜欢这个方向。我们内部的品牌团队一直在推动这样的转变。"),
            spkSeg(
                sp1,
                start: 68,
                end: 85,
                text: "很好。交付物方面，包括落地页、社交媒体素材和一支发布视频。周期是六周。"
            ),
            spkSeg(sp3, start: 85, end: 98, text: "六周有点紧，但如果本周内敲定创意简报，还是可行的。"),
            spkSeg(sp1, start: 98, end: 112, text: "同意。James，我们之前谈的 4.5 万美元预算你那边还能接受吗？"),
            spkSeg(sp2, start: 112, end: 125, text: "可以，内部已经批准了。我周四前把签好的工作说明书发过来。"),
            spkSeg(
                sp1,
                start: 125,
                end: 142,
                text: "太好了。我们把设计评审安排在下周二，保持推进节奏。我今天就发出邀请。"
            ),
            spkSeg(sp3, start: 142, end: 155, text: "没问题。到时候我会准备好初步的情绪板和风格样稿。"),
            spkSeg(sp2, start: 155, end: 168, text: "进展很不错。期待看到第一批概念方案。谢谢大家。"),
        ]

        var meeting = MeetingNote(
            title: "Acme Q3 启动会",
            createdAt: date,
            modifiedAt: date,
            recordingMode: .inPerson,
            spaceID: SeedSpaceID.clientProjects
        )
        meeting.duration = 168
        meeting.speakers = speakers
        meeting.segments = segments
        meeting.speakerSegments = speakerSegments
        meeting.hasSpeakerData = true
        meeting.summary = "启动了 Acme 产品品牌重塑的 Q3 营销活动规划。确定以摄影为主导的创意方向、六周交付周期和 4.5 万美元预算。设计评审安排在下周二。"
        meeting.isPinned = true
        meeting.tags = ["客户", "Q3"]
        meeting.actionItems = [
            ActionItem(title: "敲定创意简报", assignee: "Priya", dueDescription: "本周内", dueDate: due(3)),
            ActionItem(title: "安排下周二的设计评审", assignee: "Sarah", dueDescription: "今天", dueDate: due(0)),
            ActionItem(title: "发送签字版工作说明书", assignee: "James", dueDescription: "周四前", dueDate: due(2)),
        ]
        meeting.bookmarks = [
            Bookmark(label: "创意方向", timestamp: 38, color: .blue),
            Bookmark(label: "预算已确认", timestamp: 98, color: .purple),
            Bookmark(label: "下一步", timestamp: 125, color: .orange),
        ]
        meeting.smartMinutes = SmartMinutes(
            keyDecisions: [
                "确定以摄影为主导的创意方向，取代插画风格",
                "预算定为 4.5 万美元——Acme 内部已批准",
                "交付周期六周，从本周开始",
            ],
            discussionPoints: [
                "Q3 的重点是 8 月的产品品牌重塑发布",
                "交付物包括落地页、社交媒体素材和发布视频",
                "为赶上进度，创意简报必须本周敲定",
            ],
            actionItems: [
                "Priya 本周内敲定创意简报",
                "Sarah 发出下周二设计评审的邀请",
                "James 周四前发送签字版工作说明书",
            ],
            followUps: [
                "下周二设计评审，展示情绪板和风格样稿",
                "Priya 在评审前准备初步概念方案",
            ],
            attendeeSummary: [
                AttendeeContribution(name: "Sarah", keyPoints: ["确定周期和交付物", "确认预算"], speakingTimePercent: 40),
                AttendeeContribution(name: "James", keyPoints: ["确认品牌重塑优先级", "批准预算"], speakingTimePercent: 30),
                AttendeeContribution(
                    name: "Priya",
                    keyPoints: ["提出创意方向", "承诺按时交付简报"],
                    speakingTimePercent: 30
                ),
            ]
        )
        return meeting
    }

    // MARK: - Meeting 2: Sprint Retrospective

    private static func makeMeeting2(date: Date) -> MeetingNote {
        let sp1 = "speaker-alex", sp2 = "speaker-dana", sp3 = "speaker-raj"
        let speakers = [
            Speaker(id: sp1, name: "Alex", color: AppThemeConstants.speakerBlurple),
            Speaker(id: sp2, name: "Dana", color: AppThemeConstants.speakerPink),
            Speaker(id: sp3, name: "Raj", color: AppThemeConstants.speakerCyan),
        ]
        let segments = [
            seg(
                "我们开始回顾吧。还是老格式——哪些做得好、哪些不好、想改进什么。",
                start: 0,
                end: 14,
                speaker: "Alex"
            ),
            seg(
                "我先说做得好的地方。新的组件库让设置页改版省了大量时间。",
                start: 14,
                end: 28,
                speaker: "Dana"
            ),
            seg(
                "同意。后端这边，迁移到新的数据库结构比预期顺利，零停机。",
                start: 28,
                end: 44,
                speaker: "Raj"
            ),
            seg(
                "不错。那哪些地方不顺利？我知道代码评审的周转又出问题了。",
                start: 44,
                end: 56,
                speaker: "Alex"
            ),
            seg(
                "是啊，我有个 PR 放了三天。整个通知功能的推进都被它卡住了。",
                start: 56,
                end: 70,
                speaker: "Dana"
            ),
            seg(
                "部分是我的责任。我当时深陷迁移工作，评审就积压了。我们需要更好的机制。",
                start: 70,
                end: 86,
                speaker: "Raj"
            ),
            seg(
                "如果我们定一个 24 小时的评审 SLA 呢？每天轮换一名指定评审人，保证总有人把它当优先事项。",
                start: 86,
                end: 106,
                speaker: "Alex"
            ),
            seg(
                "我喜欢这个主意。另外，我们应该增加集成测试。这个冲刺后期发现了两个回归问题，如果测试覆盖更好就能避免。",
                start: 106,
                end: 125,
                speaker: "Dana"
            ),
            seg(
                "好主意。我下周可以组织一次测试工作坊，让大家对要用的集成测试模式达成一致。",
                start: 125,
                end: 140,
                speaker: "Raj"
            ),
        ]
        let speakerSegments = [
            spkSeg(
                sp1,
                start: 0,
                end: 14,
                text: "我们开始回顾吧。还是老格式——哪些做得好、哪些不好、想改进什么。"
            ),
            spkSeg(
                sp2,
                start: 14,
                end: 28,
                text: "我先说做得好的地方。新的组件库让设置页改版省了大量时间。"
            ),
            spkSeg(
                sp3,
                start: 28,
                end: 44,
                text: "同意。后端这边，迁移到新的数据库结构比预期顺利，零停机。"
            ),
            spkSeg(sp1, start: 44, end: 56, text: "不错。那哪些地方不顺利？我知道代码评审的周转又出问题了。"),
            spkSeg(
                sp2,
                start: 56,
                end: 70,
                text: "是啊，我有个 PR 放了三天。整个通知功能的推进都被它卡住了。"
            ),
            spkSeg(
                sp3,
                start: 70,
                end: 86,
                text: "部分是我的责任。我当时深陷迁移工作，评审就积压了。我们需要更好的机制。"
            ),
            spkSeg(
                sp1,
                start: 86,
                end: 106,
                text: "如果我们定一个 24 小时的评审 SLA 呢？每天轮换一名指定评审人，保证总有人把它当优先事项。"
            ),
            spkSeg(
                sp2,
                start: 106,
                end: 125,
                text: "我喜欢这个主意。另外，我们应该增加集成测试。这个冲刺后期发现了两个回归问题，如果测试覆盖更好就能避免。"
            ),
            spkSeg(
                sp3,
                start: 125,
                end: 140,
                text: "好主意。我下周可以组织一次测试工作坊，让大家对要用的集成测试模式达成一致。"
            ),
        ]

        var meeting = MeetingNote(
            title: "冲刺回顾会",
            createdAt: date,
            modifiedAt: date,
            recordingMode: .inPerson,
            spaceID: SeedSpaceID.internal
        )
        meeting.duration = 140
        meeting.speakers = speakers
        meeting.segments = segments
        meeting.speakerSegments = speakerSegments
        meeting.hasSpeakerData = true
        meeting.summary = "冲刺回顾会，总结了亮点（组件库、零停机迁移）和痛点（代码评审慢，阻塞功能推进）。确定 24 小时评审 SLA、每日轮值评审人，并增加集成测试。"
        meeting.isPinned = false
        meeting.tags = ["冲刺", "回顾"]
        meeting.actionItems = [
            ActionItem(
                title: "落实 24 小时代码评审 SLA 和每日评审轮值",
                assignee: "Alex",
                dueDescription: "下个冲刺",
                dueDate: due(5)
            ),
            ActionItem(
                title: "为通知和设置流程补充集成测试",
                assignee: "Dana",
                dueDescription: "下个冲刺",
                dueDate: due(5)
            ),
            ActionItem(title: "开展集成测试模式工作坊", assignee: "Raj", dueDescription: "下周", dueDate: due(4)),
        ]
        meeting.bookmarks = [
            Bookmark(label: "做得好的地方", timestamp: 14, color: .blue),
            Bookmark(label: "评审瓶颈", timestamp: 56, color: .red),
            Bookmark(label: "改进想法", timestamp: 86, color: .purple),
        ]
        meeting.smartMinutes = SmartMinutes(
            keyDecisions: [
                "代码评审实行 24 小时 SLA，并每日轮换评审人",
                "将提高集成测试覆盖率列为冲刺目标",
            ],
            discussionPoints: [
                "组件库加快了设置页改版",
                "数据库迁移完成，零停机",
                "因评审积压，PR 被阻塞三天",
                "缺少集成测试，两个回归问题到后期才发现",
            ],
            actionItems: [
                "Alex 落实 24 小时评审 SLA 和轮值表",
                "Dana 为通知和设置补充集成测试",
                "Raj 下周组织测试工作坊",
            ],
            followUps: [
                "下次回顾会评估新 SLA 流程的效果",
                "下个冲刺跟踪回归数量，衡量改进效果",
            ],
            attendeeSummary: [
                AttendeeContribution(
                    name: "Alex",
                    keyPoints: ["主持讨论", "提出评审 SLA 和轮值方案"],
                    speakingTimePercent: 35
                ),
                AttendeeContribution(
                    name: "Dana",
                    keyPoints: ["指出评审瓶颈", "提出集成测试改进"],
                    speakingTimePercent: 35
                ),
                AttendeeContribution(
                    name: "Raj",
                    keyPoints: ["分享迁移成功经验", "主动承担测试工作坊"],
                    speakingTimePercent: 30
                ),
            ]
        )
        return meeting
    }

    // MARK: - Meeting 3: CS 301 Study Group

    private static func makeMeeting3(date: Date) -> MeetingNote {
        let sp1 = "speaker-you", sp2 = "speaker-mia"
        let speakers = [
            Speaker(id: sp1, name: "你", color: AppThemeConstants.speakerBlurple),
            Speaker(id: sp2, name: "Mia", color: AppThemeConstants.speakerGreen),
        ]
        let segments = [
            seg(
                "好，期中考试还有两周。我觉得应该重点复习图算法，因为那是考试占比最大的部分。",
                start: 0,
                end: 15,
                speaker: "你"
            ),
            seg(
                "对，Kim 教授说至少 30% 会考图。我们先从最短路径还是生成树开始？",
                start: 15,
                end: 28,
                speaker: "Mia"
            ),
            seg(
                "先做最短路径吧。我总是搞不清什么时候用 Dijkstra、什么时候用 Bellman-Ford。",
                start: 28,
                end: 42,
                speaker: "你"
            ),
            seg(
                "关键是负权边。Dijkstra 处理不了，Bellman-Ford 可以。另外 Dijkstra 是贪心算法，Bellman-Ford 是动态规划。",
                start: 42,
                end: 58,
                speaker: "Mia"
            ),
            seg(
                "对，时间复杂度差别也挺大。用普通数组时 Dijkstra 是 O(V²)，用最小堆是 O(E log V)。",
                start: 58,
                end: 74,
                speaker: "你"
            ),
            seg(
                "我们还应该练一练推演题。去年的考试有两道这样的题，要求写出算法的每一步。",
                start: 74,
                end: 88,
                speaker: "Mia"
            ),
            seg(
                "好主意。我在课程网站上找到了一套练习题。要不要分头做，周四对答案？",
                start: 88,
                end: 102,
                speaker: "你"
            ),
            seg(
                "可以。我还会复习前两年的试卷——听说助教把它们传到共享盘了。",
                start: 102,
                end: 118,
                speaker: "Mia"
            ),
        ]
        let speakerSegments = [
            spkSeg(
                sp1,
                start: 0,
                end: 15,
                text: "好，期中考试还有两周。我觉得应该重点复习图算法，因为那是考试占比最大的部分。"
            ),
            spkSeg(
                sp2,
                start: 15,
                end: 28,
                text: "对，Kim 教授说至少 30% 会考图。我们先从最短路径还是生成树开始？"
            ),
            spkSeg(
                sp1,
                start: 28,
                end: 42,
                text: "先做最短路径吧。我总是搞不清什么时候用 Dijkstra、什么时候用 Bellman-Ford。"
            ),
            spkSeg(
                sp2,
                start: 42,
                end: 58,
                text: "关键是负权边。Dijkstra 处理不了，Bellman-Ford 可以。另外 Dijkstra 是贪心算法，Bellman-Ford 是动态规划。"
            ),
            spkSeg(
                sp1,
                start: 58,
                end: 74,
                text: "对，时间复杂度差别也挺大。用普通数组时 Dijkstra 是 O(V²)，用最小堆是 O(E log V)。"
            ),
            spkSeg(
                sp2,
                start: 74,
                end: 88,
                text: "我们还应该练一练推演题。去年的考试有两道这样的题，要求写出算法的每一步。"
            ),
            spkSeg(
                sp1,
                start: 88,
                end: 102,
                text: "好主意。我在课程网站上找到了一套练习题。要不要分头做，周四对答案？"
            ),
            spkSeg(
                sp2,
                start: 102,
                end: 118,
                text: "可以。我还会复习前两年的试卷——听说助教把它们传到共享盘了。"
            ),
        ]

        var meeting = MeetingNote(
            title: "CS 301 学习小组",
            createdAt: date,
            modifiedAt: date,
            recordingMode: .inPerson,
            spaceID: SeedSpaceID.cs301
        )
        meeting.duration = 118
        meeting.speakers = speakers
        meeting.segments = segments
        meeting.speakerSegments = speakerSegments
        meeting.hasSpeakerData = true
        meeting.summary = "制定了 CS 301 期中复习策略。重点复习图算法——Dijkstra 与 Bellman-Ford 的对比、复杂度分析和推演题。分工练习题目，并在周四前复习往年试卷。"
        meeting.isPinned = false
        meeting.tags = ["学习", "算法"]
        meeting.actionItems = [
            ActionItem(
                title: "练习 Dijkstra 和 Bellman-Ford 推演题",
                assignee: "你",
                dueDescription: "周四前",
                dueDate: due(1)
            ),
            ActionItem(title: "复习共享盘里的前两年期中试卷", assignee: "Mia", dueDescription: "周四前", dueDate: due(1)),
        ]
        meeting.bookmarks = [
            Bookmark(label: "Dijkstra 与 Bellman-Ford", timestamp: 42, color: .blue),
            Bookmark(label: "练习计划", timestamp: 88, color: .purple),
        ]
        meeting.smartMinutes = SmartMinutes(
            keyDecisions: [
                "期中复习重点放在图算法",
                "先复习最短路径算法，再复习生成树",
            ],
            discussionPoints: [
                "图算法至少占期中考试的 30%",
                "Dijkstra 是贪心算法，遇到负权边会失效；Bellman-Ford 使用动态规划",
                "时间复杂度：Dijkstra 用最小堆为 O(E log V)，Bellman-Ford 为 O(VE)",
                "往年试卷包含逐步推演题",
            ],
            actionItems: [
                "分工完成课程网站上的练习题，周四对答案",
                "Mia 从共享盘取往年试卷",
            ],
            followUps: [
                "周四碰面，核对练习题答案",
                "最短路径之后转向生成树和最小生成树算法",
            ],
            attendeeSummary: [
                AttendeeContribution(name: "你", keyPoints: ["确定以图算法为复习重点", "找到练习题"], speakingTimePercent: 50),
                AttendeeContribution(
                    name: "Mia",
                    keyPoints: ["讲清算法区别", "建议练习推演题"],
                    speakingTimePercent: 50
                ),
            ]
        )
        return meeting
    }

    // MARK: - Meeting 4: Project Check-in w/ Prof. Lee

    private static func makeMeeting4(date: Date) -> MeetingNote {
        let sp1 = "speaker-you", sp2 = "speaker-prof-lee"
        let speakers = [
            Speaker(id: sp1, name: "你", color: AppThemeConstants.speakerBlurple),
            Speaker(id: sp2, name: "Lee 教授", color: AppThemeConstants.speakerOrange),
        ]
        let segments = [
            seg(
                "Lee 教授你好，感谢你抽时间。我想在继续写之前听听你对案例研究初稿的反馈。",
                start: 0,
                end: 14,
                speaker: "你"
            ),
            seg(
                "当然。我昨晚读了一遍。你对 Patagonia 案例的分析很扎实，但利益相关方那一节还需要更深入。",
                start: 14,
                end: 30,
                speaker: "Lee 教授"
            ),
            seg(
                "能具体说说缺什么吗？我以为主要群体都覆盖了——股东、员工和客户。",
                start: 30,
                end: 44,
                speaker: "你"
            ),
            seg(
                "确实覆盖了，但你没有涉及供应链工人。对一篇伦理学的论文来说，这是不能忽略的关键利益相关方。",
                start: 44,
                end: 58,
                speaker: "Lee 教授"
            ),
            seg(
                "这个提醒很重要。我会加一节讲供应链的劳动实践，以及它们如何纳入伦理框架。",
                start: 58,
                end: 72,
                speaker: "你"
            ),
            seg(
                "另外，理论框架部分的引用有点单薄。你应该直接引用 Freeman 的利益相关者理论，也许再加上 Donaldson 和 Preston。",
                start: 72,
                end: 88,
                speaker: "Lee 教授"
            ),
            seg(
                "明白。Freeman 的书我有——会把相关章节找出来。Donaldson 和 Preston 是 1995 年那篇吗？",
                start: 88,
                end: 100,
                speaker: "你"
            ),
            seg(
                "对，就是讲工具性、规范性和描述性分类的那篇。周五前提交修改稿，我会在截止日期前给你最终反馈。",
                start: 100,
                end: 114,
                speaker: "Lee 教授"
            ),
        ]
        let speakerSegments = [
            spkSeg(
                sp1,
                start: 0,
                end: 14,
                text: "Lee 教授你好，感谢你抽时间。我想在继续写之前听听你对案例研究初稿的反馈。"
            ),
            spkSeg(
                sp2,
                start: 14,
                end: 30,
                text: "当然。我昨晚读了一遍。你对 Patagonia 案例的分析很扎实，但利益相关方那一节还需要更深入。"
            ),
            spkSeg(
                sp1,
                start: 30,
                end: 44,
                text: "能具体说说缺什么吗？我以为主要群体都覆盖了——股东、员工和客户。"
            ),
            spkSeg(
                sp2,
                start: 44,
                end: 58,
                text: "确实覆盖了，但你没有涉及供应链工人。对一篇伦理学的论文来说，这是不能忽略的关键利益相关方。"
            ),
            spkSeg(
                sp1,
                start: 58,
                end: 72,
                text: "这个提醒很重要。我会加一节讲供应链的劳动实践，以及它们如何纳入伦理框架。"
            ),
            spkSeg(
                sp2,
                start: 72,
                end: 88,
                text: "另外，理论框架部分的引用有点单薄。你应该直接引用 Freeman 的利益相关者理论，也许再加上 Donaldson 和 Preston。"
            ),
            spkSeg(
                sp1,
                start: 88,
                end: 100,
                text: "明白。Freeman 的书我有——会把相关章节找出来。Donaldson 和 Preston 是 1995 年那篇吗？"
            ),
            spkSeg(
                sp2,
                start: 100,
                end: 114,
                text: "对，就是讲工具性、规范性和描述性分类的那篇。周五前提交修改稿，我会在截止日期前给你最终反馈。"
            ),
        ]

        var meeting = MeetingNote(
            title: "与 Lee 教授的项目会面",
            createdAt: date,
            modifiedAt: date,
            recordingMode: .onlineMeeting,
            spaceID: SeedSpaceID.businessEthics
        )
        meeting.duration = 114
        meeting.speakers = speakers
        meeting.segments = segments
        meeting.speakerSegments = speakerSegments
        meeting.hasSpeakerData = true
        meeting.summary = "与 Lee 教授审阅了商业伦理案例研究初稿。主要反馈：把供应链工人纳入利益相关方分析，补充 Freeman 以及 Donaldson & Preston 的文献引用。修改稿周五前提交。"
        meeting.isPinned = false
        meeting.tags = ["答疑"]
        meeting.actionItems = [
            ActionItem(
                title: "修改利益相关方一节，纳入供应链工人",
                assignee: "你",
                dueDescription: "周五前",
                dueDate: due(2)
            ),
            ActionItem(
                title: "在理论框架中补充 Freeman 和 Donaldson & Preston 的引用",
                assignee: "你",
                dueDescription: "周五前",
                dueDate: due(2)
            ),
            ActionItem(title: "提交修改稿", assignee: "你", dueDescription: "周五", dueDate: due(3)),
        ]
        meeting.bookmarks = [
            Bookmark(label: "利益相关方反馈", timestamp: 44, color: .red),
            Bookmark(label: "引用建议", timestamp: 72, color: .blue),
            Bookmark(label: "截止日期已确认", timestamp: 100, color: .orange),
        ]
        meeting.smartMinutes = SmartMinutes(
            keyDecisions: [
                "将供应链工人作为关键利益相关方纳入分析",
                "修改稿截止日期定为周五",
            ],
            discussionPoints: [
                "Patagonia 案例分析整体扎实",
                "利益相关方一节缺少供应链劳动视角",
                "理论框架需要加强文献引用",
                "建议引用 Freeman 的利益相关者理论和 Donaldson & Preston（1995）",
            ],
            actionItems: [
                "在利益相关方一节补充供应链劳动实践",
                "补充 Freeman 和 Donaldson & Preston 的参考文献",
                "周五前提交修改稿以获取最终反馈",
            ],
            followUps: [
                "Lee 教授在周五提交后给出最终反馈",
                "整合最后一轮反馈后提交期末论文",
            ],
            attendeeSummary: [
                AttendeeContribution(name: "你", keyPoints: ["汇报初稿进展", "明确待补充内容"], speakingTimePercent: 45),
                AttendeeContribution(
                    name: "Lee 教授",
                    keyPoints: ["指出利益相关方缺口", "推荐关键文献"],
                    speakingTimePercent: 55
                ),
            ]
        )
        return meeting
    }

    // MARK: - Meeting 5: Trip Planning Call

    private static func makeMeeting5(date: Date) -> MeetingNote {
        let sp1 = "speaker-you", sp2 = "speaker-kai"
        let speakers = [
            Speaker(id: sp1, name: "你", color: AppThemeConstants.speakerBlurple),
            Speaker(id: sp2, name: "Kai", color: AppThemeConstants.speakerCyan),
        ]
        let segments = [
            seg(
                "好，我们把日本之行定下来。9 月有两周时间——我想去东京、京都和大阪。",
                start: 0,
                end: 14,
                speaker: "你"
            ),
            seg(
                "这条路线很好。我建议东京五天、京都四天、大阪三天。这样还能留出几天安排一日游。",
                start: 14,
                end: 30,
                speaker: "Kai"
            ),
            seg(
                "完美。在东京我想去涩谷、秋叶原，还有筑地场外市场。也许再加个镰仓一日游？",
                start: 30,
                end: 46,
                speaker: "你"
            ),
            seg(
                "镰仓是个好主意。我们应该买 JR Pass——城市之间的新干线和镰仓一日游都能覆盖。",
                start: 46,
                end: 60,
                speaker: "Kai"
            ),
            seg(
                "对，14 天通票大概五万日元，很值。住宿呢——酒店还是日式旅馆？",
                start: 60,
                end: 74,
                speaker: "你"
            ),
            seg(
                "东京和大阪住酒店，但京都一定要住一次日式旅馆。岚山有一家带私人温泉的房间。",
                start: 74,
                end: 90,
                speaker: "Kai"
            ),
            seg(
                "听起来太棒了。预算方面，我想不含机票的话，每人控制在三千美元左右。",
                start: 90,
                end: 104,
                speaker: "你"
            ),
            seg(
                "可以做到。接下来两周内订机票最便宜。我看到旧金山往返大概八百美元。",
                start: 104,
                end: 120,
                speaker: "Kai"
            ),
        ]
        let speakerSegments = [
            spkSeg(
                sp1,
                start: 0,
                end: 14,
                text: "好，我们把日本之行定下来。9 月有两周时间——我想去东京、京都和大阪。"
            ),
            spkSeg(
                sp2,
                start: 14,
                end: 30,
                text: "这条路线很好。我建议东京五天、京都四天、大阪三天。这样还能留出几天安排一日游。"
            ),
            spkSeg(
                sp1,
                start: 30,
                end: 46,
                text: "完美。在东京我想去涩谷、秋叶原，还有筑地场外市场。也许再加个镰仓一日游？"
            ),
            spkSeg(
                sp2,
                start: 46,
                end: 60,
                text: "镰仓是个好主意。我们应该买 JR Pass——城市之间的新干线和镰仓一日游都能覆盖。"
            ),
            spkSeg(
                sp1,
                start: 60,
                end: 74,
                text: "对，14 天通票大概五万日元，很值。住宿呢——酒店还是日式旅馆？"
            ),
            spkSeg(
                sp2,
                start: 74,
                end: 90,
                text: "东京和大阪住酒店，但京都一定要住一次日式旅馆。岚山有一家带私人温泉的房间。"
            ),
            spkSeg(
                sp1,
                start: 90,
                end: 104,
                text: "听起来太棒了。预算方面，我想不含机票的话，每人控制在三千美元左右。"
            ),
            spkSeg(
                sp2,
                start: 104,
                end: 120,
                text: "可以做到。接下来两周内订机票最便宜。我看到旧金山往返大概八百美元。"
            ),
        ]

        var meeting = MeetingNote(
            title: "旅行计划通话",
            createdAt: date,
            modifiedAt: date,
            recordingMode: .inPerson,
            spaceID: SeedSpaceID.personal
        )
        meeting.duration = 120
        meeting.speakers = speakers
        meeting.segments = segments
        meeting.speakerSegments = speakerSegments
        meeting.hasSpeakerData = true
        meeting.summary = "规划了 9 月的两周日本之行，覆盖东京、京都和大阪。确定了行程分配、JR Pass、京都的日式旅馆，以及不含机票每人 3000 美元的预算。"
        meeting.isPinned = false
        meeting.tags = ["旅行", "日本"]
        meeting.actionItems = [
            ActionItem(title: "两周内预订旧金山出发的机票", assignee: "Kai", dueDescription: "未来两周", dueDate: due(10)),
            ActionItem(title: "预订京都岚山的日式旅馆", assignee: "你", dueDescription: "本月", dueDate: due(14)),
            ActionItem(title: "购买 14 天 JR Pass", assignee: "你", dueDescription: "出发前", dueDate: due(21)),
        ]
        meeting.bookmarks = [
            Bookmark(label: "行程分配", timestamp: 14, color: .blue),
            Bookmark(label: "JR Pass 方案", timestamp: 46, color: .purple),
            Bookmark(label: "预算讨论", timestamp: 90, color: .orange),
        ]
        meeting.smartMinutes = SmartMinutes(
            keyDecisions: [
                "路线：东京（5 天）→ 京都（4 天）→ 大阪（3 天），另留缓冲日",
                "京都岚山住日式旅馆；东京和大阪住酒店",
                "预算：不含机票每人约 3000 美元",
            ],
            discussionPoints: [
                "东京亮点：涩谷、秋叶原、筑地，镰仓一日游",
                "14 天 JR Pass 覆盖新干线和一日游（约 5 万日元）",
                "尽早订票，旧金山往返约 800 美元",
                "岚山带私人温泉的日式旅馆",
            ],
            actionItems: [
                "Kai 两周内订机票，争取最优价格",
                "预订岚山的日式旅馆",
                "出发前购买 JR Pass",
            ],
            followUps: [
                "研究想去的餐厅以及需要提前预订的项目",
                "了解随身 Wi-Fi 租赁",
            ],
            attendeeSummary: [
                AttendeeContribution(name: "你", keyPoints: ["提出路线和东京行程", "确定预算目标"], speakingTimePercent: 50),
                AttendeeContribution(name: "Kai", keyPoints: ["建议时间分配和日式旅馆", "查到机票价格"], speakingTimePercent: 50),
            ]
        )
        return meeting
    }

    // MARK: - Meeting 6: Contract Review — Meridian Deal (Legal, .presentation)

    private static func makeMeeting6(date: Date) -> MeetingNote {
        let sp1 = "speaker-rebecca", sp2 = "speaker-michael", sp3 = "speaker-lisa"
        let speakers = [
            Speaker(id: sp1, name: "Rebecca", color: AppThemeConstants.speakerBlurple),
            Speaker(id: sp2, name: "Michael", color: AppThemeConstants.speakerGreen),
            Speaker(id: sp3, name: "Lisa", color: AppThemeConstants.speakerOrange),
        ]
        let segments = [
            seg(
                "大家早上好。我们过一遍 Meridian Technologies 的合作协议。Michael，责任条款你看过了吗？",
                start: 0,
                end: 14,
                speaker: "Rebecca"
            ),
            seg(
                "看过了。第 4 条的赔偿条款范围太宽。他们要求我们对任何第三方知识产权索赔进行赔偿，这类合作里这很不寻常。",
                start: 14,
                end: 30,
                speaker: "Michael"
            ),
            seg(
                "我同意。在我们的标准模板里，赔偿仅限于我们工作成果造成的直接损失。这一条远远超出了。",
                start: 30,
                end: 44,
                speaker: "Lisa"
            ),
            seg(
                "我们以互相赔偿条款作为反提案，并把责任上限设为合同金额的两倍。Nexus 那笔交易就是这么做的。",
                start: 44,
                end: 60,
                speaker: "Rebecca"
            ),
            seg(
                "这个参照很好。保密协议部分没问题，标准的十二个月尾期。但第 7 条的竞业限制有问题——它会让我们两年内不能与任何金融科技客户合作。",
                start: 60,
                end: 80,
                speaker: "Michael"
            ),
            seg(
                "这完全没法接受。我们有三家正在合作的金融科技客户。我建议把它收窄到仅限 Meridian 的直接竞争对手，而不是整个行业。",
                start: 80,
                end: 96,
                speaker: "Lisa"
            ),
            seg(
                "正是如此。我今天起草红线稿。Michael，你能准备带财务情景的责任上限分析吗？Lisa，请把 Nexus 的赔偿条款先例找出来。",
                start: 96,
                end: 116,
                speaker: "Rebecca"
            ),
            seg(
                "没问题。我还会标注终止条款——他们的任意终止只需提前七天通知，留给我们的过渡时间不够。",
                start: 116,
                end: 132,
                speaker: "Michael"
            ),
            seg(
                "发现得好。我们争取至少三十天。Rebecca，客户通话安排在周四还是周五？",
                start: 132,
                end: 146,
                speaker: "Lisa"
            ),
            seg(
                "周四下午最合适。我希望周三完成红线稿，这样通话前可以内部对齐。我们收尾吧——大家都清楚待办事项了吗？",
                start: 146,
                end: 164,
                speaker: "Rebecca"
            ),
        ]
        let speakerSegments = [
            spkSeg(
                sp1,
                start: 0,
                end: 14,
                text: "大家早上好。我们过一遍 Meridian Technologies 的合作协议。Michael，责任条款你看过了吗？"
            ),
            spkSeg(
                sp2,
                start: 14,
                end: 30,
                text: "看过了。第 4 条的赔偿条款范围太宽。他们要求我们对任何第三方知识产权索赔进行赔偿，这类合作里这很不寻常。"
            ),
            spkSeg(
                sp3,
                start: 30,
                end: 44,
                text: "我同意。在我们的标准模板里，赔偿仅限于我们工作成果造成的直接损失。这一条远远超出了。"
            ),
            spkSeg(
                sp1,
                start: 44,
                end: 60,
                text: "我们以互相赔偿条款作为反提案，并把责任上限设为合同金额的两倍。Nexus 那笔交易就是这么做的。"
            ),
            spkSeg(
                sp2,
                start: 60,
                end: 80,
                text: "这个参照很好。保密协议部分没问题，标准的十二个月尾期。但第 7 条的竞业限制有问题——它会让我们两年内不能与任何金融科技客户合作。"
            ),
            spkSeg(
                sp3,
                start: 80,
                end: 96,
                text: "这完全没法接受。我们有三家正在合作的金融科技客户。我建议把它收窄到仅限 Meridian 的直接竞争对手，而不是整个行业。"
            ),
            spkSeg(
                sp1,
                start: 96,
                end: 116,
                text: "正是如此。我今天起草红线稿。Michael，你能准备带财务情景的责任上限分析吗？Lisa，请把 Nexus 的赔偿条款先例找出来。"
            ),
            spkSeg(
                sp2,
                start: 116,
                end: 132,
                text: "没问题。我还会标注终止条款——他们的任意终止只需提前七天通知，留给我们的过渡时间不够。"
            ),
            spkSeg(
                sp3,
                start: 132,
                end: 146,
                text: "发现得好。我们争取至少三十天。Rebecca，客户通话安排在周四还是周五？"
            ),
            spkSeg(
                sp1,
                start: 146,
                end: 164,
                text: "周四下午最合适。我希望周三完成红线稿，这样通话前可以内部对齐。我们收尾吧——大家都清楚待办事项了吗？"
            ),
        ]

        var meeting = MeetingNote(
            title: "合同评审——Meridian 交易",
            createdAt: date,
            modifiedAt: date,
            recordingMode: .onlineMeeting,
            template: .presentation,
            spaceID: SeedSpaceID.legal
        )
        meeting.duration = 164
        meeting.speakers = speakers
        meeting.segments = segments
        meeting.speakerSegments = speakerSegments
        meeting.hasSpeakerData = true
        meeting.summary = "审阅了 Meridian Technologies 的合作协议。主要问题：赔偿条款范围过宽（以互相赔偿 + 两倍上限作为反提案）、竞业限制过广（收窄至直接竞争对手）、终止通知期过短（争取 30 天）。周三完成红线稿，周四与客户通话。"
        meeting.isPinned = true
        meeting.tags = ["合同", "Meridian", "评审"]
        meeting.topicKeywords = ["合同", "责任", "赔偿", "NDA", "竞业限制"]
        meeting.transcriptionLanguage = "en"
        meeting.calendarEventID = "CAL-MERIDIAN-2026-03"
        meeting.scheduledStartTime = date
        meeting.actionItems = [
            ActionItem(
                title: "起草合同红线稿及反提案",
                assignee: "Rebecca",
                dueDescription: "周三",
                isCompleted: true,
                dueDate: due(1)
            ),
            ActionItem(
                title: "准备带财务情景的责任上限分析",
                assignee: "Michael",
                dueDescription: "周三",
                dueDate: due(1),
                reminderDate: due(0)
            ),
            ActionItem(
                title: "整理 Nexus 交易的赔偿条款作为先例",
                assignee: "Lisa",
                dueDescription: "周二",
                isCompleted: true,
                dueDate: due(0)
            ),
            ActionItem(
                title: "安排周四下午的客户通话",
                assignee: "Rebecca",
                dueDescription: "今天",
                isCompleted: true,
                dueDate: due(0)
            ),
            ActionItem(
                title: "标注终止条款——争取至少 30 天通知期",
                assignee: "Michael",
                dueDescription: "写入红线稿",
                dueDate: due(1)
            ),
        ]
        meeting.bookmarks = [
            Bookmark(label: "赔偿条款问题", timestamp: 14, color: .red),
            Bookmark(label: "责任上限方案", timestamp: 44, color: .blue),
            Bookmark(label: "竞业限制问题", timestamp: 60, color: .yellow),
            Bookmark(label: "待办事项", timestamp: 96, color: .purple),
            Bookmark(label: "终止条款", timestamp: 116, color: .orange),
        ]
        meeting.chatMessages = [
            MeetingChatMessage(role: .user, content: "这条宽泛的赔偿条款到底有什么风险？"),
            MeetingChatMessage(
                role: .assistant,
                content: "第 4 条的赔偿条款要求你方承担任何第三方知识产权索赔，即使这些索赔与你的工作成果无关。这意味着如果 Meridian 因其自有技术被诉专利侵权，他们也可能向你方寻求赔偿。标准做法——也就是 Rebecca 提出的方案——是互相赔偿，且仅限各方自身工作引起的直接损失，同时设置责任上限（本例为合同金额的两倍）。这样能按比例保护双方。"
            ),
        ]
        meeting.smartMinutes = SmartMinutes(
            keyDecisions: [
                "以互相赔偿条款反提案，责任上限为合同金额两倍",
                "将竞业限制从整个金融科技行业收窄至 Meridian 的直接竞争对手",
                "将终止通知期从 7 天争取到至少 30 天",
                "客户通话定在周四下午",
            ],
            discussionPoints: [
                "第 4 条赔偿范围过宽——覆盖工作成果之外的第三方知识产权索赔",
                "保密协议部分可接受，标准的 12 个月尾期",
                "第 7 条竞业限制会阻碍与 3 家现有金融科技客户的合作",
                "任意终止仅提前 7 天通知，不足以完成过渡",
                "Nexus 交易的先例曾成功用于类似赔偿条款",
            ],
            actionItems: [
                "Rebecca 周三前完成红线稿",
                "Michael 准备责任上限的财务分析",
                "Lisa 整理 Nexus 的赔偿条款先例",
                "Michael 在红线稿中处理终止条款",
            ],
            followUps: [
                "周三内部对齐会，在客户通话前审阅红线稿",
                "周四下午客户通话，提出反提案",
            ],
            attendeeSummary: [
                AttendeeContribution(
                    name: "Rebecca",
                    keyPoints: ["主持讨论", "提出责任上限方案", "确定时间表"],
                    speakingTimePercent: 40
                ),
                AttendeeContribution(
                    name: "Michael",
                    keyPoints: ["指出赔偿和终止条款问题", "提及保密协议审查"],
                    speakingTimePercent: 35
                ),
                AttendeeContribution(name: "Lisa", keyPoints: ["指出竞业限制风险", "建议收窄范围"], speakingTimePercent: 25),
            ]
        )
        return meeting
    }

    // MARK: - Meeting 7: Compliance Training Standup (Legal, .standup, voiceNote, archived)

    private static func makeMeeting7(date: Date) -> MeetingNote {
        let segments = [
            seg(
                "快速同步一下合规进展。GDPR 审计准备按计划进行——七项数据保护影响评估已完成四项。剩下三项分别涉及分析管线、客户支持工具和新的营销平台。",
                start: 0,
                end: 18,
                speaker: "发言人"
            ),
            seg(
                "全公司培训完成率是 82%。工程和法务是 100%。销售和市场落后，大约 65%。我已经发了提醒，并把下周五定为硬性截止日期。",
                start: 18,
                end: 36,
                speaker: "发言人"
            ),
            seg(
                "Cookie 同意横幅的更新昨天上线了。我们现在符合最新的 ePrivacy 指南。分析显示选择加入率为 43%，其实高于行业平均水平。",
                start: 36,
                end: 52,
                speaker: "发言人"
            ),
            seg(
                "有一个阻塞项——数据删除 API 接口仍在开发中。工程说还需要一周。我把它标为高优先级，因为这是 GDPR 第 17 条合规所必需的。这是目前的主要风险项。",
                start: 52,
                end: 70,
                speaker: "发言人"
            ),
            seg(
                "下一步：我会跟进销售管理层，补齐培训缺口；周一我和外部审计师有一次通话，审阅 DPIA 文档。今天就这些。",
                start: 70,
                end: 84,
                speaker: "发言人"
            ),
        ]

        var meeting = MeetingNote(
            title: "合规培训站会",
            createdAt: date,
            modifiedAt: date,
            recordingMode: .voiceNote,
            template: .standup,
            spaceID: SeedSpaceID.legal
        )
        meeting.duration = 84
        meeting.segments = segments
        meeting.hasSpeakerData = false
        meeting.isArchived = true
        meeting.summary = "关于合规状态的语音站会。GDPR 审计：7 项 DPIA 已完成 4 项。培训完成率 82%（销售和市场落后）。Cookie 同意横幅已上线，选择加入率 43%。阻塞项：数据删除 API 还需一周。"
        meeting.tags = ["合规", "站会", "GDPR"]
        meeting.topicKeywords = ["GDPR", "合规", "审计", "培训", "Cookie 同意", "数据删除"]
        meeting.actionItems = [
            ActionItem(
                title: "完成剩余 3 项 DPIA（分析、支持、营销）",
                assignee: "Rebecca",
                dueDescription: "月底",
                dueDate: due(7)
            ),
            ActionItem(
                title: "跟进销售管理层的培训完成情况",
                assignee: "Rebecca",
                dueDescription: "本周",
                isCompleted: true,
                dueDate: due(-1)
            ),
            ActionItem(title: "与外部审计师通话——审阅 DPIA 文档", assignee: "Rebecca", dueDescription: "周一", dueDate: due(2)),
        ]
        meeting.smartMinutes = SmartMinutes(
            keyDecisions: [
                "培训完成的硬性截止日期定为下周五",
                "数据删除 API 被标记为高优先级阻塞项",
            ],
            discussionPoints: [
                "7 项 DPIA 已完成 4 项；剩余涉及分析、支持工具和营销平台",
                "全公司培训完成率 82%——工程和法务 100%，销售和市场 65%",
                "Cookie 同意横幅已上线，选择加入率 43%（高于行业平均）",
                "数据删除 API 还需工程再开发一周",
            ],
            actionItems: [
                "跟进销售管理层的培训缺口",
                "周一向外部审计师通话，审阅 DPIA",
                "与工程负责人升级沟通数据删除 API 的时间表",
            ],
            followUps: [
                "周五截止前再核对一次培训数据",
                "周中检查数据删除 API 的进展",
            ],
            attendeeSummary: []
        )
        return meeting
    }

    // MARK: - Meeting 8: Patient Case Conference (Healthcare, .oneOnOne)

    private static func makeMeeting8(date: Date) -> MeetingNote {
        let sp1 = "speaker-dr-chen", sp2 = "speaker-dr-patel"
        let speakers = [
            Speaker(id: sp1, name: "Chen 医生", color: AppThemeConstants.speakerBlurple),
            Speaker(id: sp2, name: "Patel 医生", color: AppThemeConstants.speakerPink),
        ]
        let segments = [
            seg(
                "感谢会诊，Patel 医生。患者女性，42 岁，表现为六周乏力和双手关节对称性疼痛。晨僵持续约四十五分钟。",
                start: 0,
                end: 16,
                speaker: "Chen 医生"
            ),
            seg(
                "化验结果出来了吗？",
                start: 16,
                end: 20,
                speaker: "Patel 医生"
            ),
            seg(
                "出来了——RF 阳性，68；抗 CCP 升高，92。ESR 和 CRP 都升高。ANA 弱阳性，1:80。",
                start: 20,
                end: 36,
                speaker: "Chen 医生"
            ),
            seg(
                "这是类风湿关节炎很强的血清学表现。结合临床表现——小关节对称受累、晨僵时间延长，以及 RF 和抗 CCP 阳性——她符合 2010 ACR/EULAR 标准。",
                start: 36,
                end: 56,
                speaker: "Patel 医生"
            ),
            seg(
                "我也是这么想的。她母亲有类风湿关节炎，妹妹有狼疮。考虑到 ANA 阳性，我需要担心重叠综合征吗？",
                start: 56,
                end: 70,
                speaker: "Chen 医生"
            ),
            seg(
                "ANA 1:80 属于低滴度且不特异——类风湿关节炎中也会出现，并不代表狼疮。我会查 dsDNA 和补体水平来排除，但临床情况明确指向类风湿关节炎。",
                start: 70,
                end: 90,
                speaker: "Patel 医生"
            ),
            seg(
                "你推荐怎么治疗？她目前在用左甲状腺素治疗甲减，必要时服用布洛芬。",
                start: 90,
                end: 104,
                speaker: "Chen 医生"
            ),
            seg(
                "我建议从每周 15mg 甲氨蝶呤开始——这是中度类风湿关节炎的一线治疗。每天加 1mg 叶酸以减少副作用。开始用药前应该查肝功能和血常规基线。",
                start: 104,
                end: 124,
                speaker: "Patel 医生"
            ),
            seg(
                "有道理。如果单用甲氨蝶呤效果不够呢？",
                start: 124,
                end: 132,
                speaker: "Chen 医生"
            ),
            seg(
                "那我们会考虑加用生物制剂——根据她的情况，可能是 TNF 抑制剂或 JAK 抑制剂。但先给甲氨蝶呤十二周评估疗效，再考虑升级。四周后她到我的门诊做风湿科基线评估。",
                start: 132,
                end: 154,
                speaker: "Patel 医生"
            ),
        ]
        let speakerSegments = [
            spkSeg(
                sp1,
                start: 0,
                end: 16,
                text: "感谢会诊，Patel 医生。患者女性，42 岁，表现为六周乏力和双手关节对称性疼痛。晨僵持续约四十五分钟。"
            ),
            spkSeg(sp2, start: 16, end: 20, text: "化验结果出来了吗？"),
            spkSeg(
                sp1,
                start: 20,
                end: 36,
                text: "出来了——RF 阳性，68；抗 CCP 升高，92。ESR 和 CRP 都升高。ANA 弱阳性，1:80。"
            ),
            spkSeg(
                sp2,
                start: 36,
                end: 56,
                text: "这是类风湿关节炎很强的血清学表现。结合临床表现——小关节对称受累、晨僵时间延长，以及 RF 和抗 CCP 阳性——她符合 2010 ACR/EULAR 标准。"
            ),
            spkSeg(
                sp1,
                start: 56,
                end: 70,
                text: "我也是这么想的。她母亲有类风湿关节炎，妹妹有狼疮。考虑到 ANA 阳性，我需要担心重叠综合征吗？"
            ),
            spkSeg(
                sp2,
                start: 70,
                end: 90,
                text: "ANA 1:80 属于低滴度且不特异——类风湿关节炎中也会出现，并不代表狼疮。我会查 dsDNA 和补体水平来排除，但临床情况明确指向类风湿关节炎。"
            ),
            spkSeg(
                sp1,
                start: 90,
                end: 104,
                text: "你推荐怎么治疗？她目前在用左甲状腺素治疗甲减，必要时服用布洛芬。"
            ),
            spkSeg(
                sp2,
                start: 104,
                end: 124,
                text: "我建议从每周 15mg 甲氨蝶呤开始——这是中度类风湿关节炎的一线治疗。每天加 1mg 叶酸以减少副作用。开始用药前应该查肝功能和血常规基线。"
            ),
            spkSeg(sp1, start: 124, end: 132, text: "有道理。如果单用甲氨蝶呤效果不够呢？"),
            spkSeg(
                sp2,
                start: 132,
                end: 154,
                text: "那我们会考虑加用生物制剂——根据她的情况，可能是 TNF 抑制剂或 JAK 抑制剂。但先给甲氨蝶呤十二周评估疗效，再考虑升级。四周后她到我的门诊做风湿科基线评估。"
            ),
        ]

        var meeting = MeetingNote(
            title: "患者病例讨论会",
            createdAt: date,
            modifiedAt: date,
            recordingMode: .inPerson,
            template: .oneOnOne,
            spaceID: SeedSpaceID.healthcare
        )
        meeting.duration = 154
        meeting.speakers = speakers
        meeting.segments = segments
        meeting.speakerSegments = speakerSegments
        meeting.hasSpeakerData = true
        meeting.summary = "42 岁女性的风湿科会诊，表现为乏力和双手关节对称性疼痛。检查显示 RF 阳性（68）、抗 CCP 升高（92），炎症指标升高。诊断：符合 2010 ACR/EULAR 标准的类风湿关节炎。方案：开始每周 15mg 甲氨蝶呤并补充叶酸，4 周后风湿科随访。"
        meeting.isPinned = true
        meeting.tags = ["病例讨论", "风湿科"]
        meeting.topicKeywords = ["患者", "诊断", "治疗", "类风湿关节炎", "甲氨蝶呤"]
        meeting.transcriptionLanguage = "en"
        meeting.actionItems = [
            ActionItem(
                title: "开始甲氨蝶呤前开具血常规和肝功能基线检查",
                assignee: "Chen 医生",
                dueDescription: "治疗前",
                isCompleted: true,
                dueDate: due(-1),
                reminderDate: due(-2)
            ),
            ActionItem(
                title: "处方甲氨蝶呤每周 15mg + 叶酸每日 1mg",
                assignee: "Chen 医生",
                dueDescription: "下次就诊时",
                isCompleted: true,
                dueDate: due(0)
            ),
            ActionItem(
                title: "开具 dsDNA 和补体检查，排除狼疮重叠",
                assignee: "Chen 医生",
                dueDescription: "随基线检查",
                isCompleted: true,
                dueDate: due(-1)
            ),
            ActionItem(
                title: "安排 4 周后的风湿科基线随访",
                assignee: "Patel 医生",
                dueDescription: "4 周后",
                isCompleted: true,
                dueDate: due(0),
                reminderDate: due(-1)
            ),
        ]
        meeting.bookmarks = [
            Bookmark(label: "化验结果", timestamp: 20, color: .blue),
            Bookmark(label: "类风湿关节炎诊断", timestamp: 36, color: .purple),
            Bookmark(label: "ANA 讨论", timestamp: 70, color: .yellow),
            Bookmark(label: "治疗方案", timestamp: 104, color: .orange),
        ]
        meeting.chatMessages = [
            MeetingChatMessage(role: .user, content: "甲氨蝶呤的主要副作用有哪些，我需要向患者交代？"),
            MeetingChatMessage(
                role: .assistant,
                content: "甲氨蝶呤治疗类风湿关节炎最常见的副作用包括：（1）胃肠道症状——恶心、口腔溃疡和食欲下降，补充叶酸有助于减轻；（2）肝毒性——需要基线和定期肝功能监测；（3）骨髓抑制——定期监测血常规；（4）免疫抑制导致感染风险增加。较少见但很重要：肺毒性（肺炎）和致畸性——育龄女性必须避孕。"
            ),
            MeetingChatMessage(role: .user, content: "需要担心和她用的左甲状腺素发生药物相互作用吗？"),
            MeetingChatMessage(
                role: .assistant,
                content: "甲氨蝶呤和左甲状腺素没有明显的直接相互作用。不过甲氨蝶呤会影响肝脏代谢和蛋白结合，所以开始用药后 6–8 周复查 TSH 比较稳妥，以确认甲状腺激素水平稳定。通常不需要一开始就调整剂量。"
            ),
        ]
        meeting.smartMinutes = SmartMinutes(
            keyDecisions: [
                "诊断：依据 2010 ACR/EULAR 标准诊断为类风湿关节炎",
                "一线治疗：每周 15mg 甲氨蝶呤，每日 1mg 叶酸",
                "通过 dsDNA 和补体水平排除狼疮重叠",
                "12 周时复评；疗效不足则升级为生物制剂",
            ],
            discussionPoints: [
                "表现：42 岁女性，乏力及双手关节对称性疼痛 6 周，晨僵 45 分钟",
                "化验：RF 68（阳性）、抗 CCP 92（升高）、ESR 和 CRP 升高、ANA 1:80（弱阳性）",
                "家族史：母亲患类风湿关节炎，妹妹患狼疮",
                "低滴度 ANA 在类风湿关节炎中不特异——不提示狼疮",
                "甲氨蝶呤是中度类风湿关节炎的一线用药；生物制剂用于疗效不佳者",
            ],
            actionItems: [
                "Chen 医生开具基线检查（血常规、肝功能、dsDNA、补体）",
                "Chen 医生在下次就诊时处方甲氨蝶呤 + 叶酸",
                "Patel 医生 4 周后接诊患者，做风湿科基线评估",
            ],
            followUps: [
                "12 周时评估甲氨蝶呤疗效",
                "疗效不足时考虑生物制剂（TNF 抑制剂或 JAK 抑制剂）",
                "开始甲氨蝶呤后 6–8 周复查 TSH",
            ],
            attendeeSummary: [
                AttendeeContribution(
                    name: "Chen 医生",
                    keyPoints: ["汇报病例和化验结果", "询问狼疮重叠和药物相互作用"],
                    speakingTimePercent: 45
                ),
                AttendeeContribution(
                    name: "Patel 医生",
                    keyPoints: ["确认类风湿关节炎诊断", "推荐甲氨蝶呤方案", "解答 ANA 相关疑问"],
                    speakingTimePercent: 55
                ),
            ]
        )
        return meeting
    }

    // MARK: - Meeting 9: Research Protocol Brainstorm (Healthcare, .brainstorm)

    private static func makeMeeting9(date: Date) -> MeetingNote {
        let sp1 = "speaker-dr-nakamura", sp2 = "speaker-kate", sp3 = "speaker-dr-wong"
        let speakers = [
            Speaker(id: sp1, name: "Nakamura 医生", color: AppThemeConstants.speakerBlurple),
            Speaker(id: sp2, name: "Kate", color: AppThemeConstants.speakerCyan),
            Speaker(id: sp3, name: "Wong 医生", color: AppThemeConstants.speakerPink),
        ]
        let segments = [
            seg(
                "我们来头脑风暴 II 期方案设计。下个月提交 IND 之前，需要敲定入组标准和终点策略。",
                start: 0,
                end: 14,
                speaker: "Nakamura 医生"
            ),
            seg(
                "我看了一些同类试验。多数 II 期类风湿关节炎试验入组 200 到 300 例，按低剂量、高剂量和安慰剂做 1:1:1 随机分组。",
                start: 14,
                end: 30,
                speaker: "Kate"
            ),
            seg(
                "240 例是我们的理想规模——每组 80 例，假设与安慰剂相差 25 个百分点，ACR20 主要终点可达到 90% 的检验效能。",
                start: 30,
                end: 46,
                speaker: "Wong 医生"
            ),
            seg(
                "剂量怎么选？I 期 PK 数据提示 5mg 和 15mg 覆盖了目标暴露范围。",
                start: 46,
                end: 60,
                speaker: "Nakamura 医生"
            ),
            seg(
                "5mg 剂量显示出良好的 JAK1 选择性，对 JAK2 的抑制很小。15mg 的疗效信号更强，但需要密切监测血液学指标。",
                start: 60,
                end: 78,
                speaker: "Kate"
            ),
            seg(
                "我建议在第 8 周中期增加一次数据安全监查委员会（DSMB）审查。如果出现意外的肝毒性或明显的血细胞减少，我们可以暂停入组。",
                start: 78,
                end: 96,
                speaker: "Wong 医生"
            ),
            seg(
                "好主意。患者人群呢？我们讨论过把甲氨蝶呤应答不足作为入选标准。",
                start: 96,
                end: 110,
                speaker: "Nakamura 医生"
            ),
            seg(
                "这对这类药物是标准做法。我还建议排除既往使用过 JAK 抑制剂的患者，保持人群纯净。另外要考虑中心选择——我提议在美国和加拿大设 18 个中心。",
                start: 110,
                end: 130,
                speaker: "Kate"
            ),
            seg(
                "18 个中心应该能保证不错的入组速度。目标是 12 到 14 个月完成全部入组。有一点我想提出来——FDA 最近一直在关注 JAK 抑制剂的心血管安全性。我们应该把 MACE 作为探索性终点。",
                start: 130,
                end: 152,
                speaker: "Wong 医生"
            ),
            seg(
                "完全同意，加上它。Kate，你能本周起草完整的方案文档吗？我想在周五前发给顾问委员会。",
                start: 152,
                end: 166,
                speaker: "Nakamura 医生"
            ),
        ]
        let speakerSegments = [
            spkSeg(
                sp1,
                start: 0,
                end: 14,
                text: "我们来头脑风暴 II 期方案设计。下个月提交 IND 之前，需要敲定入组标准和终点策略。"
            ),
            spkSeg(
                sp2,
                start: 14,
                end: 30,
                text: "我看了一些同类试验。多数 II 期类风湿关节炎试验入组 200 到 300 例，按低剂量、高剂量和安慰剂做 1:1:1 随机分组。"
            ),
            spkSeg(
                sp3,
                start: 30,
                end: 46,
                text: "240 例是我们的理想规模——每组 80 例，假设与安慰剂相差 25 个百分点，ACR20 主要终点可达到 90% 的检验效能。"
            ),
            spkSeg(
                sp1,
                start: 46,
                end: 60,
                text: "剂量怎么选？I 期 PK 数据提示 5mg 和 15mg 覆盖了目标暴露范围。"
            ),
            spkSeg(
                sp2,
                start: 60,
                end: 78,
                text: "5mg 剂量显示出良好的 JAK1 选择性，对 JAK2 的抑制很小。15mg 的疗效信号更强，但需要密切监测血液学指标。"
            ),
            spkSeg(
                sp3,
                start: 78,
                end: 96,
                text: "我建议在第 8 周中期增加一次数据安全监查委员会（DSMB）审查。如果出现意外的肝毒性或明显的血细胞减少，我们可以暂停入组。"
            ),
            spkSeg(
                sp1,
                start: 96,
                end: 110,
                text: "好主意。患者人群呢？我们讨论过把甲氨蝶呤应答不足作为入选标准。"
            ),
            spkSeg(
                sp2,
                start: 110,
                end: 130,
                text: "这对这类药物是标准做法。我还建议排除既往使用过 JAK 抑制剂的患者，保持人群纯净。另外要考虑中心选择——我提议在美国和加拿大设 18 个中心。"
            ),
            spkSeg(
                sp3,
                start: 130,
                end: 152,
                text: "18 个中心应该能保证不错的入组速度。目标是 12 到 14 个月完成全部入组。有一点我想提出来——FDA 最近一直在关注 JAK 抑制剂的心血管安全性。我们应该把 MACE 作为探索性终点。"
            ),
            spkSeg(
                sp1,
                start: 152,
                end: 166,
                text: "完全同意，加上它。Kate，你能本周起草完整的方案文档吗？我想在周五前发给顾问委员会。"
            ),
        ]

        var meeting = MeetingNote(
            title: "研究方案头脑风暴",
            createdAt: date,
            modifiedAt: date,
            recordingMode: .onlineMeeting,
            template: .brainstorm,
            spaceID: SeedSpaceID.healthcare
        )
        meeting.duration = 166
        meeting.speakers = speakers
        meeting.segments = segments
        meeting.speakerSegments = speakerSegments
        meeting.hasSpeakerData = true
        meeting.scheduledStartTime = date
        meeting.summary = "围绕 BTC-4501（用于类风湿关节炎的 JAK1 抑制剂）的 II 期临床试验方案进行头脑风暴。关键决定：240 例患者、3 个组别、5mg 和 15mg 剂量、第 12 周 ACR20 主要终点、第 8 周 DSMB 中期审查、18 个试验中心、MACE 作为探索性心血管安全性终点。"
        meeting.isPinned = false
        meeting.tags = ["研究", "方案", "II 期"]
        meeting.topicKeywords = ["试验", "方案", "终点", "入组", "JAK 抑制剂", "ACR20"]
        meeting.actionItems = [
            ActionItem(title: "起草完整的 II 期方案文档", assignee: "Kate", dueDescription: "本周", dueDate: due(-2)),
            ActionItem(title: "将方案发给顾问委员会", assignee: "Nakamura 医生", dueDescription: "周五", dueDate: due(-1)),
            ActionItem(
                title: "敲定中心名单——美国及加拿大 18 个中心",
                assignee: "Kate",
                dueDescription: "IND 提交前",
                dueDate: due(-3)
            ),
            ActionItem(
                title: "将 MACE 列为探索性心血管安全性终点",
                assignee: "Wong 医生",
                dueDescription: "写入方案初稿",
                isCompleted: true,
                dueDate: due(-2)
            ),
        ]
        meeting.bookmarks = [
            Bookmark(label: "样本量依据", timestamp: 30, color: .blue),
            Bookmark(label: "剂量选择", timestamp: 46, color: .purple),
            Bookmark(label: "DSMB 中期审查", timestamp: 78, color: .red),
            Bookmark(label: "心血管安全性终点", timestamp: 130, color: .orange),
        ]
        meeting.smartMinutes = SmartMinutes(
            keyDecisions: [
                "共 240 例患者——每组 80 例（低剂量、高剂量、安慰剂）",
                "剂量：5mg 和 15mg 口服，每日一次",
                "主要终点：第 12 周 ACR20 应答率",
                "第 8 周进行 DSMB 中期安全性审查",
                "在美国和加拿大设 18 个试验中心",
                "将 MACE 列为探索性心血管安全性终点",
            ],
            discussionPoints: [
                "同类试验入组 200–300 例，按 1:1:1 随机分组",
                "ACR20 相对安慰剂差 25 个百分点时，检验效能 90%",
                "I 期 PK 数据支持 5mg 和 15mg 的剂量区间",
                "5mg 显示良好的 JAK1 选择性；15mg 疗效更强但需监测血液学指标",
                "FDA 日益关注 JAK 抑制剂类别的心血管安全性",
                "入组目标：18 个中心，12–14 个月完成",
            ],
            actionItems: [
                "Kate 本周起草完整方案文档",
                "Nakamura 医生周五前发给顾问委员会",
                "Kate 敲定中心名单",
                "Wong 医生纳入 MACE 探索性终点",
            ],
            followUps: [
                "顾问委员会在收到后 2 周内反馈",
                "IND 提交目标：下个月",
                "与 FDA 召开 pre-IND 会议，讨论心血管安全性监测方案",
            ],
            attendeeSummary: [
                AttendeeContribution(
                    name: "Nakamura 医生",
                    keyPoints: ["确定 IND 提交时间表", "主导剂量选择讨论"],
                    speakingTimePercent: 30
                ),
                AttendeeContribution(
                    name: "Kate",
                    keyPoints: ["对标同类试验", "分析 PK 数据支持剂量依据", "提出中心策略"],
                    speakingTimePercent: 35
                ),
                AttendeeContribution(
                    name: "Wong 医生",
                    keyPoints: ["计算样本量", "建议 DSMB 中期审查", "提出心血管安全性终点"],
                    speakingTimePercent: 35
                ),
            ]
        )
        return meeting
    }
}

// swiftlint:enable line_length force_unwrapping function_body_length
// swiftlint:enable file_length
