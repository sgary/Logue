import AVFoundation
import EventKit
import Speech
import SwiftUI

struct PermissionsSettingsTab: View {
    @State private var micGranted = AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
    @State private var speechGranted = SFSpeechRecognizer.authorizationStatus() == .authorized
    @State private var calendarGranted = EKEventStore.authorizationStatus(for: .event) == .fullAccess
    @Environment(CalendarManager.self) private var calendarManager
    @State private var accessibilityPollTimer: Timer?

    /// Reads directly from the @Observable singleton so the UI always reflects the true state.
    private var accessibilityGranted: Bool {
        AccessibilityService.shared.isAccessibilityGranted
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("权限")
                .font(.title3.bold())
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 4)

            Text("Logue 需要这些权限来运行其功能。所有处理都在你的 Mac 上进行。")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 20)
                .padding(.bottom, 4)

            PrivacyBadge("任何数据都不会离开你的设备。")
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Microphone
                    PermissionRow(
                        icon: "mic.fill",
                        title: "麦克风",
                        description: "在设备端录制并转写会议。",
                        isGranted: micGranted,
                        onRevoke: { openPrivacySettings(section: .microphone) },
                        onGrant: {
                            Task {
                                micGranted = await AVCaptureDevice.requestAccess(for: .audio)
                                if !micGranted {
                                    openPrivacySettings(section: .microphone)
                                }
                            }
                        }
                    )

                    Divider()

                    // Speech Recognition
                    PermissionRow(
                        icon: "waveform",
                        title: "语音识别",
                        description: "用于转写和按住说话的语音转文字。",
                        isGranted: speechGranted,
                        onRevoke: { openPrivacySettings(section: .speechRecognition) },
                        onGrant: {
                            Task {
                                speechGranted = await requestSpeechPermission()
                                if !speechGranted {
                                    openPrivacySettings(section: .speechRecognition)
                                }
                            }
                        }
                    )

                    Divider()

                    // Calendar
                    PermissionRow(
                        icon: "calendar",
                        title: "日历",
                        description: "显示即将开始的会议并自动填充标题。",
                        isGranted: calendarGranted,
                        onRevoke: { openPrivacySettings(section: .calendars) },
                        onGrant: {
                            Task {
                                await calendarManager.requestAccess()
                                calendarGranted = EKEventStore.authorizationStatus(for: .event) == .fullAccess
                                if !calendarGranted {
                                    openPrivacySettings(section: .calendars)
                                }
                            }
                        }
                    )

                    // Calendar toggle + upcoming events (only when granted)
                    if calendarGranted {
                        Toggle(isOn: Binding(
                            get: { calendarManager.isEnabled },
                            set: { newValue in
                                if newValue {
                                    calendarManager.isEnabled = true
                                    UserDefaults.standard.set(true, forKey: "calendarIntegrationEnabled")
                                    calendarManager.refreshUpcomingEvents()
                                } else {
                                    calendarManager.disable()
                                }
                            }
                        )) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("显示即将开始的会议")
                                    .font(.subheadline.weight(.medium))
                                Text("在会议主页显示日历事件。")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .toggleStyle(.switch)
                        .tint(AppThemeConstants.accent)
                        .padding(.leading, 36)
                        .accessibilityLabel("显示即将开始的会议")
                        .accessibilityHint("切换是否在会议主页显示日历事件")

                        PrivacyBadge("日历数据通过 EventKit 在本地读取，不会上传或共享。")
                            .padding(.leading, 36)

                        if calendarManager.isEnabled, !calendarManager.upcomingEvents.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("即将开始的事件")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)

                                ForEach(calendarManager.upcomingEvents.prefix(5)) { event in
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(event.isHappeningNow ? AppThemeConstants.error : AppThemeConstants.brandPrimary)
                                            .frame(width: 6, height: 6)
                                        Text(event.title)
                                            .font(.caption)
                                            .lineLimit(1)
                                        Spacer()
                                        Text(event.formattedTimeRange)
                                            .font(.caption2)
                                            .foregroundStyle(.tertiary)
                                    }
                                }
                            }
                            .padding(.leading, 36)
                        }
                    }

                    Divider()

                    // Accessibility
                    PermissionRow(
                        icon: "accessibility",
                        title: "辅助功能",
                        description: "跨应用的写作助手、自动建议和文本替换。",
                        isGranted: accessibilityGranted,
                        onRevoke: { openPrivacySettings(section: .accessibility) },
                        onGrant: {
                            AccessibilityService.shared.checkAccessibilityPermission(prompt: true)
                            startAccessibilityPolling()
                        }
                    )
                }
                .padding(20)
            }
        }
        .task {
            refreshAll()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            refreshAll()
        }
        .onDisappear {
            accessibilityPollTimer?.invalidate()
            accessibilityPollTimer = nil
        }
    }

    // MARK: - Helpers

    private func refreshAll() {
        micGranted = AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
        speechGranted = SFSpeechRecognizer.authorizationStatus() == .authorized
        calendarGranted = EKEventStore.authorizationStatus(for: .event) == .fullAccess
        AccessibilityService.shared.checkAccessibilityPermission()
    }

    private func requestSpeechPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    private func startAccessibilityPolling() {
        accessibilityPollTimer?.invalidate()
        var pollCount = 0
        let maxPolls = 30 // Stop after 30 seconds
        accessibilityPollTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                pollCount += 1
                let granted = AccessibilityService.shared.checkAccessibilityPermission()
                if granted || pollCount >= maxPolls {
                    accessibilityPollTimer?.invalidate()
                    accessibilityPollTimer = nil
                }
            }
        }
    }

    /// Known macOS Privacy preference pane sections.
    private enum PrivacySection: String {
        case microphone = "Microphone"
        case speechRecognition = "SpeechRecognition"
        case calendars = "Calendars"
        case accessibility = "Accessibility"
    }

    private func openPrivacySettings(section: PrivacySection) {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_\(section.rawValue)") {
            NSWorkspace.shared.open(url)
        }
    }
}

// MARK: - Permission Row

private struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String
    let isGranted: Bool
    let onRevoke: () -> Void
    let onGrant: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isGranted ? "checkmark.circle.fill" : "\(icon)")
                .font(.title3)
                .foregroundStyle(isGranted ? AppThemeConstants.success : .secondary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isGranted {
                Button("撤销") {
                    onRevoke()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .accessibilityLabel("撤销\(title)权限")
                .accessibilityHint("打开系统设置以管理\(title.lowercased())权限")
            } else {
                Button("授予") {
                    onGrant()
                }
                .buttonStyle(.borderedProminent)
                .tint(AppThemeConstants.accent)
                .controlSize(.small)
                .accessibilityLabel("授予\(title)权限")
                .accessibilityHint("为 Logue 请求\(title.lowercased())访问权限")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title)权限，\(isGranted ? "已授予" : "未授予")")
    }
}
