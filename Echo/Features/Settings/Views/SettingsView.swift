import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: SettingsViewModel

    init() {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(
            settingsRepository: SettingsRepository(
                keychainService: KeychainService(),
                userDefaults: .standard
            )
        ))
    }

    var body: some View {
        NavigationStack {
            List {
                // API Keys Section
                Section("API-Schlüssel") {
                    HStack {
                        Label("Claude", systemImage: "brain")
                        Spacer()
                        if viewModel.hasClaudeKey {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }

                    HStack {
                        Label("AssemblyAI", systemImage: "waveform")
                        Spacer()
                        if viewModel.hasAssemblyAIKey {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                }

                // Export Section
                Section("Export") {
                    HStack {
                        Label("Obsidian Vault", systemImage: "folder")
                        Spacer()
                        if viewModel.hasVaultConfigured {
                            Text("Konfiguriert")
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Nicht konfiguriert")
                                .foregroundStyle(.red)
                        }
                    }
                }

                // About Section
                Section("Info") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 MVP")
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

#Preview {
    SettingsView()
}
