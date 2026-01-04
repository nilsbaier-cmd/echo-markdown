import SwiftUI

struct RecordingDetailView: View {
    let recording: Recording

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Recording Info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Aufnahme vom \(recording.createdAt, style: .date)")
                        .font(.headline)
                    Text("\(recording.createdAt, style: .time)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(formatDuration(recording.duration))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Divider()

                // Transcript
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Transkript")
                            .font(.title2)
                            .fontWeight(.semibold)

                        Spacer()

                        if recording.transcript != nil {
                            Button {
                                UIPasteboard.general.string = recording.transcript
                            } label: {
                                Label("Kopieren", systemImage: "doc.on.doc")
                                    .font(.subheadline)
                            }
                        }
                    }

                    if let transcript = recording.transcript {
                        Text(transcript)
                            .font(.body)
                            .textSelection(.enabled)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    } else {
                        switch recording.status {
                        case .uploading:
                            HStack {
                                ProgressView()
                                Text("Audio wird hochgeladen...")
                                    .foregroundStyle(.secondary)
                            }
                        case .transcribing:
                            HStack {
                                ProgressView()
                                Text("Transkription läuft...")
                                    .foregroundStyle(.secondary)
                            }
                        case .recorded:
                            Text("Transkription noch nicht gestartet")
                                .foregroundStyle(.secondary)
                        case .failed:
                            Label("Transkription fehlgeschlagen", systemImage: "exclamationmark.triangle")
                                .foregroundStyle(.red)
                        default:
                            Text("Kein Transkript verfügbar")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "Dauer: %d:%02d", minutes, seconds)
    }
}
