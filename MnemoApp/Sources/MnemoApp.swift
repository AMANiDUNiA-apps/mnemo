// MnemoApp — @main Einstieg (Projektplan v3: ModelContainer + LaunchManager)

#if canImport(SwiftUI) && canImport(SwiftData)
import SwiftUI
import SwiftData

@main
struct MnemoApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                // Typo-Standard (Jay, 3.7.): Serifen global, Mono nur für IDs/Code
                .fontDesign(.serif)
        }
        .modelContainer(for: [AgentRecord.self, TaskRecord.self, MemoryDocument.self])
    }
}

#endif
