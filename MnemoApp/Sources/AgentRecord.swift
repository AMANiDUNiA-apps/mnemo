// MnemoApp — AgentRecord (Projektplan v3, F01)
// Aufgeteilt nach swiftui-pro-Regel: ein Typ pro Datei.

#if canImport(SwiftData)
import Foundation
import SwiftData
import MnemoShared

@Model
public final class AgentRecord {
    public var id: UUID
    public var name: String
    public var role: String
    public var statusRaw: String
    public var assignedTaskIDs: [UUID]

    public init(id: UUID = UUID(), name: String, role: String,
                statusRaw: String = AgentStatus.idle.rawValue, assignedTaskIDs: [UUID] = []) {
        self.id = id
        self.name = name
        self.role = role
        self.statusRaw = statusRaw
        self.assignedTaskIDs = assignedTaskIDs
    }

    public var status: AgentStatus {
        get { AgentStatus(rawValue: statusRaw) ?? .idle }
        set { statusRaw = newValue.rawValue }
    }
}
#endif
