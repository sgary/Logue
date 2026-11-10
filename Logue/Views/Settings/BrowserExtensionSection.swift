import SwiftUI

/// The switch for the browser bridge, under Privacy, and the link to the extension itself.
///
/// Under Privacy rather than a general or "integrations" tab because the trade is a privacy one:
/// the bridge is a listening socket that any program running as this user can reach. That is
/// worth saying in the interface rather than only in a commit message, so the copy names the
/// address and says plainly that nothing leaves the Mac.
///
/// It is on by default as of 1.1.0 — see `BrowserBridgeSettings` — so the copy here says when
/// the port is open rather than describing it as something the user has yet to allow.
struct BrowserExtensionSection: View {
    @State private var bridge = BrowserBridgeServer.shared
    /// `@AppStorage` rather than a `@State` snapshot: the latter read the default once at view
    /// init and never again, so anything else toggling the setting would leave this switch
    /// showing the opposite of the truth. The `true` matches what `BrowserBridgeSettings`
    /// registers, so a fresh install does not show "off" while the server is running.
    @AppStorage(AppConstants.UserDefaultsKeys.browserBridgeEnabled) private var isEnabled = true
    @State private var modelManager = ModelManager.shared

    /// Whether answers would be produced by an external provider rather than on this Mac.
    ///
    /// `LLMEngine` prefers its API client when one is configured, so this is not hypothetical:
    /// with a cloud model active, page text sent over the bridge leaves the machine.
    private var usesExternalProvider: Bool {
        modelManager.activeModel?.type == .api
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("浏览器扩展")
                .font(.headline)

            Text("让 Logue 浏览器扩展使用这台 Mac 的模型——在浏览器中聊天和使用写作工具，"
                + "由 Logue 当前使用的模型来回答。"
                + "扩展通过这台 Mac 自身的回环地址与 Logue 通信，回答也以同样方式返回。")
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Button(UICopy.WhatsNew.chromeExtensionLink) {
                HelpMenuActions.openChromeExtension()
            }
            .controlSize(.small)

            Toggle("允许浏览器扩展连接", isOn: $isEnabled)
                .toggleStyle(.switch)
                .onChange(of: isEnabled) { _, enabled in
                    BrowserBridgeSettings.isEnabled = enabled
                    bridge.applySetting()
                }

            if isEnabled {
                statusRow
                if usesExternalProvider {
                    externalProviderWarning
                }
            }

            Text("开启期间，Logue 会在 127.0.0.1 上接受连接——仅这台 Mac 可访问，网络中的其他设备无法访问。"
                + "以你的身份运行的程序同样可以访问。"
                + "Logue 默认接受连接，以便扩展安装后即可使用；关闭后会释放端口，并保持关闭。")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    /// Shown only when it is true, because it contradicts what someone reasonably assumes from a
    /// local bridge — and this is the Privacy tab, where the claim has to be exactly right.
    private var externalProviderWarning: some View {
        Label(
            "你当前使用的模型来自外部提供商，因此从浏览器发送的文本会发往该提供商，"
                + "而不会留在这台 Mac 上。切换到设备端模型可保持本地处理。",
            systemImage: "exclamationmark.triangle.fill"
        )
        .font(.caption)
        .foregroundStyle(AppThemeConstants.warning)
        .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private var statusRow: some View {
        if let port = bridge.activePort {
            Label("正在监听 127.0.0.1:\(String(port))", systemImage: "checkmark.circle.fill")
                .font(.callout)
                .foregroundStyle(AppThemeConstants.success)
        } else if let error = bridge.lastError {
            // Shown rather than logged: a toggle that turned itself on and did nothing is the
            // worst version of this.
            Label(error, systemImage: "exclamationmark.triangle.fill")
                .font(.callout)
                .foregroundStyle(AppThemeConstants.error)
                .fixedSize(horizontal: false, vertical: true)
        } else {
            Label("正在启动…", systemImage: "clock")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }
}
