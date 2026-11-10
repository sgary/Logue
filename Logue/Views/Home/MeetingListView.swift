import SwiftUI

/// Minimal fallback view - should rarely be shown due to auto-select
struct MeetingListView: View {
    @Environment(MeetingStore.self) private var store
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        VStack {
            ProgressView()
                .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppThemeConstants.contentBackground)
        .navigationTitle("会议")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    let meeting = store.createMeeting(
                        title: "会议 \(Date.now.formatted(date: .abbreviated, time: .shortened))"
                    )
                    store.selectedMeetingID = meeting.id
                } label: {
                    Image(systemName: "plus")
                        .accessibilityLabel("新建会议")
                }
                .help("新建会议")
            }
        }
        .onAppear {
            // Ensure a meeting is selected or created
            if store.selectedMeetingID == nil {
                if store.activeMeetings.isEmpty {
                    _ = store.createMeeting(
                        title: "未命名会议",
                        mode: .inPerson,
                        template: .general
                    )
                } else if let first = store.activeMeetings.first {
                    store.selectedMeetingID = first.id
                }
            }
        }
    }
}
