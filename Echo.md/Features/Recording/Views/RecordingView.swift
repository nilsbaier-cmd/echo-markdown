import SwiftUI

struct RecordingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: RecordingViewModel

    init(container: DependencyContainer) {
        _viewModel = StateObject(wrappedValue: RecordingViewModel(
            recordingUseCase: container.recordingUseCase,
            transcriptionUseCase: container.transcriptionUseCase,
            audioService: container.audioService,
            hapticService: container.hapticService
        ))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                WaveformView(power: viewModel.currentPower)
                    .frame(height: 100)

                Text(formatDuration(viewModel.recordingDuration))
                    .font(.system(size: 48, weight: .light, design: .monospaced))
                    .foregroundStyle(viewModel.isRecording ? .red : .primary)

                Spacer()

                recordButton
            }
            .padding()
            .navigationTitle("Aufnahme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var recordButton: some View {
        Button {
            Task {
                if viewModel.isRecording {
                    await viewModel.stopRecording()
                    dismiss()
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
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        let milliseconds = Int((duration.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
}
