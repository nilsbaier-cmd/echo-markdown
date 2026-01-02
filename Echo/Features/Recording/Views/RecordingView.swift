import SwiftUI

struct RecordingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.container) private var container
    @StateObject private var viewModel: RecordingViewModel

    init() {
        // Temporary initialization
        _viewModel = StateObject(wrappedValue: RecordingViewModel(
            recordingUseCase: RecordingUseCase(
                audioService: AudioService(),
                recordingRepository: RecordingRepository(coreDataService: CoreDataService())
            ),
            audioService: AudioService(),
            hapticService: HapticService()
        ))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                // Waveform visualization
                WaveformView(levels: viewModel.audioLevels)
                    .frame(height: 100)
                    .padding(.horizontal)

                // Duration
                Text(viewModel.formattedDuration)
                    .font(.system(size: 48, weight: .light, design: .monospaced))
                    .foregroundStyle(viewModel.isRecording ? .red : .primary)

                Spacer()

                // Record button
                Button {
                    Task {
                        if viewModel.isRecording {
                            await viewModel.stopRecording()
                        } else {
                            await viewModel.startRecording()
                        }
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(viewModel.isRecording ? .red : .blue)
                            .frame(width: 80, height: 80)

                        if viewModel.isRecording {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.white)
                                .frame(width: 24, height: 24)
                        } else {
                            Circle()
                                .fill(.white)
                                .frame(width: 24, height: 24)
                        }
                    }
                }
                .scaleEffect(viewModel.isRecording ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: viewModel.isRecording)

                Text(viewModel.isRecording ? "Tippe zum Stoppen" : "Tippe zum Starten")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .navigationTitle("Aufnahme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }

                if !viewModel.isRecording && viewModel.currentRecording != nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Weiter") {
                            // Navigate to transcription
                        }
                    }
                }
            }
            .alert("Fehler", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}

#Preview {
    RecordingView()
}
