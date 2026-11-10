import Foundation

/// The chips offered under the greeting.
///
/// Split from the view for the same reason as `HomeAskPrompts`: which chips appear is a
/// rule about the workspace, not about layout, and a rule can be tested. The ordering is
/// deliberately fixed rather than ranked — a chip that moves between renders reads as a
/// glitch, and the user is aiming at a target that has already shifted.
enum HomeSuggestions {
    /// A chip carries two strings: the short one it shows, and the full sentence it
    /// puts in the input. Showing the full sentence would make a chip a paragraph.
    struct Chip: Equatable, Identifiable {
        let label: String
        let prompt: String
        var id: String {
            label
        }
    }

    /// What the workspace looks like right now, reduced to only what chip selection needs.
    struct Inputs {
        var unsummarizedMeetingTitle: String?
        var overdueCount: Int
        var meetingsToday: Int
        var hasAnyContent: Bool
    }

    static let maximum = 3

    /// Shown before the workspace has anything in it, where nothing can be named yet.
    /// These teach capability instead, which is the only thing left to offer.
    static let firstRunChips: [Chip] = [
        Chip(label: "你能做什么？", prompt: "你能做什么？"),
        Chip(label: "录制下一场会议", prompt: "帮我录制下一场会议"),
        Chip(
            label: "起草文档",
            prompt: "根据我稍后给出的提纲起草一份文档"
        ),
    ]

    static func chips(for inputs: Inputs) -> [Chip] {
        // Both paths leave through the same cap. Returning `firstRunChips` directly would
        // exempt the one list whose length is written by hand from the only rule that
        // bounds it.
        guard inputs.hasAnyContent else { return Array(firstRunChips.prefix(maximum)) }

        var chips: [Chip] = []

        if let title = inputs.unsummarizedMeetingTitle {
            // The same fallback the sentence uses, from the same place. Two copies of the
            // literal is how the chip ends up naming something the prompt does not.
            let name = HomeAskPrompts.sanitize(title, fallback: HomeAskPrompts.untitledMeeting)
            chips.append(
                Chip(
                    label: "总结“\(name)”",
                    prompt: HomeAskPrompts.meeting(title: title, isSummarized: false)
                )
            )
        }
        if inputs.overdueCount > 0 {
            chips.append(Chip(label: "哪些任务逾期了？", prompt: "哪些任务逾期了？"))
        }
        if inputs.meetingsToday > 0 {
            chips.append(Chip(label: "我今天错过了什么？", prompt: "我今天错过了什么？"))
        }
        if chips.isEmpty {
            chips.append(Chip(label: "你能做什么？", prompt: "你能做什么？"))
        }

        return Array(chips.prefix(maximum))
    }
}
