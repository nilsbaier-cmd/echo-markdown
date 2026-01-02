import Foundation
import SwiftUI
import Combine

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var claudeAPIKey: String = ""
    @Published var assemblyAIAPIKey: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var currentStep: OnboardingStep = .welcome

    private let settingsRepository: SettingsRepositoryProtocol

    enum OnboardingStep: Int, CaseIterable {
        case welcome
        case apiKeys
        case complete
    }

    init(settingsRepository: SettingsRepositoryProtocol) {
        self.settingsRepository = settingsRepository
    }

    var canProceed: Bool {
        switch currentStep {
        case .welcome:
            return true
        case .apiKeys:
            return !claudeAPIKey.isEmpty && !assemblyAIAPIKey.isEmpty
        case .complete:
            return true
        }
    }

    func nextStep() {
        guard let nextIndex = OnboardingStep.allCases.firstIndex(of: currentStep)
            .map({ $0 + 1 }),
              nextIndex < OnboardingStep.allCases.count else {
            return
        }
        currentStep = OnboardingStep.allCases[nextIndex]
    }

    func previousStep() {
        guard let prevIndex = OnboardingStep.allCases.firstIndex(of: currentStep)
            .map({ $0 - 1 }),
              prevIndex >= 0 else {
            return
        }
        currentStep = OnboardingStep.allCases[prevIndex]
    }

    func saveAPIKeys() async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            try settingsRepository.setAPIKey(claudeAPIKey.trimmingCharacters(in: .whitespacesAndNewlines), for: .claude)
            try settingsRepository.setAPIKey(assemblyAIAPIKey.trimmingCharacters(in: .whitespacesAndNewlines), for: .assemblyAI)
            isLoading = false
            return true
        } catch {
            errorMessage = "Fehler beim Speichern der API-Keys: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
}
