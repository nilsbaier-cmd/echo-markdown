import SwiftUI
import SwiftData

@main
struct Echo_mdApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(container: DefaultDependencyContainer(
                modelContext: SwiftDataService.shared.modelContext
            ))
        }
        .modelContainer(SwiftDataService.shared.modelContainer)
    }
}
