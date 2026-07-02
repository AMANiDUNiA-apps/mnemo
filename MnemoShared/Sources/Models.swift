// MnemoShared — Cross-Process-Datentypen (Projektplan v3, F01)
// Sendable-Structs für App ↔ Vapor via JSON/Codable.
// WICHTIG: SwiftData-@Model-Klassen leben NUR im App-Target (nicht Sendable, nicht hier).

import Foundation

// MARK: - Enums

public enum AgentStatus: String, Codable, Sendable, CaseIterable {
    case idle, running, waiting, error, done
}

public enum ContentBlockType: String, Codable, Sendable, CaseIterable {
    case text, table, image, equation, code, audio
}

// MARK: - Content

/// Ein geparster Inhaltsblock aus einem Dokument (PDF, Markdown, Audio-Transkript …).
public struct ContentBlock: Codable, Sendable, Identifiable, Hashable {
    public var id: UUID
    public var type: ContentBlockType
    public var content: String
    public var pageIndex: Int?
    public var confidence: Double?
    public var metadata: [String: String]

    public init(
        id: UUID = UUID(),
        type: ContentBlockType,
        content: String,
        pageIndex: Int? = nil,
        confidence: Double? = nil,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.type = type
        self.content = content
        self.pageIndex = pageIndex
        self.confidence = confidence
        self.metadata = metadata
    }
}

// MARK: - Knowledge Graph

public struct Entity: Codable, Sendable, Identifiable, Hashable {
    public var id: String
    public var name: String
    public var type: String
    public var description: String

    public init(id: String, name: String, type: String, description: String) {
        self.id = id
        self.name = name
        self.type = type
        self.description = description
    }
}

public struct Relation: Codable, Sendable, Identifiable, Hashable {
    public var id: String
    public var fromEntity: String
    public var toEntity: String
    public var label: String
    public var weight: Double

    public init(id: String, fromEntity: String, toEntity: String, label: String, weight: Double = 1.0) {
        self.id = id
        self.fromEntity = fromEntity
        self.toEntity = toEntity
        self.label = label
        self.weight = weight
    }
}

// MARK: - RAG

public struct RAGChunk: Codable, Sendable, Identifiable, Hashable {
    public var id: String
    public var docID: String
    public var text: String
    public var position: Int
    public var chunkIndex: Int

    public init(id: String, docID: String, text: String, position: Int, chunkIndex: Int) {
        self.id = id
        self.docID = docID
        self.text = text
        self.position = position
        self.chunkIndex = chunkIndex
    }
}

public struct SearchResult: Codable, Sendable, Identifiable {
    public var id: String
    public var chunk: RAGChunk
    public var score: Double

    public init(id: String, chunk: RAGChunk, score: Double) {
        self.id = id
        self.chunk = chunk
        self.score = score
    }
}
