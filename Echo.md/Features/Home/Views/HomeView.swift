import SwiftUI

struct HomeView: View {
    @State private var showRecording = false
    @State private var showSettings = false

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    var body: some View {
        NavigationStack {
            VStack {
                ContentUnavailableView(
                    "Keine Aufnahmen",
                    systemImage: "waveform",
                    description: Text("Tippe auf den Button unten, um deine erste Sprachnotiz aufzunehmen.")
                )
            }
            .navigationTitle("Echo.md")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                recordButton
            }
            .sheet(isPresented: $showRecording) {
                RecordingView(container: container)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(settingsRepository: container.settingsRepository)
            }
        }
    }

    private var recordButton: some View {
        Button {
            showRecording = true
        } label: {
            HStack {
                Image(systemName: "mic.fill")
                Text("Aufnahme starten")
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(.blue)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding()
    }
}
