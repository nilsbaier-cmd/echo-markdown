import SwiftUI
import SwiftData

// MARK: - Recording View

struct RecordingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: RecordingViewModel

    @State private var showReflect = false
    @State private var showEditor = false
    @State private var enrichedTranscript: String = ""

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
        _viewModel = StateObject(wrappedValue: RecordingViewModel(
            recordingUseCase: container.recordingUseCase,
            transcriptionUseCase: container.transcriptionUseCase,
            audioService: container.audioService,
            hapticService: container.hapticService
        ))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Main Recording UI
                mainContent

                // Transcription Overlay
                if viewModel.isTranscribing {
                    transcribingOverlay
                }
            }
            .navigationTitle("Aufnahme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !viewModel.isTranscribing {
                        Button("Abbrechen") {
                            dismiss()
                        }
                    }
                }
            }
        }
        .onChange(of: viewModel.shouldNavigateToReflect) { _, shouldNavigate in
            if shouldNavigate {
                showReflect = true
                viewModel.resetNavigation()
            }
        }
        .fullScreenCover(isPresented: $showReflect) {
            if let recording = viewModel.transcribedRecording {
                ReflectView(
                    recording: recording,
                    container: container,
                    modelContext: modelContext
                ) { transcript in
                    enrichedTranscript = transcript
                    showReflect = false
                    showEditor = true
                }
            }
        }
        .fullScreenCover(isPresented: $showEditor) {
            if let recording = viewModel.transcribedRecording {
                EditorView(
                    transcript: enrichedTranscript,
                    recording: recording,
                    container: container
                )
            }
        }
        .onChange(of: showEditor) { _, isShowing in
            if !isShowing {
                // Editor was dismissed - go back to home
                dismiss()
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

    // MARK: - Main Content

    private var mainContent: some View {
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
    }

    // MARK: - Record Button

    private var recordButton: some View {
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
        .disabled(viewModel.isTranscribing)
    }

    // MARK: - Transcribing Overlay

    private var transcribingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)

                Text("Transkribiere Aufnahme...")
                    .font(.headline)
                    .foregroundStyle(.white)

                Text("Dies kann einen Moment dauern")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(40)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }

    // MARK: - Helpers

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        let milliseconds = Int((duration.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
}
