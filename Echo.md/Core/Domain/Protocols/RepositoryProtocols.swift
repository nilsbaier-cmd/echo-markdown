import Foundation

// MARK: - Recording Repository

protocol RecordingRepositoryProtocol {
    func save(_ recording: Recording) async throws
    func fetchAll() async throws -> [Recording]
    func fetch(by id: UUID) async throws -> Recording?
    func delete(_ recording: Recording) async throws
    func deleteAll() async throws
}

// MARK: - Settings Repository

protocol SettingsRepositoryProtocol {
    func getAPIKey(for service: APIService) -> String?
    func setAPIKey(_ key: String, for service: APIService) throws
    func deleteAPIKey(for service: APIService) throws
    func hasValidAPIKeys() -> Bool

    func getVaultBookmark() -> Data?
    func setVaultBookmark(_ data: Data) throws
}
