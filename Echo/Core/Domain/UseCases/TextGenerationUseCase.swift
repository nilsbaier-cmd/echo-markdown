import Foundation

final class TextGenerationUseCase: TextGenerationUseCaseProtocol {
    private let claudeService: ClaudeServiceProtocol

    init(claudeService: ClaudeServiceProtocol) {
        self.claudeService = claudeService
    }

    func generateText(transcript: String, style: TextStyle) async throws -> String {
        try await claudeService.generateText(transcript: transcript, style: style.rawValue)
    }
}
