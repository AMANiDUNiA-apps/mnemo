// MnemoApp — Globaler App-State (Projektplan v3, F01 App-Seite + @Observable)
// HINWEIS: Kompiliert nur mit Apple-SDK (SwiftData/SwiftUI). Auf Linux wird dieses
// Target vom Build ausgenommen — Typprüfung passiert in Xcode auf dem Mac.

#if canImport(SwiftData)
import Foundation
import SwiftData
import MnemoShared

// MARK: - SwiftData @Model (NUR App-Prozess — nicht Sendable, nie über Prozessgrenzen!)

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

@Model
public final class MemoryDocument {
    public var id: UUID
    public var filename: String
    public var mimeType: String
    public var ingestDate: Date
    public var chunkCount: Int
    public var agentID: UUID?

    public init(id: UUID = UUID(), filename: String, mimeType: String,
                ingestDate: Date = .now, chunkCount: Int = 0, agentID: UUID? = nil) {
        self.id = id
        self.filename = filename
        self.mimeType = mimeType
        self.ingestDate = ingestDate
        self.chunkCount = chunkCount
        self.agentID = agentID
    }
}

// MARK: - Globaler State (@Observable ersetzt @ObservableObject, Plan Tech-Stack)

@Observable
public final class AppState {
    public var serverRunning: Bool = false
    public var serverPort: Int = 8080
    public var selectedAgentID: UUID?
    public var lastError: String?

    public init() {}
}
#endif
