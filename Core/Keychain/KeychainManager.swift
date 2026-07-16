import Foundation
import Security

/// Keychain 管理器 — API Key 安全存取
final class KeychainManager {
    private let servicePrefix = "com.captured.apikey."

    /// 保存 API Key
    func save(key: String, for provider: String) -> Bool {
        let service = servicePrefix + provider
        delete(for: provider)
        guard let data = key.data(using: .utf8) else { return false }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }

    /// 读取 API Key
    func load(for provider: String) -> String? {
        let service = servicePrefix + provider
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// 删除 API Key
    @discardableResult
    func delete(for provider: String) -> Bool {
        let service = servicePrefix + provider
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        return SecItemDelete(query as CFDictionary) == errSecSuccess
    }

    /// 检查某个 AI 平台是否已配置 API Key
    func hasKey(for provider: String) -> Bool {
        load(for: provider) != nil
    }
}
