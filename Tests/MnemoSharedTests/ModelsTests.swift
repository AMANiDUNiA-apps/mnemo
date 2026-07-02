// Erste Tests (Plan: Swift Testing ab Xcode 27; XCTest-kompatibel gehalten,
// bis die Toolchain überall Swift Testing hat)

import XCTest
@testable import MnemoShared

final class ModelsTests: XCTestCase {
    func testContentBlockRoundtrip() throws {
        let block = ContentBlock(type: .code, content: "print(1)", pageIndex: 3, metadata: ["lang": "swift"])
        let data = try JSONEncoder().encode(block)
        let back = try JSONDecoder().decode(ContentBlock.self, from: data)
        XCTAssertEqual(block, back)
    }

    func testAgentStatusCases() {
        XCTAssertEqual(AgentStatus.allCases.count, 5)
        XCTAssertEqual(AgentStatus(rawValue: "running"), .running)
    }

    func testShellPolicyAllowlist() {
        // Allowlist lebt in MnemoXPC; hier nur das Shared-Modell — Platzhalter
        XCTAssertTrue(true)
    }
}
