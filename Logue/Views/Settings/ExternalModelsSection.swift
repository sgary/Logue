import SwiftUI

// MARK: - ConnectionStatusDot

struct ConnectionStatusDot: View {
    let status: ConnectionStatus

    @State private var isPulsing = false

    var body: some View {
        Circle()
            .fill(status.dotColor)
            .frame(width: 7, height: 7)
            .opacity(status == .checking ? (isPulsing ? 0.4 : 1.0) : 1.0)
            .animation(
                status == .checking
                    ? .easeInOut(duration: 0.6).repeatForever(autoreverses: true)
                    : .default,
                value: isPulsing
            )
            .help(status.label)
            .accessibilityLabel("连接状态：\(status.label)")
            .onChange(of: status) {
                isPulsing = status == .checking
            }
            .onAppear {
                isPulsing = status == .checking
            }
    }
}

// MARK: - APIModelRow

struct APIModelRow: View {
    @Environment(ModelManager.self) private var modelManager
    let record: ModelConfiguration
    @Binding var editingModelID: String?

    @State private var isHovered = false

    // Edit form state
    @State private var editDisplayName = ""
    @State private var editEndpoint = ""
    @State private var editModelName = ""
    @State private var editApiKey = ""
    @State private var editRequiresAuth = false
    @State private var editScannedModels: [String] = []
    @State private var editIsScanning = false
    @State private var editConnectionStatus: ConnectionStatus = .idle

    private var isActive: Bool {
        modelManager.activeModel?.id == record.id
    }

    private var isBusy: Bool {
        modelManager.activatingModelID == record.id
    }

    private var status: ConnectionStatus {
        modelManager.connectionStatus(for: record.id)
    }

    private var isEditing: Bool {
        editingModelID == record.id
    }

    private var canSave: Bool {
        switch record.providerType {
        case .anthropic:
            !editApiKey.isEmpty && !editModelName.isEmpty
        case .openai, .openRouter:
            !editApiKey.isEmpty && !editModelName.isEmpty
        case .ollama, .lmStudio, .llamacpp:
            !editEndpoint.isEmpty && !editModelName.isEmpty
        case .openaiCompatible:
            !editEndpoint.isEmpty && !editModelName.isEmpty
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Model card row
            Button {
                guard !isBusy, !isEditing else { return }
                modelManager.downloadAndActivate(record)
            } label: {
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        radioIndicator

                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text(record.displayName)
                                    .font(.subheadline.weight(.medium))

                                ConnectionStatusDot(status: status)
                            }
                            Text(record.providerType.displayName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        HStack(spacing: 6) {
                            Button {
                                modelManager.testConnection(for: record)
                            } label: {
                                Image(systemName: "bolt.fill")
                                    .font(.caption)
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.secondary)
                            .help("测试连接")
                            .accessibilityLabel("测试连接")

                            if isBusy {
                                InlineProgressLabel(text: "测试中…")
                            }

                            if isHovered {
                                Button {
                                    loadEditFields()
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        editingModelID = record.id
                                    }
                                } label: {
                                    Image(systemName: "gearshape")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                                .help("编辑配置")
                                .accessibilityLabel("编辑配置")

                                Button {
                                    modelManager.removeCustomModel(id: record.id)
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.caption)
                                        .foregroundStyle(AppThemeConstants.error)
                                }
                                .buttonStyle(.plain)
                                .help("移除模型")
                                .accessibilityLabel("移除模型")
                            }
                        }
                    }

                    // Activation error for this specific model
                    if let error = modelManager.activationError, modelManager.activationErrorModelID == record.id {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption2)
                                .foregroundStyle(AppThemeConstants.error)
                            Text(error)
                                .font(.caption2)
                                .foregroundStyle(AppThemeConstants.error)
                                .lineLimit(2)
                        }
                        .padding(.top, 4)
                        .padding(.leading, 32)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
                .background(
                    RoundedRectangle(cornerRadius: AppThemeConstants.radiusMedium, style: .continuous)
                        .fill(isActive ? AppThemeConstants.brandPrimary
                            .opacity(AppThemeConstants.activeOpacity) :
                            (isHovered ? Color.primary.opacity(AppThemeConstants.hoverOpacity) : Color.clear))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppThemeConstants.radiusMedium, style: .continuous)
                        .stroke(isActive ? AppThemeConstants.brandPrimary.opacity(AppThemeConstants.borderOpacity) : Color.clear, lineWidth: 1)
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .onHover { isHovered = $0 }
            .animation(.easeInOut(duration: 0.15), value: isActive)
            .animation(.easeInOut(duration: 0.1), value: isHovered)
            .accessibilityLabel("\(record.displayName)\(isActive ? "，使用中" : "")")
            .accessibilityHint(isActive ? "当前使用的模型" : "双击以启用")

            // Inline edit form
            if isEditing {
                editForm
                    .transition(.opacity)
            }
        }
    }

    // MARK: - Edit Form

    private var editForm: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Display Name
            VStack(alignment: .leading, spacing: 4) {
                Text("显示名称")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                TextField("模型显示名称", text: $editDisplayName)
                    .textFieldStyle(.roundedBorder)
            }

            // Provider (read-only)
            HStack {
                Text("提供商")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(record.providerType.displayName)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            // Provider-specific fields
            switch record.providerType {
            case .openai, .openRouter:
                editApiKeyField
                editEndpointField
                editModelNameField
                editScanSection

            case .anthropic:
                editApiKeyField
                editEndpointField
                editModelNameField

            case .ollama, .lmStudio, .llamacpp:
                editEndpointField
                editModelNameField
                editScanSection

            case .openaiCompatible:
                editEndpointField
                editModelNameField
                editScanSection
                editAuthToggle
            }

            // Action buttons
            HStack {
                Spacer()
                Button("取消") {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        editingModelID = nil
                    }
                }
                .controlSize(.small)

                Button("保存") { saveChanges() }
                    .buttonStyle(.borderedProminent)
                    .tint(AppThemeConstants.accent)
                    .controlSize(.small)
                    .disabled(!canSave)
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

    // MARK: - Edit Form Fields

    private var editApiKeyField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("API 密钥")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            SecureField("输入你的 API 密钥", text: $editApiKey)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var editEndpointField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("端点 URL")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            TextField(
                record.providerType.defaultEndpoint.isEmpty ? "https://..." : record.providerType.defaultEndpoint,
                text: $editEndpoint
            )
            .textFieldStyle(.roundedBorder)
        }
    }

    private var editModelNameField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("模型名称")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            TextField("例如 gpt-5.4、gpt-5.4-mini、llama3、mistral", text: $editModelName)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var editAuthToggle: some View {
        VStack(alignment: .leading, spacing: 4) {
            Toggle("需要 API 密钥", isOn: $editRequiresAuth)
                .font(.caption.weight(.medium))

            if editRequiresAuth {
                SecureField("Bearer API 密钥", text: $editApiKey)
                    .textFieldStyle(.roundedBorder)
            }
        }
    }

    private var editScanSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Button {
                    scanEndpoint()
                } label: {
                    if editIsScanning {
                        ProgressView().scaleEffect(0.6).frame(width: 50)
                    } else {
                        HStack(spacing: 4) {
                            ConnectionStatusDot(status: editConnectionStatus)
                            Text("扫描模型").font(.caption)
                        }
                    }
                }
                .controlSize(.small)
                .disabled(editEndpoint.isEmpty || editIsScanning)

                Spacer()
            }

            if !editScannedModels.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(editScannedModels, id: \.self) { model in
                            Button {
                                editModelName = model
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "cube").font(.caption2)
                                    Text(model).font(.caption)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 5)
                                .background(
                                    editModelName == model
                                        ? AppThemeConstants.brandPrimary.opacity(AppThemeConstants.opacityMedium)
                                        : Color.primary.opacity(AppThemeConstants.opacitySubtle),
                                    in: Capsule()
                                )
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(editModelName == model ? AppThemeConstants.brandPrimary : .primary)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Radio Indicator

    private var radioIndicator: some View {
        ZStack {
            Circle()
                .stroke(
                    isActive ? AppThemeConstants.brandPrimary : Color.secondary.opacity(AppThemeConstants.opacityMuted),
                    lineWidth: isActive ? 2 : 1.5
                )
                .frame(width: 18, height: 18)
            if isActive {
                Circle()
                    .fill(AppThemeConstants.brandPrimary)
                    .frame(width: 10, height: 10)
            }
        }
        .frame(width: 20)
    }

    // MARK: - Actions

    private func loadEditFields() {
        editDisplayName = record.displayName
        editEndpoint = record.endpoint ?? record.providerType.defaultEndpoint
        editModelName = record.modelName ?? ""
        editApiKey = record.apiKey ?? ""
        editRequiresAuth = record.requiresAuth
        editScannedModels = []
        editIsScanning = false
        editConnectionStatus = .idle
    }

    private func scanEndpoint() {
        guard !editEndpoint.isEmpty else { return }
        // Require HTTPS for remote endpoints (allow localhost for local servers)
        let trimmed = editEndpoint.trimmingCharacters(in: .whitespacesAndNewlines)
        let isLocal = trimmed.contains("localhost") || trimmed.contains("127.0.0.1")
        guard isLocal || trimmed.hasPrefix("https://") else {
            editConnectionStatus = .error("端点必须使用 HTTPS")
            return
        }
        editIsScanning = true
        editConnectionStatus = .checking

        Task {
            let key = (editRequiresAuth || !editApiKey.isEmpty) ? editApiKey : nil
            let config = ModelConfiguration(
                id: "scan-temp", type: .api, displayName: "", description: "",
                endpoint: editEndpoint, apiKey: key, modelName: nil,
                requiresAuth: key != nil,
                providerType: record.providerType
            )
            let models = await modelManager.scanModelsForConfig(config)
            // Sanitize model names: reject empty, overly long, or control-character-containing names
            editScannedModels = models.filter { name in
                !name.isEmpty && name.count <= 255 && !name.contains(where: { $0.isNewline || $0.asciiValue == 0 })
            }
            editIsScanning = false

            if !models.isEmpty {
                editConnectionStatus = .connected
                if editModelName.isEmpty, let first = models.first {
                    editModelName = first
                }
            } else {
                editConnectionStatus = .error("未找到模型")
            }
        }
    }

    private func saveChanges() {
        let name = editModelName.isEmpty ? "自定义模型" : editModelName
        let finalDisplayName = editDisplayName.isEmpty ? "\(name) (\(record.providerType.displayName))" : editDisplayName

        let updated = ModelConfiguration(
            id: record.id,
            type: .api,
            displayName: finalDisplayName,
            description: record.description,
            endpoint: editEndpoint.isEmpty ? nil : editEndpoint,
            apiKey: !editApiKey.isEmpty ? editApiKey : nil,
            modelName: editModelName.isEmpty ? nil : editModelName,
            requiresAuth: editRequiresAuth || !editApiKey.isEmpty,
            providerType: record.providerType
        )
        modelManager.updateCustomModel(updated)
        withAnimation(.easeInOut(duration: 0.25)) {
            editingModelID = nil
        }
    }
}
