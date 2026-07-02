// MnemoApp — TaskRecord (Projektplan v3, F01)
// Aufgeteilt nach swiftui-pro-Regel: ein Typ pro Datei.

#if canImport(SwiftData)
import Foundation
import SwiftData
import MnemoShared

@Model
public final class TaskRecord {
    public var id: UUID
    public var agentID: UUID?
    public var title: String
    public var taskDescription: String
    public var statusRaw: String
    public var resultText: String?
    public var tokenCount: Int
    public var createdAt: Date
    public var completedAt: Date?
    public var parentTaskID: UUID?

    public init(id: UUID = UUID(), agentID: UUID? = nil, title: String, taskDescription: String,
                statusRaw: String = AgentStatus.idle.rawValue, tokenCount: Int = 0,
                createdAt: Date = .now, parentTaskID: UUID? = nil) {
        self.id = id
        self.agentID = agentID
        self.title = title
        self.taskDescription = taskDescription
        self.statusRaw = statusRaw
        self.resultText = nil
        self.tokenCount = tokenCount
        self.createdAt = createdAt
        self.completedAt = nil
        self.parentTaskID = parentTaskID
    }
}
#endif
