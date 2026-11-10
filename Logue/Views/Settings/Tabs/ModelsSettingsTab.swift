import SwiftUI

struct ModelsSettingsTab: View {
    @Environment(ModelManager.self) private var modelManager

    /// Provider selection
    @State private var selectedProvider: APIProviderType?

    // Common fields
    @State private var endpoint = ""
    @State private var modelName = ""
    @State private var apiKey = ""
    @State private var requiresAuth = false
    @State private var connectionStatus: ConnectionStatus = .idle
    @State private var scannedModels: [String] = []
    @State private var isScanning = false

    // Custom MLX
    @State private var hfURLInput = ""
    @State private var isAddingCustomMLX = false

    /// Connect API
    @State private var isConnectingAPI = false

    /// Edit existing connected model
    @State private var editingModelID: String?

    private var customAPIModels: [ModelConfiguration] {
        modelManager.customModels.filter { $0.type == .api }
    }

    private var customMLXModels: [ModelConfiguration] {
        modelManager.customModels.filter { $0.type == .mlx }
    }

    private var isInsecureRemoteEndpoint: Bool {
        let trimmed = endpoint.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return trimmed.hasPrefix("http://")
            && !trimmed.hasPrefix("http://localhost")
            && !trimmed.hasPrefix("http://127.0.0.1")
            && !trimmed.hasPrefix("http://[::1]")
            && trimmed.count > 7
    }

    private var canConnect: Bool {
        guard let provider = selectedProvider else { return false }
        switch provider {
        case .anthropic:
            return !apiKey.isEmpty && !modelName.isEmpty
        case .openai, .openRouter:
            return !apiKey.isEmpty && !modelName.isEmpty
        case .ollama, .lmStudio, .llamacpp:
            return !endpoint.isEmpty && !modelName.isEmpty
        case .openaiCompatible:
            return !endpoint.isEmpty && !modelName.isEmpty
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("模型")
                .font(.title3.bold())
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 4)
            Text("连接云端或本地 AI 提供商，例如 OpenAI、Anthropic、OpenRouter、Ollama 等。")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // On-device models (presets + custom MLX)
                    onDeviceModelsSection

                    Divider()

                    // Connected API models + connect form
                    connectedModelsSection
                }
                .padding(20)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: selectedProvider)
        .animation(.easeInOut(duration: 0.25), value: isAddingCustomMLX)
        .animation(.easeInOut(duration: 0.25), value: isConnectingAPI)
    }

    // MARK: - On-Device Models

    private var onDeviceModelsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("设备端模型")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            Text("在你的 Mac 上本地运行 AI，无需联网。")
                .font(.caption)
                .foregroundStyle(.tertiary)

            VStack(spacing: 4) {
                ForEach(modelManager.presets) { preset in
                    ModelSettingsRow(record: preset)
                }
                ForEach(customMLXModels) { model in
                    ModelSettingsRow(record: model)
                }
            }

            if isAddingCustomMLX {
                addCustomMLXForm
                    .transition(.opacity)
            } else {
                Button {
                    withAnimation { isAddingCustomMLX = true }
                } label: {
                    Label("从 HuggingFace 添加模型", systemImage: "plus.circle")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
        }
    }

    private var addCustomMLXForm: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("粘贴 HuggingFace 上 mlx-community 的模型 URL。")
                .font(.caption)
                .foregroundStyle(.tertiary)

            TextField("https://huggingface.co/mlx-community/...", text: $hfURLInput)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    guard !hfURLInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                    addCustomMLXModel()
                }

            if let error = modelManager.fetchModelError {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundStyle(AppThemeConstants.error)
                    Text(error)
                        .font(.caption2)
                        .foregroundStyle(AppThemeConstants.error)
                        .lineLimit(2)
                }
            }

            HStack {
                Spacer()
                Button("取消") {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isAddingCustomMLX = false
                        hfURLInput = ""
                    }
                }
                .controlSize(.small)

                Button("添加模型") { addCustomMLXModel() }
                    .buttonStyle(.borderedProminent)
                    .tint(AppThemeConstants.accent)
                    .controlSize(.small)
                    .disabled(
                        hfURLInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            || modelManager.isFetchingModelInfo
                    )

                if modelManager.isFetchingModelInfo {
                    ProgressView().scaleEffect(0.6)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: AppThemeConstants.radiusMedium, style: .continuous)
                .fill(AppThemeConstants.surfaceBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppThemeConstants.radiusMedium, style: .continuous)
                .strokeBorder(AppThemeConstants.borderColor, lineWidth: 1)
        )
    }

    // MARK: - Connect New Model

    private var connectNewModelForm: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("提供商", selection: $selectedProvider) {
                Text("选择提供商…").tag(APIProviderType?.none)
                ForEach(APIProviderType.connectableProviders) { provider in
                    Text(provider.displayName)
                        .tag(APIProviderType?.some(provider))
                }
            }
            .onChange(of: selectedProvider) { _, newValue in
                if let provider = newValue {
                    selectProvider(provider)
                } else {
                    resetFields()
                }
            }

            if selectedProvider != nil {
                inlineConfigForm
                    .transition(.opacity)
            } else {
                // Cancel button when no provider selected yet
                HStack {
                    Spacer()
                    Button("取消") {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isConnectingAPI = false
                            selectedProvider = nil
                            resetFields()
                        }
                    }
                    .controlSize(.small)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: AppThemeConstants.radiusMedium, style: .continuous)
                .fill(AppThemeConstants.surfaceBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppThemeConstants.radiusMedium, style: .continuous)
                .strokeBorder(AppThemeConstants.borderColor, lineWidth: 1)
        )
    }

    // MARK: - Inline Config Form

    private var inlineConfigForm: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Provider description
            if let provider = selectedProvider {
                Text(providerDescription(for: provider))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            // Dynamic fields per provider
            switch selectedProvider {
            case .openai, .openRouter:
                apiKeyField
                endpointField
                modelNameField
                scanSection

            case .anthropic:
                apiKeyField
                endpointField
                anthropicModelPicker

            case .ollama, .lmStudio, .llamacpp:
                endpointField
                modelNameField
                scanSection

            case .openaiCompatible:
                endpointField
                modelNameField
                scanSection
                authToggle

            default:
                EmptyView()
            }

            // Action buttons
            HStack {
                Spacer()
                Button("取消") {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isConnectingAPI = false
                        selectedProvider = nil
                        resetFields()
                    }
                }
                .controlSize(.small)

                Button("连接") { addModel() }
                    .buttonStyle(.borderedProminent)
                    .tint(AppThemeConstants.accent)
                    .controlSize(.small)
                    .disabled(!canConnect)
            }
        }
    }

    // MARK: - Connected Models

    private var connectedModelsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("已连接的模型")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            if !customAPIModels.isEmpty {
                VStack(spacing: 4) {
                    ForEach(customAPIModels) { model in
                        APIModelRow(record: model, editingModelID: $editingModelID)
                    }
                }
            }

            if isConnectingAPI {
                connectNewModelForm
                    .transition(.opacity)
            } else if editingModelID == nil {
                Button {
                    withAnimation { isConnectingAPI = true }
                } label: {
                    Label("连接模型", systemImage: "plus.circle")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
        }
        .onChange(of: editingModelID) { _, newValue in
            if newValue != nil {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isConnectingAPI = false
                    selectedProvider = nil
                    resetFields()
                }
            }
        }
    }

    // MARK: - Form Fields

    private var apiKeyField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("API 密钥")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            SecureField("输入你的 API 密钥", text: $apiKey)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var endpointField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("端点 URL")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                TextField(selectedProvider?.defaultEndpoint ?? "https://...", text: $endpoint)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: endpoint) {
                        connectionStatus = .idle
                        scannedModels = []
                    }

                if isInsecureRemoteEndpoint {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundStyle(AppThemeConstants.warning)
                        .help("远程端点应使用 HTTPS")
                }
            }
        }
    }

    private var modelNameField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("模型名称")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            TextField("例如 gpt-5.4、gpt-5.4-mini、llama3、mistral", text: $modelName)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var scanSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Button {
                    scanEndpoint()
                } label: {
                    if isScanning {
                        ProgressView().scaleEffect(0.6).frame(width: 50)
                    } else {
                        HStack(spacing: 4) {
                            ConnectionStatusDot(status: connectionStatus)
                            Text("扫描模型").font(.caption)
                        }
                    }
                }
                .controlSize(.small)
                .disabled(endpoint.isEmpty || isScanning)

                Spacer()
            }

            if !scannedModels.isEmpty {
                scannedModelsChips
            }
        }
    }

    @State private var useCustomAnthropicModel = false

    private var anthropicModelPicker: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("模型").font(.caption.weight(.medium)).foregroundStyle(.secondary)
            if useCustomAnthropicModel {
                HStack(spacing: 6) {
                    TextField("输入模型名称", text: $modelName).textFieldStyle(.roundedBorder).font(.caption)
                    Button("取消") { useCustomAnthropicModel = false; modelName = AnthropicClient.knownModels.first ?? "" }.controlSize(.small)
                }
            } else {
                HStack(spacing: 6) {
                    Picker("", selection: $modelName) {
                        ForEach(AnthropicClient.knownModels, id: \.self) { Text($0).tag($0) }
                    }.labelsHidden()
                    Button("自定义") { useCustomAnthropicModel = true }.controlSize(.small)
                }
            }
        }
    }

    private var authToggle: some View {
        VStack(alignment: .leading, spacing: 4) {
            Toggle("需要 API 密钥", isOn: $requiresAuth)
                .font(.caption.weight(.medium))

            if requiresAuth {
                SecureField("Bearer API 密钥", text: $apiKey)
                    .textFieldStyle(.roundedBorder)
            }
        }
    }

    private var scannedModelsChips: some View {
        Picker("选择模型", selection: $modelName) {
            ForEach(scannedModels, id: \.self) { model in
                Text(model).tag(model)
            }
        }
        .labelsHidden()
    }
}

// MARK: - Helpers & Actions

private extension ModelsSettingsTab {
    func providerDescription(for provider: APIProviderType) -> String {
        switch provider {
        case .openai: "连接到 OpenAI API（GPT-4o、GPT-4 等）。"
        case .anthropic: "连接到 Anthropic Messages API（Claude 模型）。"
        case .openRouter: "连接 OpenRouter，访问多个提供商。"
        case .ollama: "连接到本地 Ollama 实例。"
        case .lmStudio: "连接到 LM Studio。"
        case .llamacpp: "连接到 llama.cpp 服务器。"
        case .openaiCompatible: "连接到任何兼容 OpenAI 的 API 端点。"
        }
    }

    func selectProvider(_ provider: APIProviderType) {
        endpoint = provider.defaultEndpoint
        requiresAuth = provider.requiresAuthByDefault
        modelName = ""
        apiKey = ""
        scannedModels = []
        connectionStatus = .idle

        if provider == .anthropic {
            modelName = AnthropicClient.knownModels.first ?? ""
        }
    }

    func resetFields() {
        endpoint = ""
        modelName = ""
        apiKey = ""
        requiresAuth = false
        scannedModels = []
        connectionStatus = .idle
        isScanning = false
    }

    func scanEndpoint() {
        guard !endpoint.isEmpty else { return }
        isScanning = true
        connectionStatus = .checking

        Task {
            let key = (requiresAuth || !apiKey.isEmpty) ? apiKey : nil
            let config = ModelConfiguration(
                id: "scan-temp", type: .api, displayName: "", description: "",
                endpoint: endpoint, apiKey: key, modelName: nil,
                requiresAuth: key != nil,
                providerType: selectedProvider ?? .openaiCompatible
            )
            let models = await modelManager.scanModelsForConfig(config)
            scannedModels = models
            isScanning = false

            if !models.isEmpty {
                connectionStatus = .connected
                if modelName.isEmpty, let first = models.first {
                    modelName = first
                }
            } else {
                connectionStatus = .error("未找到模型")
            }
        }
    }

    func addCustomMLXModel() {
        Task {
            let success = await modelManager.fetchAndAddCustomMLXModel(from: hfURLInput)
            if success {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isAddingCustomMLX = false
                    hfURLInput = ""
                }
            }
        }
    }

    func addModel() {
        guard let provider = selectedProvider else { return }
        let name = modelName.isEmpty ? "自定义模型" : modelName
        let config = ModelConfiguration(
            id: UUID().uuidString,
            type: .api,
            displayName: "\(name) (\(provider.displayName))",
            description: "\(provider.displayName) 端点。",
            endpoint: endpoint.isEmpty ? nil : endpoint,
            apiKey: (!apiKey.isEmpty) ? apiKey : nil,
            modelName: modelName.isEmpty ? nil : modelName,
            requiresAuth: requiresAuth || !apiKey.isEmpty,
            providerType: provider
        )
        modelManager.addCustomModel(config)

        withAnimation(.easeInOut(duration: 0.25)) {
            isConnectingAPI = false
            selectedProvider = nil
            resetFields()
        }
    }
}
