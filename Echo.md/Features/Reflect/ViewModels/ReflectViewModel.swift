import Foundation
import Combine
import SwiftUI
import SwiftData

// MARK: - Reflect State

enum ReflectState: Equatable {
    case initial
    case loadingQuestions
    case showingQuestions
    case recordingAnswer
    case transcribingAnswer
    case generatingFollowUp
    case integrating
    case completed(enrichedTranscript: String)
    case error(String)

    static func == (lhs: ReflectState, rhs: ReflectState) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial),
             (.loadingQuestions, .loadingQuestions),
             (.showingQuestions, .showingQuestions),
             (.recordingAnswer, .recordingAnswer),
             (.transcribingAnswer, .transcribingAnswer),
             (.generatingFollowUp, .generatingFollowUp),
             (.integrating, .integrating):
            return true
        case (.completed(let a), .completed(let b)):
            return a == b
        case (.error(let a), .error(let b)):
            return a == b
        default:
            return false
        }
    }
}

// MARK: - Reflect View Model

@MainActor
final class ReflectViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var state: ReflectState = .initial
    @Published var session: ReflectSession?
    @Published var visibleQuestions: [ReflectQuestion] = []
    @Published var selectedQuestionId: UUID?
    @Published var textAnswer: String = ""
    @Published var isRecordingAnswer = false
    @Published var currentAnswerPower: Float = -160

    // MARK: - Dependencies

    private let reflectUseCase: ReflectUseCaseProtocol
    private let transcriptionUseCase: TranscriptionUseCaseProtocol
    private let audioService: AudioServiceProtocol
    private let hapticService: HapticServiceProtocol
    private let modelContext: ModelContext

    // MARK: - Private State

    private var answerRecordingURL: URL?
    private var meteringTimer: Timer?

    // MARK: - Computed Properties

    var selectedQuestion: ReflectQuestion? {
        visibleQuestions.first { $0.id == selectedQuestionId }
    }

    var unansweredQuestions: [ReflectQuestion] {
        visibleQuestions.filter { !$0.isAnswered }
    }

    var canEndSession: Bool {
        state == .showingQuestions
    }

    var answeredCount: Int {
        visibleQuestions.filter { $0.isAnswered }.count
    }

    var totalCount: Int {
        visibleQuestions.count
    }

    // MARK: - Init

    init(
        reflectUseCase: ReflectUseCaseProtocol,
        transcriptionUseCase: TranscriptionUseCaseProtocol,
        audioService: AudioServiceProtocol,
        hapticService: HapticServiceProtocol,
        modelContext: ModelContext
    ) {
        self.reflectUseCase = reflectUseCase
        self.transcriptionUseCase = transcriptionUseCase
        self.audioService = audioService
        self.hapticService = hapticService
        self.modelContext = modelContext
    }

    // MARK: - Session Management

    func startSession(transcript: String, recording: Recording) async {
        state = .loadingQuestions
        hapticService.impact(.light)

        // Create and persist session
        let newSession = ReflectSession(originalTranscript: transcript)
        newSession.recording = recording
        recording.reflectSession = newSession
        modelContext.insert(newSession)

        do {
            try modelContext.save()
            session = newSession

            // Generate initial questions
            let questions = try await reflectUseCase.generateQuestions(for: transcript)

            // Add to session
            for question in questions {
                modelContext.insert(question)
            }
            newSession.addQuestions(questions)
            try modelContext.save()

            visibleQuestions = questions
            state = .showingQuestions
            hapticService.notification(.success)

        } catch {
            state = .error("Fragen konnten nicht generiert werden: \(error.localizedDescription)")
            hapticService.notification(.error)
        }
    }

    func endSession() async {
        guard let session = session else { return }

        state = .integrating
        hapticService.impact(.medium)

        do {
            let enrichedTranscript: String

            if session.hasAnswers {
                enrichedTranscript = try await reflectUseCase.integrateAnswers(
                    originalTranscript: session.originalTranscript,
                    answeredQuestions: session.answeredQuestions
                )
            } else {
                enrichedTranscript = session.originalTranscript
            }

            // Update session
            session.enrichedTranscript = enrichedTranscript
            session.isCompleted = true
            session.completedAt = Date()
            try modelContext.save()

            state = .completed(enrichedTranscript: enrichedTranscript)
            hapticService.notification(.success)

        } catch {
            // Fallback: use original transcript
            let fallbackTranscript = session.originalTranscript
            session.enrichedTranscript = fallbackTranscript
            session.isCompleted = true
            session.completedAt = Date()
            try? modelContext.save()

            state = .completed(enrichedTranscript: fallbackTranscript)
            hapticService.notification(.warning)
        }
    }

    // MARK: - Question Selection

    func selectQuestion(_ id: UUID) {
        guard unansweredQuestions.contains(where: { $0.id == id }) else { return }
        selectedQuestionId = id
        textAnswer = ""
        hapticService.impact(.light)
    }

    func deselectQuestion() {
        selectedQuestionId = nil
        textAnswer = ""
    }

    // MARK: - Audio Recording

    func startRecordingAnswer() async {
        guard selectedQuestionId != nil else { return }

        hapticService.impact(.medium)

        do {
            answerRecordingURL = try await audioService.startRecording()
            isRecordingAnswer = true
            state = .recordingAnswer
            startMetering()
        } catch {
            state = .error("Aufnahme konnte nicht gestartet werden")
            hapticService.notification(.error)
        }
    }

    func stopRecordingAnswer() async {
        hapticService.impact(.medium)
        stopMetering()
        isRecordingAnswer = false

        do {
            try await audioService.stopRecording()

            guard let url = answerRecordingURL else {
                state = .showingQuestions
                return
            }

            state = .transcribingAnswer

            // Create temporary recording for transcription
            let tempRecording = Recording(audioURL: url)

            // Transcribe the answer
            let transcribedAnswer = try await transcriptionUseCase.transcribe(tempRecording)

            // Delete temporary audio file
            try? FileManager.default.removeItem(at: url)
            answerRecordingURL = nil

            await submitAnswer(transcribedAnswer, source: .audio)

        } catch {
            // Clean up on error
            if let url = answerRecordingURL {
                try? FileManager.default.removeItem(at: url)
                answerRecordingURL = nil
            }
            state = .showingQuestions
            hapticService.notification(.error)
        }
    }

    // MARK: - Text Answer

    func submitTextAnswer() async {
        let trimmedAnswer = textAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedAnswer.isEmpty else { return }

        await submitAnswer(trimmedAnswer, source: .text)
        textAnswer = ""
    }

    // MARK: - Answer Processing (triggers automatic follow-up)

    private func submitAnswer(_ answer: String, source: AnswerSource) async {
        guard let questionId = selectedQuestionId,
              let session = session else { return }

        hapticService.notification(.success)

        // Update question in session
        session.answerQuestion(id: questionId, answer: answer, source: source)

        // Update local state
        if let index = visibleQuestions.firstIndex(where: { $0.id == questionId }) {
            visibleQuestions[index].answer = answer
            visibleQuestions[index].answerSource = source
        }

        selectedQuestionId = nil

        do {
            try modelContext.save()
        } catch {
            print("Failed to save answer: \(error)")
        }

        // AUTOMATIC: Generate follow-up questions
        await generateFollowUpQuestions()
    }

    // MARK: - Automatic Follow-up Generation

    private func generateFollowUpQuestions() async {
        guard let session = session else { return }

        state = .generatingFollowUp

        do {
            let followUpQuestions = try await reflectUseCase.generateFollowUpQuestions(
                originalTranscript: session.originalTranscript,
                answeredQuestions: session.answeredQuestions
            )

            if followUpQuestions.isEmpty {
                // No more questions - dialog is complete
                // But don't auto-end, let user decide
                state = .showingQuestions
                return
            }

            // Insert new questions into context
            for question in followUpQuestions {
                modelContext.insert(question)
            }

            // Add new questions to session
            session.addQuestions(followUpQuestions)
            try modelContext.save()

            // Add to visible questions (keep answered ones visible too)
            visibleQuestions.append(contentsOf: followUpQuestions)

            state = .showingQuestions
            hapticService.impact(.light)

        } catch {
            // On error, just stay in showingQuestions state
            state = .showingQuestions
            print("Failed to generate follow-up questions: \(error)")
        }
    }

    // MARK: - Private Helpers

    private func startMetering() {
        meteringTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.currentAnswerPower = self?.audioService.getAveragePower() ?? -160
            }
        }
    }

    private func stopMetering() {
        meteringTimer?.invalidate()
        meteringTimer = nil
        currentAnswerPower = -160
    }
}
