import Foundation

struct ShadowReaderQuestion: Identifiable {
    let id: UUID
    let question: String
    var answer: String?
    var isAnswered: Bool { answer != nil && !answer!.isEmpty }

    init(id: UUID = UUID(), question: String, answer: String? = nil) {
        self.id = id
        self.question = question
        self.answer = answer
    }
}
