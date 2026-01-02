import Foundation
import Combine

@MainActor
final class ShadowReaderViewModel: ObservableObject {
    @Published var questions: [ShadowReaderQuestion] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let transcriptionUseCase: TranscriptionUseCaseProtocol
    private let shadowReaderUseCase: ShadowReaderUseCaseProtocol

    init(
        transcriptionUseCase: TranscriptionUseCaseProtocol,
        shadowReaderUseCase: ShadowReaderUseCaseProtocol
    ) {
        self.transcriptionUseCase = transcriptionUseCase
        self.shadowReaderUseCase = shadowReaderUseCase
    }

    func generateQuestions(for transcript: String) async {
        isLoading = true
        do {
            questions = try await shadowReaderUseCase.generateQuestions(for: transcript)
        } catch {
            errorMessage = "Fehler beim Generieren der Fragen: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func updateAnswer(for questionId: UUID, answer: String) {
        if let index = questions.firstIndex(where: { $0.id == questionId }) {
            questions[index].answer = answer
        }
    }
}
