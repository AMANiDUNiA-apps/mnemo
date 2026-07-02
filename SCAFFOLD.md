# macOS-App Scaffold — Stand & Wegweiser

> Erstellt 2026-07-02 (Branch `macos-app-scaffold`) nach `Mnemo_Projektplan_v3.md`.
> Kanonische Spec bleibt `brain-memory-manager-spec.md` — bei Widerspruch gewinnt die Spec.

## Was hier liegt (Phase-1-Skeleton, F01–F03 + Anfänge F08/A12)

| Pfad | Inhalt | Kompiliert auf |
|------|--------|----------------|
| `Package.swift` | 4 SPM-Targets + Vapor/GRDB/AsyncHTTPClient (F03) | Mac + Linux |
| `MnemoShared/` | Sendable-Structs (F01) + alle Protokolle inkl. `LLMClient`-Adapter (F02) | Mac + Linux |
| `MnemoServer/` | Vapor-Entrypoint, localhost:8080, `/health` + API-Platzhalter | Mac + Linux |
| `MnemoApp/` | SwiftData-@Models, `@Observable` AppState, SwiftUI-Shell, LaunchManager-Skeleton | **nur Mac** (`#if canImport`) |
| `MnemoXPC/` | ShellRequest/Response + Allowlist-Policy (A12-Skeleton) | Mac + Linux (XPC-Bindung folgt) |
| `Tests/` | Erste Roundtrip-Tests | Mac + Linux |
| `docker-compose.yml` | MinerU-Sidecar (F07) | überall |

## Nächste Schritte auf dem Mac (Xcode 27)
1. `swift build` — MnemoShared + MnemoServer müssen grün sein
2. Xcode-App-Target um `MnemoApp/Sources` bauen; **FoundationModels + CoreML im
   App-Target verlinken** (NICHT in Package.swift — Plan F03 Stolpersteine)
3. `swift build -c release --product MnemoServer` → Binary nach `MnemoApp/Resources/`
4. Platform-Version: `.macOS(.v15)` → auf `.v27` heben, sobald Toolchain sie kennt
5. Weiter mit F04 (GRDB-Schema) + F09 laut Plan — kritischer Pfad:
   `F01 → F09 → F02 → F06 → R04 → … → Q03`

## Ehrliche Einschränkungen dieses Scaffolds
- Auf dem ARM-Server (kein Swift-Toolchain) **ungeprüft** — geschrieben streng nach Plan,
  aber der erste `swift build` auf dem Mac wird Kleinigkeiten finden. Das ist eingeplant:
  „einfach mal machen und daraus lernen" (Jay, 2026-07-02).
- `MnemoApp` ist als SPM-Target angelegt, damit Views typgeprüft werden können; das
  finale App-Target entsteht in Xcode (F03).
- Swift Testing (statt XCTest) umstellen, sobald Xcode 27 final.
