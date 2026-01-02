import Foundation

struct ShadowReaderQuestion: Identifiable, Codable {
    let id: UUID
    let question: String
    let context: String
    var answer: String?

    init(
        id: UUID = UUID(),
        question: String,
        context: String,
        answer: String? = nil
    ) {
        self.id = id
        self.question = question
        self.context = context
        self.answer = answer
    }
}
