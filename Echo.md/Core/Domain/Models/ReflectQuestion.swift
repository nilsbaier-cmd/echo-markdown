import Foundation
import SwiftData

// MARK: - Answer Source

enum AnswerSource: String, Codable {
    case audio
    case text
}

// MARK: - Reflect Question Model

@Model
final class ReflectQuestion {
    var id: UUID
    var question: String
    var iteration: Int
    var answer: String?
    var answerSource: AnswerSource?
    var createdAt: Date

    @Relationship(inverse: \ReflectSession.questions)
    var session: ReflectSession?

    var isAnswered: Bool {
        answer != nil && !answer!.isEmpty
    }

    init(
        id: UUID = UUID(),
        question: String,
        iteration: Int = 0,
        answer: String? = nil,
        answerSource: AnswerSource? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.question = question
        self.iteration = iteration
        self.answer = answer
        self.answerSource = answerSource
        self.createdAt = createdAt
    }
}
