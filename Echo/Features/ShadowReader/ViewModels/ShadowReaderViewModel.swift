import Foundation
import SwiftUI

@MainActor
final class ShadowReaderViewModel: ObservableObject {
    @Published var questions: [ShadowReaderQuestion] = []
    @Published var currentQuestionIndex: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var enrichedTranscript: String = ""

    private let transcriptionUseCase: TranscriptionUseCaseProtocol
    private let shadowReaderUseCase: ShadowReaderUseCaseProtocol

    private var originalTranscript: String = ""

    init(
        transcriptionUseCase: TranscriptionUseCaseProtocol,
        shadowReaderUseCase: ShadowReaderUseCaseProtocol
    ) {
        self.transcriptionUseCase = transcriptionUseCase
        self.shadowReaderUseCase = shadowReaderUseCase
    }

    var currentQuestion: ShadowReaderQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }

    var hasMoreQuestions: Bool {
        currentQuestionIndex < questions.count - 1
    }

    func transcribeAndAnalyze(recording: Recording) async {
        isLoading = true
        errorMessage = nil

        do {
            // Step 1: Transcribe
            originalTranscript = try await transcriptionUseCase.transcribe(recording: recording)

            // Step 2: Generate questions
            questions = try await shadowReaderUseCase.analyzeTranscript(originalTranscript)
            enrichedTranscript = originalTranscript

            currentQuestionIndex = 0
        } catch {
            errorMessage = "Fehler: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func answerCurrentQuestion(_ answer: String) async {
        guard var question = currentQuestion else { return }

        question.answer = answer

        do {
            enrichedTranscript = try await shadowReaderUseCase.answerQuestion(question, answer: answer)
            questions[currentQuestionIndex] = question
        } catch {
            errorMessage = "Fehler beim Verarbeiten der Antwort"
        }
    }

    func nextQuestion() {
        if hasMoreQuestions {
            currentQuestionIndex += 1
        }
    }

    func skipQuestion() {
        nextQuestion()
    }
}
