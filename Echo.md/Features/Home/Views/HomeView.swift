import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \Recording.createdAt, order: .reverse) private var recordings: [Recording]
    @State private var showRecording = false
    @State private var showSettings = false

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    var body: some View {
        NavigationStack {
            Group {
                if recordings.isEmpty {
                    ContentUnavailableView(
                        "Keine Aufnahmen",
                        systemImage: "waveform",
                        description: Text("Tippe auf den Button unten, um deine erste Sprachnotiz aufzunehmen.")
                    )
                } else {
                    recordingsList
                }
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

    private var recordingsList: some View {
        List {
            ForEach(recordings) { recording in
                RecordingRow(recording: recording)
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

// MARK: - Recording Row

struct RecordingRow: View {
    let recording: Recording

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "waveform")
                    .foregroundStyle(.blue)

                VStack(alignment: .leading, spacing: 4) {
                    Text(recording.createdAt, style: .date)
                        .font(.headline)
                    Text(recording.createdAt, style: .time)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(formatDuration(recording.duration))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    statusBadge
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var statusBadge: some View {
        Group {
            switch recording.status {
            case .recording:
                Label("Aufnahme", systemImage: "circle.fill")
                    .foregroundStyle(.red)
            case .recorded:
                Label("Aufgenommen", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            case .transcribing:
                Label("Transkribieren", systemImage: "waveform.circle")
                    .foregroundStyle(.orange)
            case .transcribed:
                Label("Transkribiert", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.blue)
            default:
                EmptyView()
            }
        }
        .font(.caption)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
