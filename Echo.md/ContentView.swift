import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    var body: some View {
        if hasCompletedOnboarding {
            HomeView(container: container)
        } else {
            OnboardingView(settingsRepository: container.settingsRepository)
        }
    }
}
