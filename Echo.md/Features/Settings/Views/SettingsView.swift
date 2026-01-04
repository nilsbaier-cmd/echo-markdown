import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: SettingsViewModel

    init(settingsRepository: SettingsRepositoryProtocol) {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(
            settingsRepository: settingsRepository
        ))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Claude API-Key")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        SecureField("Dein Claude API-Key", text: $viewModel.claudeAPIKey)
                            .textContentType(.password)
                            .autocorrectionDisabled()
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("AssemblyAI API-Key")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        SecureField("Dein AssemblyAI API-Key", text: $viewModel.assemblyAIAPIKey)
                            .textContentType(.password)
                            .autocorrectionDisabled()
                    }

                    Button {
                        viewModel.saveAPIKeys()
                    } label: {
                        Text("Speichern")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .listRowBackground(Color.clear)

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    if let success = viewModel.successMessage {
                        Text(success)
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                } header: {
                    Text("API-Schlüssel")
                }

                Section("Über") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Einstellungen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fertig") {
                        dismiss()
                    }
                }
            }
        }
    }
}
