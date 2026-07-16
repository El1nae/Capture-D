import SwiftUI

/// AI 平台选择 + API Key 配置
struct AIConfigView: View {
    @Environment(AIManager.self) private var ai
    private let keychain = KeychainManager()

    /// 每个平台当前输入框内容（providerID -> key）
    @State private var keyInputs: [String: String] = [:]
    /// 已保存提示
    @State private var savedProvider: String?

    var body: some View {
        List {
            // MARK: - 平台选择
            Section {
                ForEach(ai.availableServices, id: \.providerID) { service in
                    Button {
                        selectProvider(service.providerID)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                                Text(service.displayName)
                                    .font(.system(size: AppTheme.FontSize.body, weight: .medium))
                                    .foregroundStyle(AppTheme.Colors.primaryText)
                                Text(keychain.hasKey(for: service.providerID) ? "已配置密钥" : "未配置密钥")
                                    .font(.system(size: AppTheme.FontSize.caption))
                                    .foregroundStyle(
                                        keychain.hasKey(for: service.providerID)
                                            ? AppTheme.Colors.secondaryText
                                            : AppTheme.Colors.destructive
                                    )
                            }
                            Spacer()
                            if ai.currentProvider == service.providerID {
                                Image(systemName: "checkmark")
                                    .font(.system(size: AppTheme.FontSize.body, weight: .semibold))
                                    .foregroundStyle(AppTheme.Colors.accent)
                            }
                        }
                    }
                }
            } header: {
                Text("选择 AI 平台")
            } footer: {
                Text("当前使用：\(ai.currentService.displayName)")
                    .font(.system(size: AppTheme.FontSize.footnote))
            }

            // MARK: - API Key 输入
            ForEach(ai.availableServices, id: \.providerID) { service in
                Section {
                    SecureField("输入 \(service.displayName) API Key", text: binding(for: service.providerID))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .font(.system(size: AppTheme.FontSize.body))

                    HStack {
                        Button {
                            save(for: service.providerID)
                        } label: {
                            Text("保存")
                                .font(.system(size: AppTheme.FontSize.body, weight: .medium))
                        }
                        .disabled((keyInputs[service.providerID] ?? "").isEmpty)

                        Spacer()

                        if savedProvider == service.providerID {
                            Label("已保存", systemImage: "checkmark.circle.fill")
                                .font(.system(size: AppTheme.FontSize.caption))
                                .foregroundStyle(Color.green)
                        } else if keychain.hasKey(for: service.providerID) {
                            Button(role: .destructive) {
                                delete(for: service.providerID)
                            } label: {
                                Text("清除")
                                    .font(.system(size: AppTheme.FontSize.caption))
                            }
                        }
                    }
                } header: {
                    Text("\(service.displayName) 密钥")
                }
            }

            // MARK: - 帮助
            Section {
                NavigationLink {
                    APIKeyGuideView()
                } label: {
                    Label("如何获取 API Key？", systemImage: "questionmark.circle")
                        .font(.system(size: AppTheme.FontSize.body))
                }
            }
        }
        .navigationTitle("AI 配置")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadExistingKeys)
    }

    // MARK: - 逻辑

    private func binding(for provider: String) -> Binding<String> {
        Binding(
            get: { keyInputs[provider] ?? "" },
            set: { keyInputs[provider] = $0 }
        )
    }

    private func selectProvider(_ provider: String) {
        ai.currentProvider = provider
    }

    private func loadExistingKeys() {
        for service in ai.availableServices {
            if let key = keychain.load(for: service.providerID), keyInputs[service.providerID] == nil {
                // 展示为掩码，避免明文回显
                keyInputs[service.providerID] = String(repeating: "•", count: min(key.count, 12))
            }
        }
    }

    private func save(for provider: String) {
        guard let key = keyInputs[provider], !key.isEmpty else { return }
        // 掩码内容不覆盖真实密钥
        guard !key.allSatisfy({ $0 == "•" }) else { return }
        if keychain.save(key: key, for: provider) {
            keyInputs[provider] = String(repeating: "•", count: min(key.count, 12))
            savedProvider = provider
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if savedProvider == provider { savedProvider = nil }
            }
        }
    }

    private func delete(for provider: String) {
        keychain.delete(for: provider)
        keyInputs[provider] = ""
        savedProvider = nil
    }
}
