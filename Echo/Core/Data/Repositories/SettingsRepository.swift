import Foundation

final class SettingsRepository: SettingsRepositoryProtocol {
    private let keychainService: KeychainServiceProtocol
    private let userDefaults: UserDefaults

    private enum Keys {
        static let vaultBookmark = "echo.vault.bookmark"
    }

    init(keychainService: KeychainServiceProtocol, userDefaults: UserDefaults) {
        self.keychainService = keychainService
        self.userDefaults = userDefaults
    }

    // MARK: - API Keys

    func getAPIKey(for service: APIService) -> String? {
        keychainService.get(key: service.keychainKey)
    }

    func setAPIKey(_ key: String, for service: APIService) throws {
        try keychainService.save(key: service.keychainKey, value: key)
    }

    func deleteAPIKey(for service: APIService) throws {
        try keychainService.delete(key: service.keychainKey)
    }

    func hasValidAPIKeys() -> Bool {
        let claudeKey = getAPIKey(for: .claude)
        let assemblyKey = getAPIKey(for: .assemblyAI)
        return claudeKey != nil && !claudeKey!.isEmpty &&
               assemblyKey != nil && !assemblyKey!.isEmpty
    }

    // MARK: - Vault Bookmark

    func getVaultBookmark() -> Data? {
        userDefaults.data(forKey: Keys.vaultBookmark)
    }

    func setVaultBookmark(_ data: Data) throws {
        userDefaults.set(data, forKey: Keys.vaultBookmark)
    }
}
