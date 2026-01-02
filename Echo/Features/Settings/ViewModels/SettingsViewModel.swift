import Foundation
import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var hasClaudeKey: Bool = false
    @Published var hasAssemblyAIKey: Bool = false
    @Published var hasVaultConfigured: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let settingsRepository: SettingsRepositoryProtocol

    init(settingsRepository: SettingsRepositoryProtocol) {
        self.settingsRepository = settingsRepository
        refreshStatus()
    }

    func refreshStatus() {
        hasClaudeKey = settingsRepository.getAPIKey(for: .claude) != nil
        hasAssemblyAIKey = settingsRepository.getAPIKey(for: .assemblyAI) != nil
        hasVaultConfigured = settingsRepository.getVaultBookmark() != nil
    }

    func updateClaudeKey(_ key: String) {
        do {
            try settingsRepository.setAPIKey(key, for: .claude)
            hasClaudeKey = true
            successMessage = "Claude API-Key gespeichert"
        } catch {
            errorMessage = "Fehler beim Speichern: \(error.localizedDescription)"
        }
    }

    func updateAssemblyAIKey(_ key: String) {
        do {
            try settingsRepository.setAPIKey(key, for: .assemblyAI)
            hasAssemblyAIKey = true
            successMessage = "AssemblyAI API-Key gespeichert"
        } catch {
            errorMessage = "Fehler beim Speichern: \(error.localizedDescription)"
        }
    }

    func deleteClaudeKey() {
        do {
            try settingsRepository.deleteAPIKey(for: .claude)
            hasClaudeKey = false
            successMessage = "Claude API-Key gelöscht"
        } catch {
            errorMessage = "Fehler beim Löschen: \(error.localizedDescription)"
        }
    }

    func deleteAssemblyAIKey() {
        do {
            try settingsRepository.deleteAPIKey(for: .assemblyAI)
            hasAssemblyAIKey = false
            successMessage = "AssemblyAI API-Key gelöscht"
        } catch {
            errorMessage = "Fehler beim Löschen: \(error.localizedDescription)"
        }
    }

    func setVaultBookmark(_ data: Data) {
        do {
            try settingsRepository.setVaultBookmark(data)
            hasVaultConfigured = true
            successMessage = "Obsidian-Vault konfiguriert"
        } catch {
            errorMessage = "Fehler beim Speichern: \(error.localizedDescription)"
        }
    }
}
