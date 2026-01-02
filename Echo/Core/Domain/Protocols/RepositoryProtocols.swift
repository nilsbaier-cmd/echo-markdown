import Foundation

// MARK: - Recording Repository

protocol RecordingRepositoryProtocol {
    func save(_ recording: Recording) async throws
    func fetch(id: UUID) async throws -> Recording?
    func fetchAll() async throws -> [Recording]
    func delete(id: UUID) async throws
    func update(_ recording: Recording) async throws
}

// MARK: - Settings Repository

protocol SettingsRepositoryProtocol {
    func getAPIKey(for service: APIService) -> String?
    func setAPIKey(_ key: String, for service: APIService) throws
    func deleteAPIKey(for service: APIService) throws
    func getVaultBookmark() -> Data?
    func setVaultBookmark(_ data: Data) throws
    func hasValidAPIKeys() -> Bool
}
