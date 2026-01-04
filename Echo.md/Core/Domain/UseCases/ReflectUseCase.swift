import Foundation

// MARK: - Reflect Use Case

final class ReflectUseCase: ReflectUseCaseProtocol {
    private let claudeService: ClaudeServiceProtocol

    init(claudeService: ClaudeServiceProtocol) {
        self.claudeService = claudeService
    }

    // MARK: - Generate Initial Questions

    func generateQuestions(for transcript: String) async throws -> [ReflectQuestion] {
        let questions = try await claudeService.generateReflectQuestions(transcript: transcript)
        return questions.map { ReflectQuestion(question: $0, iteration: 0) }
    }

    // MARK: - Generate Follow-up Questions

    func generateFollowUpQuestions(
        originalTranscript: String,
        answeredQuestions: [ReflectQuestion]
    ) async throws -> [ReflectQuestion] {

        // Build Q&A history from answered questions
        let qaHistory = answeredQuestions
            .sorted { $0.createdAt < $1.createdAt }
            .compactMap { question -> (String, String)? in
                guard let answer = question.answer else { return nil }
                return (question.question, answer)
            }

        guard !qaHistory.isEmpty else { return [] }

        let questions = try await claudeService.generateFollowUpQuestions(
            originalTranscript: originalTranscript,
            previousQA: qaHistory
        )

        // Determine next iteration number
        let nextIteration = (answeredQuestions.map { $0.iteration }.max() ?? 0) + 1

        return questions.map { ReflectQuestion(question: $0, iteration: nextIteration) }
    }

    // MARK: - Integrate Answers

    func integrateAnswers(
        originalTranscript: String,
        answeredQuestions: [ReflectQuestion]
    ) async throws -> String {

        // Build Q&A history sorted by creation date
        let qaHistory = answeredQuestions
            .sorted { $0.createdAt < $1.createdAt }
            .compactMap { question -> (String, String)? in
                guard let answer = question.answer else { return nil }
                return (question.question, answer)
            }

        guard !qaHistory.isEmpty else {
            return originalTranscript
        }

        return try await claudeService.integrateContentWithAnswers(
            originalTranscript: originalTranscript,
            qaHistory: qaHistory
        )
    }
}
