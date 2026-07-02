// MnemoApp — Haupt-View (Phase 5 Skeleton: U01 Shell mit Sidebar)

#if canImport(SwiftUI) && canImport(SwiftData)
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Query(sort: \AgentRecord.name) private var agents: [AgentRecord]

    var body: some View {
        NavigationSplitView {
            List(agents, id: \.id) { agent in
                Label(agent.name, systemImage: "brain")
                    .badge(agent.status.rawValue)
            }
            .navigationTitle("mnemo")
        } detail: {
            VStack(spacing: 12) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 56))
                Text("mnemo — memory for AI agents")
                    .font(.title2)
                Text(appState.serverRunning
                     ? "Server läuft auf Port \(appState.serverPort)"
                     : "Server nicht gestartet")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
#endif
