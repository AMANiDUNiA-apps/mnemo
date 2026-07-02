// swift-tools-version:6.0
// mnemo macOS App — SPM Manifest (Projektplan v3, F03: 4 Targets)
//
// Baubar auf macOS (Xcode 27). MnemoServer + MnemoShared bauen auch auf Linux
// (Vapor/GRDB sind cross-platform); MnemoApp/MnemoXPC brauchen Apple-SDKs.
// FoundationModels + CoreML sind OS-Frameworks: im Xcode-App-Target verlinken,
// NICHT hier (siehe Plan F03, Stolpersteine).

import PackageDescription

let package = Package(
    name: "mnemo",
    platforms: [
        .macOS(.v15) // Plan-Ziel: macOS 27 — .v27 eintragen, sobald die SPM-Tools-Version es kennt
    ],
    products: [
        .library(name: "MnemoShared", targets: ["MnemoShared"]),
        .executable(name: "MnemoServer", targets: ["MnemoServer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.99.0"),
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.29.0"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.21.0"),
    ],
    targets: [
        // 1. Shared: Codable-Typen + Protokolle — kein OS-spezifischer Code
        .target(
            name: "MnemoShared",
            dependencies: [],
            path: "MnemoShared/Sources"
        ),

        // 2. Vapor-Server: läuft als eigener Prozess (embedded in der .app)
        .executableTarget(
            name: "MnemoServer",
            dependencies: [
                "MnemoShared",
                .product(name: "Vapor", package: "vapor"),
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
            ],
            path: "MnemoServer/Sources"
        ),

        // 3. macOS App: SwiftUI + SwiftData (final als Xcode-App-Target;
        //    hier als Library-Target, damit `swift build` die Views typprüfen kann)
        .target(
            name: "MnemoApp",
            dependencies: ["MnemoShared"],
            path: "MnemoApp/Sources"
        ),

        // 4. XPC-Helper: minimale Dependencies (Sandbox-Shell-Brücke)
        .target(
            name: "MnemoXPC",
            dependencies: ["MnemoShared"],
            path: "MnemoXPC/Sources"
        ),

        .testTarget(
            name: "MnemoSharedTests",
            dependencies: ["MnemoShared"],
            path: "Tests/MnemoSharedTests"
        ),
    ]
)
