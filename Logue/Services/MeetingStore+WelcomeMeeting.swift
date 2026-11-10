import Foundation
import SwiftUI

// MARK: - Welcome Meeting Seed Data

extension MeetingStore {
    static func makeWelcomeMeeting() -> MeetingNote {
        let speakers = makeWelcomeSpeakers()
        let segments = makeWelcomeSegments()
        let speakerSegments = makeWelcomeSpeakerSegments(segments: segments)
        let actionItems = makeWelcomeActionItems()
        let bookmarks = makeWelcomeBookmarks()
        let smartMinutes = makeWelcomeSmartMinutes(actionItems: actionItems)

        let summary = "团队一起了解了 Logue 的核心功能，包括实时转写、发言人识别、书签、"
            + "AI 生成的摘要和整理工具。所有处理都在设备端完成，以保护隐私。"
            + "后续将安排一次会议，探索写作功能。"

        return MeetingNote(
            title: "Logue 入门",
            duration: 110,
            segments: segments,
            actionItems: actionItems,
            summary: summary,
            smartMinutes: smartMinutes,
            recordingMode: .inPerson,
            tags: ["getting-started", "demo"],
            template: .general,
            bookmarks: bookmarks,
            topicKeywords: ["转写", "发言人识别", "书签", "AI 摘要", "隐私"],
            hasSpeakerData: true,
            speakers: speakers,
            speakerSegments: speakerSegments
        )
    }

    // MARK: - Speakers

    private static let speaker1ID = "speaker-alice"
    private static let speaker2ID = "speaker-bob"
    private static let speaker3ID = "speaker-carol"

    private static func makeWelcomeSpeakers() -> [Speaker] {
        [
            Speaker(id: speaker1ID, name: "Alice", color: AppThemeConstants.speakerBlurple),
            Speaker(id: speaker2ID, name: "Bob", color: AppThemeConstants.speakerGreen),
            Speaker(id: speaker3ID, name: "Carol", color: AppThemeConstants.speakerOrange),
        ]
    }

    // MARK: - Transcript Segments

    private static func makeWelcomeSegments() -> [TranscriptSegment] {
        [
            TranscriptSegment(
                text: "欢迎大家！我们开始 Logue 里的第一场会议吧。"
                    + "我想带大家过一遍部分功能。",
                startTime: 0, endTime: 12, speakerLabel: "Alice"
            ),
            TranscriptSegment(
                text: "听起来不错。我一直想试试转写功能。"
                    + "发言人识别做得很好。",
                startTime: 12, endTime: 22, speakerLabel: "Bob"
            ),
            TranscriptSegment(
                text: "是啊，而且我很喜欢所有处理都在设备端完成。音频不会上传到"
                    + "云端，这对我们团队的隐私很重要。",
                startTime: 22, endTime: 34, speakerLabel: "Carol"
            ),
            TranscriptSegment(
                text: "没错。要重点介绍的功能有：实时转写、"
                    + "发言人识别、录制中加书签，以及 AI 生成的摘要。",
                startTime: 34, endTime: 48, speakerLabel: "Alice"
            ),
            TranscriptSegment(
                text: "我还注意到可以添加带截止日期和提醒的待办事项。"
                    + "这对后续跟进很有用。",
                startTime: 48, endTime: 58, speakerLabel: "Bob"
            ),
            TranscriptSegment(
                text: "智能纪要功能也很厉害。它会自动整理关键决策、"
                    + "讨论要点和待办事项。",
                startTime: 58, endTime: 70, speakerLabel: "Carol"
            ),
            TranscriptSegment(
                text: "我把这一刻加个书签。录制过程中随时可以添加书签，"
                    + "标记重要时刻。",
                startTime: 70, endTime: 80, speakerLabel: "Alice"
            ),
            TranscriptSegment(
                text: "还有一点——你可以把会议整理到文件夹里并加上标签，"
                    + "方便筛选。会议多的时候特别有用。",
                startTime: 80, endTime: 94, speakerLabel: "Bob"
            ),
            TranscriptSegment(
                text: "介绍得很全面。我觉得我们应该安排下周再跟进一次，"
                    + "也讨论一下写作助手功能。",
                startTime: 94, endTime: 105, speakerLabel: "Carol"
            ),
            TranscriptSegment(
                text: "同意。我们收尾吧。谢谢大家！",
                startTime: 105, endTime: 110, speakerLabel: "Alice"
            ),
        ]
    }

    // MARK: - Speaker Segments

    // Bug-5: Add bounds guard to prevent crash if segment count changes
    private static func makeWelcomeSpeakerSegments(segments: [TranscriptSegment]) -> [SpeakerSegment] {
        guard segments.count >= 10 else { return [] }
        return [
            SpeakerSegment(speakerId: speaker1ID, startTime: 0, endTime: 12, text: segments[0].text),
            SpeakerSegment(speakerId: speaker2ID, startTime: 12, endTime: 22, text: segments[1].text),
            SpeakerSegment(speakerId: speaker3ID, startTime: 22, endTime: 34, text: segments[2].text),
            SpeakerSegment(speakerId: speaker1ID, startTime: 34, endTime: 48, text: segments[3].text),
            SpeakerSegment(speakerId: speaker2ID, startTime: 48, endTime: 58, text: segments[4].text),
            SpeakerSegment(speakerId: speaker3ID, startTime: 58, endTime: 70, text: segments[5].text),
            SpeakerSegment(speakerId: speaker1ID, startTime: 70, endTime: 80, text: segments[6].text),
            SpeakerSegment(speakerId: speaker2ID, startTime: 80, endTime: 94, text: segments[7].text),
            SpeakerSegment(speakerId: speaker3ID, startTime: 94, endTime: 105, text: segments[8].text),
            SpeakerSegment(speakerId: speaker1ID, startTime: 105, endTime: 110, text: segments[9].text),
        ]
    }

    // MARK: - Action Items & Bookmarks

    private static func makeWelcomeActionItems() -> [ActionItem] {
        [
            ActionItem(
                title: "体验 AI 摘要和智能纪要功能",
                assignee: "Bob",
                dueDescription: "本周内"
            ),
            ActionItem(
                title: "安排跟进会议，讨论写作助手",
                assignee: "Carol",
                dueDescription: "下周一"
            ),
            ActionItem(
                title: "试着把会议整理到文件夹并添加标签",
                assignee: "Alice",
                dueDescription: "本周内"
            ),
        ]
    }

    private static func makeWelcomeBookmarks() -> [Bookmark] {
        [
            Bookmark(label: "功能概览开始", timestamp: 34, color: .blue),
            Bookmark(label: "书签演示", timestamp: 70, color: .orange),
            Bookmark(label: "收尾与下一步", timestamp: 94, color: .purple),
        ]
    }

    // MARK: - Smart Minutes

    private static func makeWelcomeSmartMinutes(actionItems: [ActionItem]) -> SmartMinutes {
        SmartMinutes(
            keyDecisions: [
                "确定将 Logue 作为团队的会议笔记工具",
                "安排一次跟进，探索写作助手功能",
            ],
            discussionPoints: [
                "实时转写并识别发言人",
                "设备端处理确保完全的隐私",
                "录制过程中可以添加书签，标记关键时刻",
                "AI 生成的智能纪要让记笔记自动化",
                "用文件夹和标签整理大量会议",
            ],
            actionItems: actionItems.map(\.title),
            followUps: [
                "了解写作助手和文档分析功能",
                "探索日历集成，用于即将到来的会议",
            ],
            attendeeSummary: [
                AttendeeContribution(
                    name: "Alice",
                    keyPoints: ["主导了功能演示", "演示了书签功能"],
                    speakingTimePercent: 40
                ),
                AttendeeContribution(
                    name: "Bob",
                    keyPoints: ["重点介绍了待办事项和整理功能"],
                    speakingTimePercent: 30
                ),
                AttendeeContribution(
                    name: "Carol",
                    keyPoints: ["强调了隐私优势和智能纪要"],
                    speakingTimePercent: 30
                ),
            ]
        )
    }
}
