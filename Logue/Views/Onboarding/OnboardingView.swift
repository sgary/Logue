import AVFoundation
import ServiceManagement
import Speech
import SwiftUI

/// Multi-page onboarding wizard shown on first launch.
/// Guides users through permissions, model setup, and calendar integration.
struct OnboardingView: View {
    @Environment(ModelManager.self) var modelManager
    @State var currentPage = 0
    @State private var micGranted = false
    @State private var speechGranted = false
    @State private var calendarManager = CalendarManager.shared
    @State private var accessibilityPollTimer: Timer?

    /// Reads directly from the @Observable singleton so the UI always reflects the true state.
    private var accessibilityGranted: Bool {
        AccessibilityService.shared.isAccessibilityGranted
    }

    @State var didAutoAdvanceFromModel = false
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled

    let onComplete: () -> Void

    private let pageCount = 7

    var body: some View {
        VStack(spacing: 0) {
            // Page content
            Group {
                switch currentPage {
                case 0: welcomePage
                case 1: microphonePage
                case 2: modelPage
                case 3: calendarPage
                case 4: accessibilityPage
                case 5: launchAtLoginPage
                default: completePage
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()

            // Navigation bar
            navigationBar
        }
        .frame(width: 720, height: 560)
        .background(AppThemeConstants.surfaceBackground)
        .task {
            // Check current permission states
            micGranted = AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
            speechGranted = SFSpeechRecognizer.authorizationStatus() == .authorized
            AccessibilityService.shared.checkAccessibilityPermission()
        }
        .onDisappear {
            // Clean up any active timers to prevent leaks if the view is dismissed
            stopAccessibilityPolling()
        }
    }

    // MARK: - Navigation Bar

    /// Whether navigation should be blocked (model page mid-download/activation).
    private var isNavigationBlocked: Bool {
        currentPage == 2 && modelManager.activeModelID == nil
    }

    private var navigationBar: some View {
        HStack {
            // Hide Back on the microphone page and during model download/activation.
            if currentPage > 0, currentPage < pageCount - 1, currentPage != 1, !isModelBusy {
                Button("返回") {
                    withAnimation(.easeInOut(duration: 0.25)) { currentPage -= 1 }
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .accessibilityLabel("返回")
                .accessibilityHint("回到上一个引导步骤")
            }

            Spacer()

            // Page dots
            HStack(spacing: 6) {
                ForEach(0 ..< pageCount, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? AppThemeConstants.accent : Color.secondary.opacity(0.3))
                        .frame(width: 6, height: 6)
                }
            }
            .accessibilityLabel("第 \(currentPage + 1) 步，共 \(pageCount) 步")

            Spacer()

            if currentPage < pageCount - 1 {
                Button(currentPage == 0 ? "开始使用" : "继续") {
                    withAnimation(.easeInOut(duration: 0.25)) { currentPage += 1 }
                }
                .buttonStyle(.borderedProminent)
                .tint(AppThemeConstants.accent)
                .controlSize(.regular)
                .disabled(isNavigationBlocked)
                .help(isNavigationBlocked && currentPage == 2
                    ? "下载并启用 AI 模型后继续"
                    : "")
                .accessibilityLabel(currentPage == 0 ? "开始使用" : "下一步")
                .accessibilityHint("进入下一个引导步骤")
            } else {
                Button("开始使用 Logue") {
                    onComplete()
                }
                .buttonStyle(.borderedProminent)
                .tint(AppThemeConstants.accent)
                .controlSize(.regular)
                .accessibilityLabel("开始使用 Logue")
                .accessibilityHint("完成引导并打开应用")
            }
        }
        .padding(.horizontal, AppThemeConstants.paddingXLarge)
        .padding(.vertical, AppThemeConstants.paddingMedium)
        .background(AppThemeConstants.chromeBackground)
    }

    // MARK: - Page 0: Welcome

    private var welcomePage: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "waveform.badge.mic")
                .font(.largeTitle)
                .foregroundStyle(AppThemeConstants.accent)

            VStack(spacing: 8) {
                Text("欢迎使用 Logue")
                    .font(.title.bold())
                Text("隐私优先的 AI 会议助手")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 12) {
                featureRow(icon: "mic.fill", text: "在设备端录制并转写会议")
                featureRow(icon: "sparkles", text: "AI 驱动的摘要与待办事项")
                featureRow(icon: "doc.text", text: "智能文档写作助手")
                featureRow(icon: "lock.shield.fill", text: "所有内容都留在这台 Mac 上")
            }
            .padding(.horizontal, 40)
            .padding(.top, 8)

            Spacer()

            PrivacyBadge("所有处理都在本地完成，你的数据不会离开这台 Mac。")
                .padding(.bottom, 8)
        }
        .padding(AppThemeConstants.paddingXLarge)
    }

    // MARK: - Page 4: Microphone

    private var microphonePage: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                Circle()
                    .fill(micGranted ? AppThemeConstants.success.opacity(0.12) : AppThemeConstants.accent.opacity(0.12))
                    .frame(width: 72, height: 72)
                Image(systemName: micGranted ? "checkmark.circle.fill" : "mic.circle.fill")
                    .font(.title)
                    .foregroundStyle(micGranted ? AppThemeConstants.success : AppThemeConstants.accent)
            }

            VStack(spacing: 8) {
                Text("麦克风权限")
                    .font(.title2.bold())
                Text("Logue 需要麦克风权限，以便在设备端转写会议和语音笔记。")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 360)
            }

            if micGranted, speechGranted {
                Label("麦克风与语音识别已启用", systemImage: "checkmark.circle.fill")
                    .font(.callout.weight(.medium))
                    .foregroundStyle(AppThemeConstants.success)
            } else {
                VStack(spacing: 10) {
                    if !micGranted {
                        Button("授予麦克风权限") {
                            Task {
                                micGranted = await AVCaptureDevice.requestAccess(for: .audio)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppThemeConstants.accent)
                        .controlSize(.large)
                        .accessibilityLabel("授予麦克风权限")
                        .accessibilityHint("请求麦克风权限以录制会议")
                    }

                    if !speechGranted {
                        Button("启用语音识别") {
                            Task {
                                speechGranted = await requestSpeechPermission()
                            }
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                        .accessibilityLabel("启用语音识别")
                        .accessibilityHint("请求语音识别权限以进行转写")
                    }
                }
            }

            Spacer()

            PrivacyBadge("音频完全在设备端通过 Apple 语音技术处理。")
                .padding(.bottom, 8)
        }
        .padding(AppThemeConstants.paddingXLarge)
    }

    // MARK: - Page 6: Calendar

    private var calendarPage: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        calendarManager.isAuthorized
                            ? AppThemeConstants.success.opacity(0.12)
                            : AppThemeConstants.accent.opacity(0.12)
                    )
                    .frame(width: 72, height: 72)
                Image(systemName: calendarManager.isAuthorized ? "checkmark.circle.fill" : "calendar.circle.fill")
                    .font(.title)
                    .foregroundStyle(calendarManager.isAuthorized ? AppThemeConstants.success : AppThemeConstants.accent)
            }

            VStack(spacing: 8) {
                Text("日历集成")
                    .font(.title2.bold())
                Text("在 Logue 中查看即将开始的会议，会议开始时即可快速开始录制。")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 380)
            }

            if calendarManager.isAuthorized {
                Label("日历已连接", systemImage: "checkmark.circle.fill")
                    .font(.callout.weight(.medium))
                    .foregroundStyle(AppThemeConstants.success)
            } else {
                VStack(spacing: 10) {
                    Button("连接日历") {
                        Task { await calendarManager.requestAccess() }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppThemeConstants.accent)
                    .controlSize(.large)
                    .accessibilityLabel("连接日历")
                    .accessibilityHint("请求日历权限以显示即将开始的会议")

                    Button("跳过——稍后设置") {
                        withAnimation(.easeInOut(duration: 0.25)) { currentPage += 1 }
                    }
                    .buttonStyle(.plain)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("跳过日历设置")
                }
            }

            Spacer()

            PrivacyBadge("日历数据仅在本地读取，不会上传。")
                .padding(.bottom, 8)
        }
        .padding(AppThemeConstants.paddingXLarge)
    }

    // MARK: - Page 7: Accessibility

    private var accessibilityPage: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        accessibilityGranted
                            ? AppThemeConstants.success.opacity(0.12)
                            : AppThemeConstants.accent.opacity(0.12)
                    )
                    .frame(width: 72, height: 72)
                Image(systemName: accessibilityGranted ? "checkmark.circle.fill" : "accessibility.fill")
                    .font(.title)
                    .foregroundStyle(accessibilityGranted ? AppThemeConstants.success : AppThemeConstants.accent)
            }

            VStack(spacing: 8) {
                Text("辅助功能权限")
                    .font(.title2.bold())
                Text("Logue 使用辅助功能来支持写作助手、自动建议以及跨应用文本替换。")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 380)
            }

            if accessibilityGranted {
                Label("辅助功能权限已启用", systemImage: "checkmark.circle.fill")
                    .font(.callout.weight(.medium))
                    .foregroundStyle(AppThemeConstants.success)
            } else {
                VStack(spacing: 10) {
                    Button("授予辅助功能权限") {
                        AccessibilityService.shared.checkAccessibilityPermission(prompt: true)
                        startAccessibilityPolling()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppThemeConstants.accent)
                    .controlSize(.large)
                    .accessibilityLabel("授予辅助功能权限")
                    .accessibilityHint("打开系统设置以授予辅助功能权限")

                    Button("跳过——稍后设置") {
                        stopAccessibilityPolling()
                        withAnimation(.easeInOut(duration: 0.25)) { currentPage += 1 }
                    }
                    .buttonStyle(.plain)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("跳过辅助功能设置")
                }
            }

            Spacer()

            PrivacyBadge("辅助功能仅用于文本交互，数据不会离开这台 Mac。")
                .padding(.bottom, 8)
        }
        .padding(AppThemeConstants.paddingXLarge)
    }

    private func startAccessibilityPolling() {
        accessibilityPollTimer?.invalidate()
        accessibilityPollTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                let granted = AccessibilityService.shared.checkAccessibilityPermission()
                if granted {
                    stopAccessibilityPolling()
                }
            }
        }
    }

    private func stopAccessibilityPolling() {
        accessibilityPollTimer?.invalidate()
        accessibilityPollTimer = nil
    }

    // MARK: - Page 8: Launch at Login

    private var launchAtLoginPage: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                Circle()
                    .fill(AppThemeConstants.accent.opacity(0.12))
                    .frame(width: 72, height: 72)
                Image(systemName: "power.circle.fill")
                    .font(.title)
                    .foregroundStyle(AppThemeConstants.accent)
            }

            VStack(spacing: 8) {
                Text("登录时启动")
                    .font(.title2.bold())
                Text(
                    "Logue 常驻菜单栏，随时待命。"
                        + "启用登录时启动，开机后即可使用。"
                )
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 380)
            }

            Toggle("登录时启动 Logue", isOn: $launchAtLogin)
                .toggleStyle(.switch)
                .onChange(of: launchAtLogin) { _, newValue in
                    do {
                        if newValue {
                            try SMAppService.mainApp.register()
                        } else {
                            try SMAppService.mainApp.unregister()
                        }
                    } catch {
                        launchAtLogin = !newValue
                    }
                }
                .frame(maxWidth: 240)

            Button("跳过——稍后设置") {
                withAnimation(.easeInOut(duration: 0.25)) { currentPage += 1 }
            }
            .buttonStyle(.plain)
            .font(.callout)
            .foregroundStyle(.secondary)
            .accessibilityLabel("跳过登录时启动设置")

            Spacer()

            PrivacyBadge("Logue 在菜单栏本地运行，不会在后台收集数据。")
                .padding(.bottom, 8)
        }
        .padding(AppThemeConstants.paddingXLarge)
    }

    // MARK: - Page 9: Complete

    private var completePage: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                Circle()
                    .fill(AppThemeConstants.success.opacity(0.12))
                    .frame(width: 72, height: 72)
                Image(systemName: "checkmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(AppThemeConstants.success)
            }

            VStack(spacing: 8) {
                Text("一切就绪！")
                    .font(.title2.bold())
                Text("以下是一些入门快捷键：")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 12) {
                shortcutRow(keys: "⌘N", label: "新建文档")
                shortcutRow(keys: "⌘⇧N", label: "新建会议")
                shortcutRow(keys: ShortcutManager.shared.commandCenterShortcut.displayString, label: "询问 Logue（全局）")
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: AppThemeConstants.radiusLarge)
                    .fill(AppThemeConstants.chromeBackground)
            )

            Spacer()
        }
        .padding(AppThemeConstants.paddingXLarge)
    }

    // MARK: - Helpers

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(AppThemeConstants.accent)
                .frame(width: 24)
            Text(text)
                .font(.callout)
        }
    }

    private func shortcutRow(keys: String, label: String) -> some View {
        HStack(spacing: 12) {
            Text(keys)
                .font(.system(.caption, design: .monospaced).weight(.medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: AppThemeConstants.radiusSmall)
                        .fill(AppThemeConstants.surfaceBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppThemeConstants.radiusSmall)
                                .strokeBorder(Color.primary.opacity(AppThemeConstants.opacityLight), lineWidth: 1)
                        )
                )
            Text(label)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }

    private func requestSpeechPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}
