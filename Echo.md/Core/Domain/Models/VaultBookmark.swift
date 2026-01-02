import Foundation
import SwiftData

@Model
final class VaultBookmark {
    var id: UUID
    var name: String
    var bookmarkData: Data
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        bookmarkData: Data,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.bookmarkData = bookmarkData
        self.createdAt = createdAt
    }
}
