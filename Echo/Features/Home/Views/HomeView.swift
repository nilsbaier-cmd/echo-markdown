import SwiftUI

struct HomeView: View {
    @Environment(\.container) private var container
    @State private var showRecording = false
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            VStack {
                // Recordings list will go here
                ContentUnavailableView(
                    "Keine Aufnahmen",
                    systemImage: "waveform",
                    description: Text("Tippe auf den Button unten, um deine erste Sprachnotiz aufzunehmen.")
                )
            }
            .navigationTitle("Echo")
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
                RecordingView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
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

#Preview {
    HomeView()
}
