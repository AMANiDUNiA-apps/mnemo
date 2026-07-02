// MnemoApp — MemoryDocument (Projektplan v3, F01)
// Aufgeteilt nach swiftui-pro-Regel: ein Typ pro Datei.

#if canImport(SwiftData)
import Foundation
import SwiftData
import MnemoShared

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
#endif
