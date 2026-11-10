import Foundation
@testable import Logue
import Testing

/// Pins the messages the download row shows. These are the failures this machine actually hit
/// while downloading from Hugging Face: a timed-out request and a failed TLS handshake.
@Suite("Model download failures")
@MainActor
struct ModelDownloadFailureTests {
    @Test("A timeout tells the user to check the network or proxy")
    func timeoutExplained() {
        let message = ModelManager.shared.friendlyDownloadError(URLError(.timedOut))
        #expect(message == "下载超时。请检查网络或代理后重试。")
    }

    @Test("A TLS failure points at the proxy")
    func tlsFailureExplained() {
        let message = ModelManager.shared.friendlyDownloadError(URLError(.secureConnectionFailed))
        #expect(message == "与 Hugging Face 的安全连接失败。请检查代理设置后重试。")
    }

    @Test("An unknown error keeps its own description")
    func unknownErrorPassesThrough() {
        let error = NSError(domain: "Test", code: 1, userInfo: [NSLocalizedDescriptionKey: "boom"])
        #expect(ModelManager.shared.friendlyDownloadError(error) == "boom")
    }
}
