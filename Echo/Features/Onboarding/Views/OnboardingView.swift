import SwiftUI

struct OnboardingView: View {
    @Environment(\.container) private var container
    @StateObject private var viewModel: OnboardingViewModel
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    init() {
        // Temporary initialization - will be replaced by container
        _viewModel = StateObject(wrappedValue: OnboardingViewModel(
            settingsRepository: SettingsRepository(
                keychainService: KeychainService(),
                userDefaults: .standard
            )
        ))
    }

    var body: some View {
        NavigationStack {
            VStack {
                switch viewModel.currentStep {
                case .welcome:
                    welcomeView
                case .apiKeys:
                    apiKeysView
                case .complete:
                    completeView
                }
            }
            .padding()
            .navigationTitle("Echo.md einrichten")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Welcome

    private var welcomeView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue)

            Text("Willkommen bei Echo.md")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Verwandle deine Sprachnotizen in strukturierte Texte mit KI-Unterstützung.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            Button {
                viewModel.nextStep()
            } label: {
                Text("Einrichtung starten")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }

    // MARK: - API Keys

    private var apiKeysView: some View {
        VStack(spacing: 24) {
            Text("API-Schlüssel eingeben")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Echo.md benötigt Zugang zu AssemblyAI (Transkription) und Claude (Textverarbeitung).")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 8) {
                Text("AssemblyAI API-Key")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                SecureField("Dein AssemblyAI API-Key", text: $viewModel.assemblyAIAPIKey)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.password)
                    .autocorrectionDisabled()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Claude API-Key")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                SecureField("Dein Claude API-Key", text: $viewModel.claudeAPIKey)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.password)
                    .autocorrectionDisabled()
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Spacer()

            HStack {
                Button("Zurück") {
                    viewModel.previousStep()
                }
                .buttonStyle(.bordered)

                Spacer()

                Button {
                    Task {
                        if await viewModel.saveAPIKeys() {
                            viewModel.nextStep()
                        }
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Text("Weiter")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canProceed || viewModel.isLoading)
            }
        }
    }

    // MARK: - Complete

    private var completeView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)

            Text("Einrichtung abgeschlossen!")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Du kannst jetzt mit Echo.md Sprachnotizen aufnehmen und in Text umwandeln.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            Button {
                hasCompletedOnboarding = true
            } label: {
                Text("Los geht's")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
}

#Preview {
    OnboardingView()
}
