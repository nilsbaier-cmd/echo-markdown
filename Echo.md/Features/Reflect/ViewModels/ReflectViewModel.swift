import Foundation
import Combine

@MainActor
final class ReflectViewModel: ObservableObject {
    @Published var questions: [ReflectQuestion] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let transcriptionUseCase: TranscriptionUseCaseProtocol
    private let reflectUseCase: ReflectUseCaseProtocol

    init(
        transcriptionUseCase: TranscriptionUseCaseProtocol,
        reflectUseCase: ReflectUseCaseProtocol
    ) {
        self.transcriptionUseCase = transcriptionUseCase
        self.reflectUseCase = reflectUseCase
    }

    func generateQuestions(for transcript: String) async {
        isLoading = true
        do {
            questions = try await reflectUseCase.generateQuestions(for: transcript)
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
