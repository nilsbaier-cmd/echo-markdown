import Foundation
import SwiftData

// MARK: - Reflect Session Model

@Model
final class ReflectSession {
    var id: UUID
    var originalTranscript: String
    var enrichedTranscript: String?
    var isCompleted: Bool
    var createdAt: Date
    var completedAt: Date?

    @Relationship(deleteRule: .cascade)
    var questions: [ReflectQuestion]?

    @Relationship(inverse: \Recording.reflectSession)
    var recording: Recording?

    // MARK: - Computed Properties

    var allQuestions: [ReflectQuestion] {
        questions ?? []
    }

    var answeredQuestions: [ReflectQuestion] {
        allQuestions.filter { $0.isAnswered }
    }

    var currentIteration: Int {
        allQuestions.map { $0.iteration }.max() ?? 0
    }

    var hasAnswers: Bool {
        !answeredQuestions.isEmpty
    }

    // MARK: - Init

    init(
        id: UUID = UUID(),
        originalTranscript: String,
        enrichedTranscript: String? = nil,
        isCompleted: Bool = false,
        createdAt: Date = Date(),
        completedAt: Date? = nil
    ) {
        self.id = id
        self.originalTranscript = originalTranscript
        self.enrichedTranscript = enrichedTranscript
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.questions = []
    }

    // MARK: - Methods

    func addQuestions(_ newQuestions: [ReflectQuestion]) {
        for question in newQuestions {
            question.session = self
        }
        if questions == nil {
            questions = []
        }
        questions?.append(contentsOf: newQuestions)
    }

    func answerQuestion(id: UUID, answer: String, source: AnswerSource) {
        if let question = questions?.first(where: { $0.id == id }) {
            question.answer = answer
            question.answerSource = source
        }
    }
}
