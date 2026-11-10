import SwiftUI

/// Right-panel view for playing back the raw meeting recording.
/// The service is owned by MeetingWorkspaceView so playback state survives panel switches.
struct AudioPlaybackView: View {
    let meeting: MeetingNote
    let service: AudioPlaybackService

    @State private var isScrubbing = false
    @State private var scrubTime: TimeInterval = 0

    private static let speedOptions: [Float] = [0.75, 1.0, 1.25, 1.5, 2.0]

    var body: some View {
        VStack(spacing: 0) {
            panelHeader
            Divider()
            if let url = meeting.audioFileURL {
                ScrollView {
                    VStack(spacing: 24) {
                        playerContent
                        if !meeting.bookmarks.isEmpty {
                            bookmarkList
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .onAppear {
                    service.segments = meeting.segments
                    service.load(url: url)
                }
                .onDisappear { service.stop() }
            } else {
                emptyState
            }
        }
    }

    // MARK: - Header

    private var panelHeader: some View {
        HStack {
            Label("录音", systemImage: "waveform")
                .font(.subheadline.weight(.semibold))
            Spacer()
            if meeting.audioFileURL != nil {
                Text(TranscriptSegment.formatTime(service.duration))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Player

    private var playerContent: some View {
        VStack(spacing: 20) {
            transportControls
            scrubber
            speedPicker
        }
    }

    private var transportControls: some View {
        HStack(spacing: 28) {
            skipButton(seconds: -15, icon: "gobackward.15")
            playPauseButton
            skipButton(seconds: 15, icon: "goforward.15")
        }
    }

    private var playPauseButton: some View {
        Button { service.togglePlayPause() } label: {
            Image(systemName: service.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(AppThemeConstants.accent)
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(service.isPlaying ? "暂停" : "播放")
    }

    private func skipButton(seconds: TimeInterval, icon: String) -> some View {
        Button { service.skip(by: seconds) } label: {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(seconds < 0 ? "后退 15 秒" : "前进 15 秒")
        .disabled(service.duration == 0)
    }

    private var scrubber: some View {
        VStack(spacing: 6) {
            Slider(
                value: isScrubbing ? $scrubTime : Binding(
                    get: { service.currentTime },
                    set: { _ in }
                ),
                in: 0 ... max(service.duration, 1),
                onEditingChanged: { editing in
                    if editing {
                        scrubTime = service.currentTime
                        service.beginScrub()
                        isScrubbing = true
                    } else {
                        service.endScrub(to: scrubTime)
                        isScrubbing = false
                    }
                }
            )
            .tint(AppThemeConstants.accent)
            .disabled(service.duration == 0)

            HStack {
                Text(TranscriptSegment.formatTime(isScrubbing ? scrubTime : service.currentTime))
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.secondary)
                Spacer()
                Text(TranscriptSegment.formatTime(service.duration))
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var speedPicker: some View {
        HStack(spacing: 6) {
            ForEach(Self.speedOptions, id: \.self) { rate in
                let isSelected = abs(service.playbackRate - rate) < 0.01
                Button {
                    service.playbackRate = rate
                } label: {
                    Text(rateLabel(rate))
                        .font(.caption.weight(isSelected ? .semibold : .regular))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            isSelected
                                ? AppThemeConstants.accent.opacity(AppThemeConstants.opacityLight)
                                : Color.primary.opacity(AppThemeConstants.opacitySubtle),
                            in: Capsule()
                        )
                        .foregroundStyle(isSelected ? AppThemeConstants.accent : Color.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(rateLabel(rate)) 倍速")
            }
        }
    }

    private func rateLabel(_ rate: Float) -> String {
        rate == 1.0 ? "1×" : String(format: rate.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f×" : "%.2g×", rate)
    }

    // MARK: - Bookmarks

    private var bookmarkList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("书签")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(meeting.bookmarks.sorted(by: { $0.timestamp < $1.timestamp })) { bookmark in
                Button {
                    service.seek(to: bookmark.timestamp)
                    if !service.isPlaying {
                        service.play()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(bookmark.color.swiftUIColor)
                            .frame(width: 7, height: 7)
                        Text(bookmark.label.isEmpty ? "书签" : bookmark.label)
                            .font(.caption)
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        Spacer()
                        Text(TranscriptSegment.formatTime(bookmark.timestamp))
                            .font(.caption2.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(
                        Color.primary.opacity(AppThemeConstants.opacitySubtle),
                        in: RoundedRectangle(cornerRadius: AppThemeConstants.radiusSmall)
                    )
                }
                .buttonStyle(.plain)
                .help("跳转到 \(bookmark.formattedTimestamp)")
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "waveform.slash")
                .font(.largeTitle)
                .foregroundStyle(.tertiary)
            Text("没有可用的录音")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("开始录音以捕获音频。")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}
