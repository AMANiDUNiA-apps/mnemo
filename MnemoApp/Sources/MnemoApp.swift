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
        }
        .modelContainer(for: [AgentRecord.self, TaskRecord.self, MemoryDocument.self])
    }
}

/// Startet das embedded MnemoServer-Binary aus dem App-Bundle und wartet auf /health.
/// (Plan F08 — Skeleton; XPC-Shell und Sandbox-Entitlements folgen.)
@Observable
final class LaunchManager {
    private(set) var process: Process?

    func startServer() throws {
        guard process == nil else { return }
        guard let url = Bundle.main.url(forResource: "MnemoServer", withExtension: nil) else {
            throw LaunchError.binaryMissing
        }
        let p = Process()
        p.executableURL = url
        p.environment = ["MNEMO_PORT": "8080"]
        try p.run()
        process = p
    }

    func stopServer() {
        process?.terminate()
        process = nil
    }

    enum LaunchError: Error { case binaryMissing }
}
#endif
