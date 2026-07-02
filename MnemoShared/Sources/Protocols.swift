// MnemoShared — Abstrakte Protokolle (Projektplan v3, F02)
// Foundation Models hat KEIN universelles LanguageModel-Protokoll →
// eigenes Adapter-Pattern: LLMClient verbirgt lokales Apple-FM, Claude, Gemini.

import Foundation

// MARK: - Dokumente & Embeddings

public protocol DocumentParser: Sendable {
    func parse(_ url: URL) async throws -> [ContentBlock]
}

public protocol EmbeddingProvider: Sendable {
    func embed(_ texts: [String]) async throws -> [[Float]]
}

// MARK: - Stores (Actors: mutable State, prozess-lokal im Vapor-Server)

public protocol VectorStore: Actor {
    func insert(id: String, vector: [Float]) async throws
    func search(query: [Float], topK: Int) async throws -> [SearchResult]
}

public protocol KnowledgeGraph: Actor {
    func upsert(entity: Entity) async throws
    func upsert(relation: Relation) async throws
    func entity(id: String) async throws -> Entity?
    func remove(entityID: String) async throws
    func neighbors(of entityID: String, depth: Int) async throws -> [Entity]
}

// MARK: - Agenten & Tools

public struct PlanStep: Codable, Sendable, Identifiable {
    public var id: UUID
    public var title: String
    public var instruction: String
    public init(id: UUID = UUID(), title: String, instruction: String) {
        self.id = id
        self.title = title
        self.instruction = instruction
    }
}

public struct StepResult: Codable, Sendable {
    public var stepID: UUID
    public var output: String
    public var tokenCount: Int
    public init(stepID: UUID, output: String, tokenCount: Int = 0) {
        self.stepID = stepID
        self.output = output
        self.tokenCount = tokenCount
    }
}

public protocol AgentProtocol: Actor {
    func execute(_ step: PlanStep) async throws -> StepResult
    var state: AgentStatus { get async }
}

public protocol ToolProtocol: Sendable {
    var name: String { get }
    var description: String { get }
    var inputSchema: String { get }
    func call(input: String) async throws -> String
}

// MARK: - LLM-Adapter (F02: eigenes Protokoll statt Foundation-Models-Direktbindung)

public struct LLMMessage: Codable, Sendable {
    public enum Role: String, Codable, Sendable { case system, user, assistant, tool }
    public var role: Role
    public var content: String
    public init(role: Role, content: String) {
        self.role = role
        self.content = content
    }
}

public struct ToolDefinition: Codable, Sendable {
    public var name: String
    public var description: String
    public var inputSchema: String
    public init(name: String, description: String, inputSchema: String) {
        self.name = name
        self.description = description
        self.inputSchema = inputSchema
    }
}

public struct LLMResponse: Codable, Sendable {
    public var content: String
    public var toolCalls: [ToolCall]
    public var tokenCount: Int
    public init(content: String, toolCalls: [ToolCall] = [], tokenCount: Int = 0) {
        self.content = content
        self.toolCalls = toolCalls
        self.tokenCount = tokenCount
    }
}

public struct ToolCall: Codable, Sendable, Identifiable {
    public var id: String
    public var name: String
    public var arguments: String
    public init(id: String, name: String, arguments: String) {
        self.id = id
        self.name = name
        self.arguments = arguments
    }
}

public enum LLMEvent: Sendable {
    case textDelta(String)
    case toolCall(ToolCall)
    case done(LLMResponse)
}

public protocol LLMClient: Sendable {
    func complete(messages: [LLMMessage], tools: [ToolDefinition]) async throws -> LLMResponse
    func stream(messages: [LLMMessage], tools: [ToolDefinition]) -> AsyncThrowingStream<LLMEvent, Error>
}
// Konkrete Implementierungen (Phase 4): LocalFoundationModelClient (App-Target,
// FoundationModels-Framework), ClaudeClient, GeminiClient (MnemoServer, AsyncHTTPClient).
