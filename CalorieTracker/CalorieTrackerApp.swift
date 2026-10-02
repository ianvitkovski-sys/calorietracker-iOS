import SwiftUI
import SwiftData

@main
struct CalorieTrackerApp: App {
    @StateObject private var container = AppContainer.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(container)
                .modelContainer(container.modelContainer)
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .inactive {
                        try? container.mainModelContext.save()
                    }
                }
        }
    }
}
