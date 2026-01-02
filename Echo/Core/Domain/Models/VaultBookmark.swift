import Foundation
import SwiftData

@Model
final class VaultBookmark {
    @Attribute(.unique) var id: UUID
    var name: String
    var bookmarkData: Data
    var isDefault: Bool

    init(
        id: UUID = UUID(),
        name: String,
        bookmarkData: Data,
        isDefault: Bool = false
    ) {
        self.id = id
        self.name = name
        self.bookmarkData = bookmarkData
        self.isDefault = isDefault
    }
}
