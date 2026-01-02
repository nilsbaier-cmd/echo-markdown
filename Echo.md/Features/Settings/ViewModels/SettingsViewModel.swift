import Foundation
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var hasClaudeKey = false
    @Published var hasAssemblyAIKey = false
    @Published var errorMessage: String?

    private let settingsRepository: SettingsRepositoryProtocol

    init(settingsRepository: SettingsRepositoryProtocol) {
        self.settingsRepository = settingsRepository
        refreshKeyStatus()
    }

    func refreshKeyStatus() {
        hasClaudeKey = settingsRepository.getAPIKey(for: .claude) != nil
        hasAssemblyAIKey = settingsRepository.getAPIKey(for: .assemblyAI) != nil
    }

    func deleteAPIKey(for service: APIService) {
        do {
            try settingsRepository.deleteAPIKey(for: service)
            refreshKeyStatus()
        } catch {
            errorMessage = "Fehler beim Löschen: \(error.localizedDescription)"
        }
    }
}
