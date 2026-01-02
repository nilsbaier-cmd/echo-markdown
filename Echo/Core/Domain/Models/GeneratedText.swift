import Foundation
import SwiftData

@Model
final class GeneratedText {
    @Attribute(.unique) var id: UUID
    var content: String
    var styleRawValue: String
    var timestamp: Date
    var recording: Recording?

    var style: TextStyle {
        get { TextStyle(rawValue: styleRawValue) ?? .obsidian }
        set { styleRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        content: String,
        style: TextStyle,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.content = content
        self.styleRawValue = style.rawValue
        self.timestamp = timestamp
    }
}

enum TextStyle: String, Codable, CaseIterable {
    case formal
    case informal
    case obsidian

    var displayName: String {
        switch self {
        case .formal: return "Formell"
        case .informal: return "Informell"
        case .obsidian: return "Obsidian-Notiz"
        }
    }
}
