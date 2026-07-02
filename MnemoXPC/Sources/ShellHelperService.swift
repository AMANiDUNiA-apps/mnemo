// MnemoXPC — Sandbox-Shell-Brücke (Projektplan v3, A12 — Skeleton)
// Isolierter XPC-Helfer: Die App/der Server rufen NIE direkt Shell auf;
// dieser Service kapselt Kommandos mit Allowlist. Sicherheit per Architektur.

import Foundation
import MnemoShared

/// Protokoll der XPC-Schnittstelle (Objective-C-kompatibel für NSXPCConnection auf dem Mac).
public struct ShellRequest: Codable, Sendable {
    public var command: String
    public var arguments: [String]
    public var workingDirectory: String?
    public init(command: String, arguments: [String] = [], workingDirectory: String? = nil) {
        self.command = command
        self.arguments = arguments
        self.workingDirectory = workingDirectory
    }
}

public struct ShellResponse: Codable, Sendable {
    public var exitCode: Int32
    public var stdout: String
    public var stderr: String
    public init(exitCode: Int32, stdout: String, stderr: String) {
        self.exitCode = exitCode
        self.stdout = stdout
        self.stderr = stderr
    }
}

/// Allowlist — nur diese Binaries darf der Helper ausführen (Phase 4 erweitert das konfigurierbar).
public enum ShellPolicy {
    public static let allowedCommands: Set<String> = ["git", "ls", "cat", "grep", "python3"]

    public static func isAllowed(_ request: ShellRequest) -> Bool {
        allowedCommands.contains((request.command as NSString).lastPathComponent)
    }
}
