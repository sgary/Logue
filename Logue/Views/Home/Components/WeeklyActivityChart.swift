import Charts
import SwiftUI

/// Stacked bar chart showing meetings & documents per day for the last 7 days.
struct WeeklyActivityChart: View {
    let activity: [InsightsStatsProvider.DayActivity]
    let busiestDay: String?

    private static let meetingColor = AppThemeConstants.accent
    private static let documentColor = AppThemeConstants.categoryPurple

    var body: some View {
        InsightCardShell {
            VStack(alignment: .leading, spacing: 12) {
                CardSectionHeader(icon: "chart.bar.xaxis", title: "每周活动")

                Chart(activity) { day in
                    BarMark(
                        x: .value("Day", day.dayLabel),
                        y: .value("Count", day.meetingCount)
                    )
                    .foregroundStyle(day.isToday ? Self.meetingColor : Self.meetingColor.opacity(AppThemeConstants.opacityMuted))
                    .cornerRadius(AppThemeConstants.radiusXSmall)
                    .position(by: .value("Type", "Meetings"))

                    BarMark(
                        x: .value("Day", day.dayLabel),
                        y: .value("Count", day.documentCount)
                    )
                    .foregroundStyle(day.isToday ? Self.documentColor : Self.documentColor.opacity(AppThemeConstants.opacityMuted))
                    .cornerRadius(AppThemeConstants.radiusXSmall)
                    .position(by: .value("Type", "Documents"))
                }
                .chartYAxis {
                    AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                            .foregroundStyle(.quaternary)
                        AxisValueLabel()
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .chartLegend(.hidden)
                .frame(height: 140)
                .accessibilityLabel("每周活动图表")
                .accessibilityValue(
                    "本周 \(activity.reduce(0) { $0 + $1.meetingCount }) 场会议和 \(activity.reduce(0) { $0 + $1.documentCount }) 个文档"
                )

                // Legend + busiest day
                HStack(spacing: 16) {
                    legendItem(color: Self.meetingColor, label: "会议")
                    legendItem(color: Self.documentColor, label: "文档")
                    Spacer()
                    if let busiestDay {
                        Text("最忙：\(busiestDay)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
