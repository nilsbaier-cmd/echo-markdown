import SwiftUI

@main
struct EchoApp: App {
    let container: DependencyContainer = DefaultDependencyContainer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.container, container)
        }
    }
}
