import SwiftUI
import SwiftData

// MARK: - Reflect View

struct ReflectView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: ReflectViewModel

    let recording: Recording
    let onComplete: (String) -> Void

    private let container: DependencyContainer

    init(
        recording: Recording,
        container: DependencyContainer,
        modelContext: ModelContext,
        onComplete: @escaping (String) -> Void
    ) {
        self.recording = recording
        self.container = container
        self.onComplete = onComplete
        _viewModel = StateObject(wrappedValue: ReflectViewModel(
            reflectUseCase: container.reflectUseCase,
            transcriptionUseCase: container.transcriptionUseCase,
            audioService: container.audioService,
            hapticService: container.hapticService,
            modelContext: modelContext
        ))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                mainContent

                if case .error(let message) = viewModel.state {
                    errorOverlay(message: message)
                }
            }
            .navigationTitle("Reflect")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    endSessionButton
                }
            }
        }
        .interactiveDismissDisabled()
        .task {
            if let transcript = recording.transcript {
                await viewModel.startSession(transcript: transcript, recording: recording)
            }
        }
        .onChange(of: viewModel.state) { _, newState in
            if case .completed(let enrichedTranscript) = newState {
                onComplete(enrichedTranscript)
            }
        }
    }

    // MARK: - Main Content

    @ViewBuilder
    private var mainContent: some View {
        switch viewModel.state {
        case .initial, .loadingQuestions:
            loadingView(text: "Generiere Rueckfragen...")

        case .showingQuestions:
            questionsView

        case .recordingAnswer:
            recordingView

        case .transcribingAnswer:
            loadingView(text: "Transkribiere Antwort...")

        case .generatingFollowUp:
            loadingView(text: "Generiere weitere Fragen...")

        case .integrating:
            loadingView(text: "Bereite Text vor...")

        case .completed:
            loadingView(text: "Fertig!")

        case .error:
            questionsView
        }
    }

    // MARK: - Loading View

    private func loadingView(text: String) -> some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.5)
            Text(text)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Questions View

    private var questionsView: some View {
        VStack(spacing: 0) {
            // Stats Header
            statsHeader

            // Questions List
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.visibleQuestions) { question in
                            ReflectQuestionCard(
                                question: question,
                                isSelected: viewModel.selectedQuestionId == question.id,
                                onSelect: { viewModel.selectQuestion(question.id) }
                            )
                            .id(question.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.visibleQuestions.count) { _, _ in
                    // Scroll to newest question
                    if let lastQuestion = viewModel.visibleQuestions.last {
                        withAnimation {
                            proxy.scrollTo(lastQuestion.id, anchor: .bottom)
                        }
                    }
                }
            }

            // Answer Input
            if viewModel.selectedQuestion != nil {
                answerInputArea
            }
        }
    }

    // MARK: - Stats Header

    private var statsHeader: some View {
        HStack {
            Image(systemName: "bubble.left.and.bubble.right")
                .foregroundStyle(.blue)

            Text("\(viewModel.answeredCount) von \(viewModel.totalCount) beantwortet")
                .font(.subheadline)

            Spacer()

            if let session = viewModel.session {
                Text("Runde \(session.currentIteration + 1)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
    }

    // MARK: - Answer Input Area

    private var answerInputArea: some View {
        VStack(spacing: 0) {
            Divider()

            ReflectAnswerInput(
                textAnswer: $viewModel.textAnswer,
                isRecording: viewModel.isRecordingAnswer,
                currentPower: viewModel.currentAnswerPower,
                onStartRecording: {
                    Task { await viewModel.startRecordingAnswer() }
                },
                onStopRecording: {
                    Task { await viewModel.stopRecordingAnswer() }
                },
                onSubmitText: {
                    Task { await viewModel.submitTextAnswer() }
                },
                onCancel: {
                    viewModel.deselectQuestion()
                }
            )
            .padding()
            .background(Color(.systemBackground))
        }
    }

    // MARK: - Recording View

    private var recordingView: some View {
        VStack(spacing: 32) {
            Spacer()

            if let question = viewModel.selectedQuestion {
                Text(question.question)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Text("Aufnahme laeuft...")
                .foregroundStyle(.secondary)

            WaveformView(power: viewModel.currentAnswerPower)
                .frame(height: 80)
                .padding(.horizontal, 40)

            Button {
                Task { await viewModel.stopRecordingAnswer() }
            } label: {
                ZStack {
                    Circle()
                        .fill(.red)
                        .frame(width: 80, height: 80)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(.white)
                        .frame(width: 24, height: 24)
                }
            }

            Spacer()
        }
    }

    // MARK: - End Session Button (immer sichtbar)

    @ViewBuilder
    private var endSessionButton: some View {
        if viewModel.canEndSession {
            Button("Beenden") {
                Task { await viewModel.endSession() }
            }
            .fontWeight(.semibold)
        }
    }

    // MARK: - Error Overlay

    private func errorOverlay(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundStyle(.orange)

            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Button("Abbrechen") {
                    onComplete(recording.transcript ?? "")
                }
                .buttonStyle(.bordered)

                Button("Erneut versuchen") {
                    Task {
                        if let transcript = recording.transcript {
                            await viewModel.startSession(transcript: transcript, recording: recording)
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
    }
}
