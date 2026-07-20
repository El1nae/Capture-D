import SwiftUI

/// AI 平台选择 + API Key 配置
struct AIConfigView: View {
    @Environment(AIManager.self) private var ai
    private let keychain = KeychainManager()

    /// 每个平台当前输入框内容（providerID -> key）
    @State private var keyInputs: [String: String] = [:]
    /// 已保存提示
    @State private var savedProvider: String?
    /// 当前聚焦的输入框
    @FocusState private var focusedProvider: String?

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
                                    .font(AppTheme.Fonts.serif(AppTheme.FontSize.body, weight: .regular))
                                    .foregroundStyle(AppTheme.Colors.primaryText)
                                Text(keychain.hasKey(for: service.providerID) ? "已配置密钥" : "未配置密钥")
                                    .font(AppTheme.Fonts.sans(AppTheme.FontSize.caption, weight: .light))
                                    .foregroundStyle(
                                        keychain.hasKey(for: service.providerID)
                                            ? AppTheme.Colors.secondaryText
                                            : AppTheme.Colors.destructive
                                    )
                            }
                            Spacer()
                            if ai.currentProvider == service.providerID {
                                Image(systemName: "checkmark")
                                    .font(.system(size: AppTheme.FontSize.body, weight: .light))
                                    .foregroundStyle(AppTheme.Colors.accent)
                            }
                        }
                    }
                }
            } header: {
                Text("选择 AI 平台")
                    .font(AppTheme.Fonts.sans(AppTheme.FontSize.footnote, weight: .regular))
                    .tracking(1.5)
                    .textCase(.uppercase)
            } footer: {
                Text("当前使用：\(ai.currentService.displayName)")
                    .font(AppTheme.Fonts.sans(AppTheme.FontSize.footnote, weight: .light))
            }

            // MARK: - API Key 输入
            ForEach(ai.availableServices, id: \.providerID) { service in
                Section {
                    SecureField("输入 \(service.displayName) API Key", text: binding(for: service.providerID))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .font(AppTheme.Fonts.sans(AppTheme.FontSize.body, weight: .light))
                        .focused($focusedProvider, equals: service.providerID)
                        .padding(.vertical, AppTheme.Spacing.sm)
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                                .stroke(
                                    focusedProvider == service.providerID
                                        ? AppTheme.Colors.accent
                                        : AppTheme.Colors.primaryText.opacity(0.08),
                                    lineWidth: 0.5
                                )
                        )
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)

                    HStack {
                        Button {
                            save(for: service.providerID)
                        } label: {
                            Text("保存")
                                .font(AppTheme.Fonts.serif(AppTheme.FontSize.body, weight: .regular))
                        }
                        .disabled((keyInputs[service.providerID] ?? "").isEmpty)

                        Spacer()

                        if savedProvider == service.providerID {
                            Label("已保存", systemImage: "checkmark.circle.fill")
                                .font(AppTheme.Fonts.sans(AppTheme.FontSize.caption, weight: .light))
                                .foregroundStyle(AppTheme.Colors.accent)
                        } else if keychain.hasKey(for: service.providerID) {
                            Button(role: .destructive) {
                                delete(for: service.providerID)
                            } label: {
                                Text("清除")
                                    .font(AppTheme.Fonts.serif(AppTheme.FontSize.caption, weight: .regular))
                            }
                        }
                    }
                } header: {
                    Text("\(service.displayName) 密钥")
                        .font(AppTheme.Fonts.sans(AppTheme.FontSize.footnote, weight: .regular))
                        .tracking(1.5)
                        .textCase(.uppercase)
                }
            }

            // MARK: - 帮助
            Section {
                NavigationLink {
                    APIKeyGuideView()
                } label: {
                    Label("如何获取 API Key？", systemImage: "questionmark.circle")
                        .font(AppTheme.Fonts.serif(AppTheme.FontSize.body, weight: .light))
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
