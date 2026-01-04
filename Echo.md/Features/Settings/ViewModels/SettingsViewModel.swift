import Foundation
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var claudeAPIKey = ""
    @Published var assemblyAIAPIKey = ""
    @Published var hasClaudeKey = false
    @Published var hasAssemblyAIKey = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let settingsRepository: SettingsRepositoryProtocol

    init(settingsRepository: SettingsRepositoryProtocol) {
        self.settingsRepository = settingsRepository
        loadAPIKeys()
    }

    func loadAPIKeys() {
        claudeAPIKey = settingsRepository.getAPIKey(for: .claude) ?? ""
        assemblyAIAPIKey = settingsRepository.getAPIKey(for: .assemblyAI) ?? ""
        refreshKeyStatus()
    }

    func refreshKeyStatus() {
        hasClaudeKey = !claudeAPIKey.isEmpty
        hasAssemblyAIKey = !assemblyAIAPIKey.isEmpty
    }

    func saveAPIKeys() {
        errorMessage = nil
        successMessage = nil

        do {
            if !claudeAPIKey.isEmpty {
                try settingsRepository.setAPIKey(claudeAPIKey.trimmingCharacters(in: .whitespacesAndNewlines), for: .claude)
            }
            if !assemblyAIAPIKey.isEmpty {
                try settingsRepository.setAPIKey(assemblyAIAPIKey.trimmingCharacters(in: .whitespacesAndNewlines), for: .assemblyAI)
            }
            refreshKeyStatus()
            successMessage = "API-Keys erfolgreich gespeichert"
        } catch {
            errorMessage = "Fehler beim Speichern: \(error.localizedDescription)"
        }
    }

    func deleteAPIKey(for service: APIService) {
        do {
            try settingsRepository.deleteAPIKey(for: service)
            loadAPIKeys()
        } catch {
            errorMessage = "Fehler beim Löschen: \(error.localizedDescription)"
        }
    }
}
