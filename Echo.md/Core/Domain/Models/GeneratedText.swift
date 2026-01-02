import Foundation
import SwiftData

@Model
final class GeneratedText {
    var id: UUID
    var createdAt: Date
    var content: String
    var style: TextStyle
    var isExported: Bool

    @Relationship(inverse: \Recording.generatedTexts)
    var recording: Recording?

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        content: String = "",
        style: TextStyle = .note,
        isExported: Bool = false
    ) {
        self.id = id
        self.createdAt = createdAt
        self.content = content
        self.style = style
        self.isExported = isExported
    }
}

enum TextStyle: String, Codable, CaseIterable {
    case note = "Notiz"
    case summary = "Zusammenfassung"
    case article = "Artikel"
    case bulletPoints = "Stichpunkte"
}
