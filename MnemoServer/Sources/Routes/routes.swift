// MnemoServer — Routen (Phase 1 Skeleton; RAG/Agents folgen in Phase 3/4)

import Vapor
import MnemoShared

func routes(_ app: Application) throws {
    // Health — die App pollt das beim Start (LaunchManager wartet auf 200)
    app.get("health") { _ in
        HealthStatus(status: "ok", version: "0.1.0-scaffold")
    }

    // Platzhalter der API-Oberfläche (Plan: F05, R12, A10)
    let api = app.grouped("api", "v1")

    api.get("agents") { _ -> [AgentInfo] in
        [] // Phase 4: Agent-Registry
    }

    api.post("rag", "query") { req -> RAGQueryResponse in
        let query = try req.content.decode(RAGQueryRequest.self)
        // Phase 3: BM25 → Vektor → Fusion. Skeleton antwortet leer, aber typrichtig.
        return RAGQueryResponse(query: query.text, results: [])
    }
}

struct HealthStatus: Content {
    let status: String
    let version: String
}

struct AgentInfo: Content {
    let id: String
    let name: String
    let status: String
}

struct RAGQueryRequest: Content {
    let text: String
    let topK: Int?
}

struct RAGQueryResponse: Content {
    let query: String
    let results: [String]
}
