import Foundation

final class ShadowReaderUseCase: ShadowReaderUseCaseProtocol {
    private let claudeService: ClaudeServiceProtocol

    init(claudeService: ClaudeServiceProtocol) {
        self.claudeService = claudeService
    }

    func generateQuestions(for transcript: String) async throws -> [ShadowReaderQuestion] {
        let questions = try await claudeService.generateShadowReaderQuestions(transcript: transcript)
        return questions.map { ShadowReaderQuestion(question: $0) }
    }
}
