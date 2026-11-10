import Foundation
import MLXLLM
import MLXLMCommon
import MLXLMHFAPI
import MLXLMTransformers

// MARK: - Model Storage Helpers

extension ModelManager {
    /// The root HF hub cache directory for a model: `<hubCacheDir>/models--<org>--<name>/`.
    /// Contains `blobs/`, `refs/`, `snapshots/`. Used for full cleanup on delete/cancel.
    /// Uses `HubClient.default.cache` to resolve the path, which respects sandbox containers.
    static func modelCacheRoot(for repoID: String) -> URL {
        let sanitized = repoID.replacingOccurrences(of: "/", with: "--")
        let hubCacheDir = HubClient.default.cache.cacheDirectory
        return hubCacheDir.appending(path: "models--\(sanitized)")
    }

    /// Computes the local directory for a HuggingFace model using the standard
    /// HF hub cache layout: `<hubCacheDir>/models--<org>--<name>/snapshots/`.
    /// Returns the first snapshot directory if one exists, or the base models directory.
    static func modelDirectory(for repoID: String) -> URL {
        let snapshotsDir = modelCacheRoot(for: repoID).appending(path: "snapshots")
        // Return the first (usually only) snapshot revision directory
        if let snapshots = try? FileManager.default.contentsOfDirectory(at: snapshotsDir, includingPropertiesForKeys: nil),
           let first = snapshots.first(where: { $0.hasDirectoryPath })
        {
            return first
        }
        return snapshotsDir
    }

    /// Checks whether a model has been fully downloaded by verifying at least one
    /// safetensors weight file exists in the HF cache snapshot directory.
    static func isModelDownloaded(repoID: String) -> Bool {
        let dir = modelDirectory(for: repoID)
        guard FileManager.default.fileExists(atPath: dir.path) else { return false }
        let contents = (try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)) ?? []
        return contents.contains { $0.pathExtension == "safetensors" }
    }
}

// MARK: - Download + Activate

extension ModelManager {
    var isAnyDownloadInProgress: Bool {
        downloadingID != nil
    }

    /// Downloads a model without activating it afterwards.
    func downloadModel(_ record: ModelConfiguration) {
        guard record.type == .mlx else { return }
        setDownloadError(nil)
        setDownloadErrorModelID(nil)
        if let currentID = downloadingID, currentID != record.id {
            setDownloadError("另一个模型正在下载。请先取消该下载。")
            setDownloadErrorModelID(record.id)
            return
        }
        guard !isDownloaded(record) else { return }

        downloadTask?.cancel()
        // Show progress bar immediately at 0% while waiting for any
        // cancelled download to wind down in performDownload.
        setDownloadingID(record.id)
        setDownloadProgress(0)
        setDownloadTask(Task { [weak self] in
            guard let self, let repoId = record.hfRepoID else { return }
            guard await performDownload(repoId: repoId, modelID: record.id) != nil else { return }
        })
    }

    /// Loads an already-downloaded model into the engine.
    func loadModel(_ record: ModelConfiguration) {
        Task { [weak self] in
            await self?.activateDownloadedModel(record)
        }
    }

    func downloadAndActivate(_ record: ModelConfiguration, autoActivate: Bool = false) {
        // If another model is downloading and this one needs downloading too, block it.
        if let currentID = downloadingID, currentID != record.id, !isDownloaded(record) {
            setDownloadError("另一个模型正在下载。请先取消该下载。")
            setDownloadErrorModelID(record.id)
            return
        }

        // If this model is already downloaded and another is downloading,
        // activate it without cancelling the download.
        if downloadingID != nil, downloadingID != record.id, isDownloaded(record) {
            Task { [weak self] in
                await self?.activateDownloadedModel(record)
            }
            return
        }

        downloadTask?.cancel()
        setDownloadTask(Task { [weak self] in
            await self?.downloadAndActivateInternal(record, autoActivate: autoActivate)
        })
    }

    /// Activates an already-downloaded model without interrupting any in-progress download.
    func activateDownloadedModel(_ record: ModelConfiguration) async {
        guard isDownloaded(record) else { return }

        setActivationError(nil)
        setActivationErrorModelID(nil)
        setActivatingModelID(record.id)

        if record.type == .api {
            await activateAPI(record)
            return
        }

        guard let repoId = record.hfRepoID else { return }
        let modelDir = Self.modelDirectory(for: repoId)

        // Release current session before loading new model
        await LLMEngine.shared.releaseSession()
        if activeModelID != nil {
            activeModelID = nil
        }

        await ensureChatTemplate(at: modelDir, repoID: repoId)

        setIsActivating(true)

        do {
            try await LLMEngine.shared.loadModel(from: modelDir)
            activeModelID = record.id
            logger.info("Model activated: \(repoId, privacy: .public)")
        } catch is CancellationError {
            logger.info("Model activation cancelled.")
        } catch {
            logger.error("Activation failed: \(error.localizedDescription, privacy: .public)")
            setActivationError(friendlyActivationError(error))
            setActivationErrorModelID(record.id)
        }

        setIsActivating(false)
        setActivatingModelID(nil)
    }

    func downloadAndActivateInternal(_ record: ModelConfiguration, autoActivate: Bool = false) async {
        setActivationError(nil)
        setActivationErrorModelID(nil)
        setActivatingModelID(record.id)
        setDownloadError(nil)
        setDownloadErrorModelID(nil)

        if record.type == .api {
            // Release any existing session before switching
            if activeModelID != nil {
                await LLMEngine.shared.releaseSession()
                activeModelID = nil
            }
            await activateAPI(record)
            return
        }

        guard let repoId = record.hfRepoID else {
            setActivatingModelID(nil)
            return
        }

        // Download phase — don't release the current session so the user can keep working
        if !Self.isModelDownloaded(repoID: repoId) {
            guard await performDownload(repoId: repoId, modelID: record.id) != nil else {
                setActivatingModelID(nil)
                return
            }

            if autoActivate {
                guard !Task.isCancelled else {
                    setActivatingModelID(nil)
                    return
                }
                await activateDownloadedModel(record)
            } else {
                // Don't auto-activate — the user may be actively using the app.
                // They can activate the model manually when ready.
                setActivatingModelID(nil)
            }
            return
        }

        // Model already downloaded — user is explicitly activating, proceed normally
        await activateDownloadedModel(record)
    }

    /// Runs the network download phase. Returns the downloaded snapshot directory on success,
    /// or `nil` on failure (state has already been reset on failure).
    ///
    /// This deliberately stops at the files. The caller asked for a download, not for the model to
    /// be loaded into memory; loading is what `activateDownloadedModel` is for. Doing both here
    /// meant a load failure was reported as a failed download while the files sat on disk.
    ///
    /// Each download gets a unique generation number. All state mutations (progress,
    /// downloadingID, errors) are guarded by this generation — if the user cancels
    /// and starts a new download, the old download's completion/error handlers
    /// silently bail out instead of clobbering the new download's state.
    private func performDownload(repoId: String, modelID: String) async -> URL? {
        logger.info("[Download] Starting: \(repoId, privacy: .public)")
        setDownloadingID(modelID)
        setDownloadProgress(0)
        incrementDownloadGeneration()
        let generation = downloadGeneration

        // Download directly to the default HF cache (~/.cache/huggingface/hub/).
        // This avoids the temp-cache-to-standard-cache move that was silently failing
        // for custom models, causing "Download" to show instead of "Load" after completion.
        let directory: URL
        do {
            directory = try await downloadWithRetry(repoId: repoId, generation: generation)
        } catch {
            handleDownloadError(error, generation: generation, modelID: modelID)
            return nil
        }

        incrementDownloadStateVersion()

        if downloadGeneration == generation {
            setDownloadingID(nil)
            setDownloadProgress(1.0)
            logger.info("[Download] Complete: \(repoId, privacy: .public) gen=\(generation)")
        }
        return directory
    }

    /// Downloads the snapshot, retrying transient network failures.
    ///
    /// A download that failed once used to fail for good: one `timedOut` or TLS error left the row
    /// back at "下载" with no explanation, and the user clicking again started from nothing as far
    /// as they could tell. Files that already landed are in the hub cache, so a retry resumes from
    /// them instead of re-downloading.
    private func downloadWithRetry(repoId: String, generation: Int) async throws -> URL {
        let attempts = 3
        var lastError: Error?

        for attempt in 1...attempts {
            do {
                return try await HubClient.default.download(
                    id: repoId,
                    revision: nil,
                    matching: Self.modelDownloadPatterns,
                    useLatest: false
                ) { [weak self] progress in
                    Task { @MainActor in
                        guard let self, self.downloadGeneration == generation else { return }
                        self.setDownloadProgress(progress.fractionCompleted)
                    }
                }
            } catch {
                if Task.isCancelled { throw error }
                lastError = error
                guard attempt < attempts, Self.isTransientDownloadError(error) else { throw error }
                logger.warning(
                    "[Download] Attempt \(attempt) failed: \(error.localizedDescription, privacy: .public) — retrying"
                )
                // Reset first: progress is otherwise held back by the monotonic guard, and the
                // retry would look frozen at the percentage the failed attempt reached.
                setDownloadProgress(0)
                try await Task.sleep(for: .seconds(attempt == 1 ? 2 : 5))
            }
        }

        throw lastError ?? CancellationError()
    }

    /// The files a model needs to run. Mirrors `MLXLMCommon`'s own download patterns, which are
    /// not public.
    private static let modelDownloadPatterns = ["*.safetensors", "*.json", "*.jinja"]

    /// Whether a failed download is worth another attempt.
    ///
    /// Timeouts and connection failures are what a proxy does when it is briefly unhealthy; they
    /// are the errors this machine actually sees. A malformed repository or a missing file will
    /// fail the same way every time, so those are left to the caller.
    private static func isTransientDownloadError(_ error: Error) -> Bool {
        let nsError = error as NSError
        guard nsError.domain == NSURLErrorDomain else { return false }
        switch nsError.code {
        case NSURLErrorTimedOut,
             NSURLErrorNetworkConnectionLost,
             NSURLErrorNotConnectedToInternet,
             NSURLErrorCannotConnectToHost,
             NSURLErrorCannotFindHost,
             NSURLErrorDNSLookupFailed,
             NSURLErrorSecureConnectionFailed,
             NSURLErrorServerCertificateUntrusted:
            return true
        default:
            return false
        }
    }

    private func handleDownloadError(_ error: Error, generation: Int, modelID: String) {
        // The downloader throws URLError(.cancelled) on Task.cancel, not CancellationError.
        let wasCancelled = Task.isCancelled
        if wasCancelled {
            logger.info("[Download] Cancelled. gen=\(generation)")
        } else {
            logger.error("[Download] Failed: \(error.localizedDescription, privacy: .public) gen=\(generation)")
        }
        // Only mutate state if this is still the active download.
        if downloadGeneration == generation {
            if !wasCancelled {
                setDownloadError(friendlyDownloadError(error))
                setDownloadErrorModelID(modelID)
            }
            setDownloadingID(nil)
            setDownloadProgress(0)
            setActivatingModelID(nil)
        }
    }

    /// Turns the network failures this downloader actually produces into something the user can
    /// act on. The raw text ("The request timed out.") says what happened but not what to change.
    func friendlyDownloadError(_ error: Error) -> String {
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            switch nsError.code {
            case NSURLErrorTimedOut:
                return "下载超时。请检查网络或代理后重试。"
            case NSURLErrorNotConnectedToInternet:
                return "网络未连接，请连接网络后重试。"
            case NSURLErrorCannotConnectToHost, NSURLErrorCannotFindHost, NSURLErrorDNSLookupFailed:
                return "无法连接到 Hugging Face。请检查网络或代理设置。"
            case NSURLErrorSecureConnectionFailed, NSURLErrorServerCertificateUntrusted:
                return "与 Hugging Face 的安全连接失败。请检查代理设置后重试。"
            case NSURLErrorNetworkConnectionLost:
                return "网络连接中断，请重试。"
            default:
                break
            }
        }
        return error.localizedDescription
    }

    func activateAPI(_ record: ModelConfiguration) async {
        setIsActivating(true)
        do {
            // Auto-discover model name if missing
            var config = record
            if (config.modelName ?? "").isEmpty {
                let client = try LLMClientFactory.makeClient(for: config)
                if let firstName = try? await client.listModels().first {
                    config = ModelConfiguration(
                        id: config.id, type: config.type,
                        displayName: config.displayName, description: config.description,
                        endpoint: config.endpoint, apiKey: config.apiKey,
                        modelName: firstName, requiresAuth: config.requiresAuth,
                        providerType: config.providerType
                    )
                    logger.info("Auto-discovered API model: \(firstName, privacy: .public)")
                }
            }

            try await LLMEngine.shared.loadAPISession(config: config)
            activeModelID = record.id
            logger.info("API Model activated: \(record.id, privacy: .public)")
        } catch {
            logger.error("API Activation failed: \(error.localizedDescription, privacy: .public)")
            setActivationError(friendlyActivationError(error))
            setActivationErrorModelID(record.id)
        }
        setIsActivating(false)
        setActivatingModelID(nil)
    }

    // MARK: - Delete Downloaded Model

    func deleteDownloadedModel(_ record: ModelConfiguration) {
        guard record.type == .mlx, let repoId = record.hfRepoID else { return }

        // Deactivate first if this is the active model
        if activeModelID == record.id {
            activeModelID = nil
            Task { await LLMEngine.shared.releaseSession() }
        }

        // Delete the entire HF cache root (blobs + snapshots + refs) to reclaim all disk space
        let cacheRoot = Self.modelCacheRoot(for: repoId)
        if FileManager.default.fileExists(atPath: cacheRoot.path) {
            do {
                try FileManager.default.removeItem(at: cacheRoot)
                logger.info("Deleted model cache: \(repoId, privacy: .public)")
            } catch {
                logger.error("Failed to delete model: \(error.localizedDescription, privacy: .public)")
            }
        }

        incrementDownloadStateVersion()

        // Also remove the entry if it's a user-added custom model (not a preset)
        if customModels.contains(where: { $0.id == record.id }) {
            removeCustomModel(id: record.id)
        }
    }

    // MARK: - Cancel

    func cancelActivation() {
        downloadTask?.cancel()
        setDownloadTask(nil)
        setDownloadingID(nil)
        setDownloadProgress(0)
        setIsActivating(false)
        setActivatingModelID(nil)
    }

    func cancelDownload() {
        let cancellingID = downloadingID
        let oldGeneration = downloadGeneration
        logger.info("[Cancel] Cancelling download gen=\(oldGeneration)")

        // Increment generation first so zombie URLSession callbacks
        // (which outlive Task.cancel) are rejected immediately.
        incrementDownloadGeneration()
        downloadTask?.cancel()
        setDownloadTask(nil)
        setDownloadingID(nil)
        setDownloadProgress(0)
        setActivatingModelID(nil)

        // Clean up the temp cache directory used by this download generation.
        // Also clean up any files that were moved to the standard cache.
        let tempCacheDir = FileManager.default.temporaryDirectory
            .appending(path: "logue-model-download-\(oldGeneration)")
        try? FileManager.default.removeItem(at: tempCacheDir)

        if let id = cancellingID,
           let record = allModels.first(where: { $0.id == id }),
           let repoId = record.hfRepoID
        {
            let cacheRoot = Self.modelCacheRoot(for: repoId)
            if FileManager.default.fileExists(atPath: cacheRoot.path) {
                do {
                    try FileManager.default.removeItem(at: cacheRoot)
                    logger.info("[Cancel] Cleaned up: \(repoId, privacy: .public)")
                } catch {
                    logger.error("[Cancel] Cleanup failed: \(error.localizedDescription, privacy: .public)")
                }
            }
        }
    }

    // MARK: - Auto-load on launch

    func restoreActiveModelIfAvailable() {
        guard let id = activeModelID,
              let record = allModels.first(where: { $0.id == id })
        else { return }

        if record.type == .api {
            Task { [weak self] in await self?.activateAPI(record) }
            return
        }

        guard let repoId = record.hfRepoID else { return }
        guard Self.isModelDownloaded(repoID: repoId) else {
            logger.warning("Active model files missing on disk for \(repoId, privacy: .public) — clearing activeModelID")
            activeModelID = nil
            return
        }

        let modelDir = Self.modelDirectory(for: repoId)
        Task { [weak self] in
            guard let self, !Task.isCancelled else { return }
            setIsActivating(true)
            await ensureChatTemplate(at: modelDir, repoID: repoId)
            do {
                try await LLMEngine.shared.loadModel(from: modelDir)
                logger.info("Restored model on launch: \(repoId, privacy: .public)")
            } catch is CancellationError {
                logger.info("Model restore cancelled on launch.")
            } catch {
                logger.error("Restore failed for \(repoId, privacy: .public): \(error.localizedDescription, privacy: .public)")
                activeModelID = nil
            }
            setIsActivating(false)
        }
    }

    /// Maps raw MLX/API errors into concise, user-friendly messages.
    func friendlyActivationError(_ error: Error) -> String {
        let raw = error.localizedDescription
        if raw.contains("Mismatched parameter") {
            return "此模型的格式与当前 MLX 版本不兼容。请尝试其他量化版本（例如 4-bit 而非 8-bit）。"
        }
        if raw.contains("No such file") || raw.contains("doesn't exist") {
            return "模型文件似乎不完整或已损坏。请尝试删除并重新下载。"
        }
        if raw.contains("out of memory") || raw.contains("allocation") || raw.contains("mach_vm") {
            return "内存不足，无法加载此模型。请关闭其他应用或尝试更小的模型。"
        }
        if raw.contains("chat_template") || raw.contains("tokenizer") {
            return "此模型缺少聊天模板。它可能是基础模型，而非指令模型。"
        }
        if raw.contains("timeout") || raw.contains("Prewarm timed out") {
            return "模型加载超时。请重试；如果问题持续，此模型可能对你的 Mac 来说过大。"
        }
        return raw
    }
}
