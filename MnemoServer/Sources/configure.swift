// MnemoServer — Konfiguration (bindet bewusst NUR an localhost)

import Vapor

public func configure(_ app: Application) throws {
    app.http.server.configuration.hostname = "127.0.0.1"
    app.http.server.configuration.port = Environment.get("MNEMO_PORT").flatMap(Int.init) ?? 8080

    try routes(app)
}
