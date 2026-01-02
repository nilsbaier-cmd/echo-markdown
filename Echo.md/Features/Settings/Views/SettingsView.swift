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
            List {
                Section("API-Schlüssel") {
                    HStack {
                        Text("Claude")
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
                        Text("AssemblyAI")
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
