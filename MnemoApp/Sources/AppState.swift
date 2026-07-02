// MnemoApp — Globaler App-State (@Observable, Projektplan v3)

#if canImport(SwiftData)
import Foundation

@MainActor
@Observable
public final class AppState {
    public var serverRunning: Bool = false
    public var serverPort: Int = 8080
    public var selectedAgentID: UUID?
    public var lastError: String?

    public init() {}
}
#endif
