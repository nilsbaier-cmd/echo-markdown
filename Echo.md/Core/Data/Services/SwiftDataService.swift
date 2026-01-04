import Foundation
import SwiftData

@MainActor
final class SwiftDataService {
    static let shared = SwiftDataService()

    let modelContainer: ModelContainer

    private init() {
        do {
            let schema = Schema([
                Recording.self,
                GeneratedText.self,
                VaultBookmark.self,
                ReflectSession.self,
                ReflectQuestion.self
            ])

            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )

            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var modelContext: ModelContext {
        modelContainer.mainContext
    }
}
