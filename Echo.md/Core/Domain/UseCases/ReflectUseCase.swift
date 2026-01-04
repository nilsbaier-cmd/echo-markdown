import Foundation

final class ReflectUseCase: ReflectUseCaseProtocol {
    private let claudeService: ClaudeServiceProtocol

    init(claudeService: ClaudeServiceProtocol) {
        self.claudeService = claudeService
    }

    func generateQuestions(for transcript: String) async throws -> [ReflectQuestion] {
        let questions = try await claudeService.generateReflectQuestions(transcript: transcript)
        return questions.map { ReflectQuestion(question: $0) }
    }
}
