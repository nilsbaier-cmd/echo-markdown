import Foundation

final class ShadowReaderUseCase: ShadowReaderUseCaseProtocol {
    private let claudeService: ClaudeServiceProtocol

    init(claudeService: ClaudeServiceProtocol) {
        self.claudeService = claudeService
    }

    func analyzeTranscript(_ transcript: String) async throws -> [ShadowReaderQuestion] {
        let questions = try await claudeService.generateShadowReaderQuestions(transcript: transcript)

        return questions.map { questionText in
            ShadowReaderQuestion(
                question: questionText,
                context: transcript
            )
        }
    }

    func answerQuestion(_ question: ShadowReaderQuestion, answer: String) async throws -> String {
        // Combine original context with the answer
        let enrichedContext = """
        Ursprünglicher Gedanke:
        \(question.context)

        Rückfrage: \(question.question)
        Antwort: \(answer)
        """

        return enrichedContext
    }
}
