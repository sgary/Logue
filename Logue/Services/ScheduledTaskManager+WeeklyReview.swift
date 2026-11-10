import Foundation
import os.log

// MARK: - LLM Generation Helpers

extension ScheduledTaskManager {
    /// Runs the LLM to synthesize the weekly narrative, then saves a markdown document
    /// combining the LLM output with structured data (counts, action items, decisions).
    func generateAndSaveWeeklyReview(_ snapshot: WeeklyReviewSnapshot) async -> TaskRunRecord {
        let structuredContext = buildWeeklyReviewContext(snapshot)
        let body: String
        do {
            let narrative = try await withRetry {
                let result = try await LLMEngine.shared.complete(
                    system: LLMEngine.chatSystemPrompt + """

                    \nYou are producing the narrative "Themes of the Week" section for a weekly review document.
                    Given the meeting summaries, identify 2-4 recurring themes, patterns, or strategic threads
                    that cut across the week. For each theme: one short title (bold markdown), two or three sentences.
                    No preamble, no JSON. Plain markdown only.
                    """,
                    prompt: """
                    Produce the Themes of the Week section based on this activity:

                    ---

                    \(structuredContext)
                    """,
                    maxTokens: 1024
                )
                guard !result.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    throw LLMError.emptyResponse
                }
                return result
            }
            body = buildWeeklyReviewMarkdown(snapshot: snapshot, themes: narrative)
        } catch {
            logger
                .warning(
                    "Weekly review themes generation failed, falling back to structured-only report: \(error.localizedDescription, privacy: .public)"
                )
            body = buildWeeklyReviewMarkdown(snapshot: snapshot, themes: nil)
        }

        // Save the report as a document so it's browsable in the library.
        let title = "每周回顾 — \(snapshot.dateRangeLabel)"
        let doc = DocumentStore.shared.createDocument(title: title, body: body, select: false)

        let meetingsLabel = "\(snapshot.meetingCount) 场会议"
        let pendingLabel = "\(snapshot.pendingItems.count) 项待办"
        let notifBody = "\(meetingsLabel)，\(pendingLabel)"
        sendNotification(title: "每周回顾已就绪", body: notifBody)
        logger.info("Weekly review saved as document \(doc.id)")
        return TaskRunRecord(
            taskType: .weeklyReview,
            status: .success,
            resultSummary: "\(title) — \(notifBody)",
            createdDocumentID: doc.id
        )
    }

    /// Structured context fed to the LLM. Truncated per-meeting to stay within the context window.
    func buildWeeklyReviewContext(_ snapshot: WeeklyReviewSnapshot) -> String {
        let maxMeetingsInPrompt = 10
        let summarised = snapshot.meetings
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(maxMeetingsInPrompt)
            .enumerated()
            .map { index, meeting in
                let pending = meeting.actionItems.filter { !$0.isCompleted }.count
                let completed = meeting.actionItems.filter(\.isCompleted).count
                return """
                \(index + 1). \(meeting.title) (\(formatDuration(meeting.duration)))
                   Summary: \(String((meeting.summary ?? "—").prefix(240)))
                   Action items: \(pending) pending · \(completed) completed
                """
            }
            .joined(separator: "\n\n")

        return """
        Week: \(snapshot.dateRangeLabel)
        Meetings: \(snapshot.meetingCount) (total \(formatDuration(snapshot.totalDuration)))
        Action items: \(snapshot.completedItems.count) completed · \(snapshot.pendingItems.count) pending · \(snapshot.overdueItems.count) overdue
        Key decisions: \(snapshot.keyDecisions.count)

        MEETINGS:
        \(summarised)
        """
    }

    /// Assembles the final markdown document from structured snapshot data + optional LLM themes.
    func buildWeeklyReviewMarkdown(snapshot: WeeklyReviewSnapshot, themes: String?) -> String {
        var out = "# 每周回顾 — \(snapshot.dateRangeLabel)\n\n"
        out += "_生成于 \(Date().formatted(date: .complete, time: .shortened))_\n\n"

        // Overview
        out += "## 概览\n\n"
        out += "- **会议：** \(snapshot.meetingCount) 场（共 \(formatDuration(snapshot.totalDuration))）\n"
        out += "- **待办事项：** \(snapshot.completedItems.count) 已完成 · \(snapshot.pendingItems.count) 待处理"
        if !snapshot.overdueItems.isEmpty {
            out += " · **\(snapshot.overdueItems.count) 已逾期**"
        }
        out += "\n"
        out += "- **关键决策：** \(snapshot.keyDecisions.count) 项\n\n"

        // Themes (LLM narrative)
        if let themes, !themes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            out += "## 本周主题\n\n"
            out += themes.trimmingCharacters(in: .whitespacesAndNewlines) + "\n\n"
        }

        // Overdue items (highlighted)
        if !snapshot.overdueItems.isEmpty {
            out += "## 逾期待办事项\n\n"
            for (meetingTitle, item) in snapshot.overdueItems {
                let assignee = item.assignee.map { " — _\($0)_" } ?? ""
                let due = item.dueDate.map { "（到期 \($0.formatted(.relative(presentation: .named)))）" } ?? ""
                out += "- [ ] \(item.title)\(assignee)\(due) · 来自 _\(meetingTitle)_\n"
            }
            out += "\n"
        }

        // Pending (non-overdue)
        let nonOverduePending = snapshot.pendingItems.filter { pair in
            !snapshot.overdueItems.contains { $0.item.id == pair.item.id }
        }
        if !nonOverduePending.isEmpty {
            out += "## 待处理待办事项\n\n"
            for (meetingTitle, item) in nonOverduePending {
                let assignee = item.assignee.map { " — _\($0)_" } ?? ""
                let due = item.dueDate.map { "（到期 \($0.formatted(.relative(presentation: .named)))）" } ?? ""
                out += "- [ ] \(item.title)\(assignee)\(due) · 来自 _\(meetingTitle)_\n"
            }
            out += "\n"
        }

        // Key decisions
        if !snapshot.keyDecisions.isEmpty {
            out += "## 关键决策\n\n"
            for (meetingTitle, decision) in snapshot.keyDecisions {
                out += "- \(decision) _— \(meetingTitle)_\n"
            }
            out += "\n"
        }

        // Meeting index
        out += "## 会议\n\n"
        for meeting in snapshot.meetings.sorted(by: { $0.createdAt > $1.createdAt }) {
            let date = meeting.createdAt.formatted(date: .abbreviated, time: .shortened)
            out += "- **\(meeting.title)** — \(date)（\(formatDuration(meeting.duration))）\n"
        }

        return out
    }

    func buildMeetingPrepContext(for event: CalendarEvent) -> String {
        let store = MeetingStore.shared
        let eventWords = Set(
            event.title.lowercased()
                .components(separatedBy: .alphanumerics.inverted)
                .filter { $0.count > 3 }
        )

        let relatedMeetings = store.activeMeetings
            .filter { meeting in
                let meetingWords = Set(
                    meeting.title.lowercased()
                        .components(separatedBy: .alphanumerics.inverted)
                        .filter { $0.count > 3 }
                )
                return !meetingWords.isDisjoint(with: eventWords)
            }
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(3)

        var context = "Upcoming meeting: \(event.title)\nTime: \(event.formattedTimeRange)\n"
        if let location = event.location {
            context += "Location: \(location)\n"
        }

        if !relatedMeetings.isEmpty {
            context += "\nRELATED PAST MEETINGS:\n"
            for meeting in relatedMeetings {
                let pendingItems = meeting.actionItems.filter { !$0.isCompleted }
                context += """
                - \(meeting.title) (\(meeting.createdAt.formatted(date: .abbreviated, time: .omitted)))
                  Summary: \(String((meeting.summary ?? "No summary").prefix(200)))
                  Pending actions: \(pendingItems.map(\.title).joined(separator: "; "))
                \n
                """
            }
        }
        return context
    }

    func generateMeetingPrepBriefing(for event: CalendarEvent, context: String) async -> TaskRunRecord {
        do {
            let briefing = try await withRetry {
                let briefing = try await LLMEngine.shared.complete(
                    system: LLMEngine.chatSystemPrompt + """

                    \nBased on the upcoming meeting and any related past meetings,
                    produce a brief preparation note. Include: key context from past discussions,
                    pending action items to follow up on, and suggested talking points.
                    Be concise (3-5 bullet points).
                    """,
                    prompt: """
                    Prepare a briefing note for this upcoming meeting.

                    ---

                    \(context)
                    """
                )
                guard !briefing.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    throw LLMError.emptyResponse
                }
                return briefing
            }
            sendNotification(title: "会议准备：\(event.title)", body: String(briefing.prefix(200)))
            logger.info("Meeting prep generated for: \(event.title, privacy: .private)")
            return TaskRunRecord(
                taskType: .meetingPrep, status: .success,
                resultSummary: "[\(event.title)] \(String(briefing.prefix(400)))"
            )
        } catch {
            return TaskRunRecord(
                taskType: .meetingPrep, status: .failed,
                resultSummary: "[\(event.title)] 错误：\(error.localizedDescription)"
            )
        }
    }
}
