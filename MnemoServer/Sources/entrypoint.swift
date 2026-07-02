// MnemoServer — Vapor 4, embedded Local Server (Projektplan v3, Architektur: Port 8080)
// Läuft als eigener Prozess; die macOS-App startet dieses Binary aus dem Bundle
// (LaunchManager) und spricht REST + WebSocket auf localhost.

import Vapor

@main
enum Entrypoint {
    static func main() async throws {
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)
        let app = try await Application.make(env)
        do {
            try configure(app)
            try await app.execute()
        } catch {
            app.logger.report(error: error)
            try? await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }
}
