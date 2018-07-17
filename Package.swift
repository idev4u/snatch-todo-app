// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "snatch-todos",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.4"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on PostgreSQL.
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0-rc.2.3"),
        // Add Leaf template engine
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0-rc.2")
    ],
    targets: [
        .target(name: "App",
                dependencies: ["FluentPostgreSQL", "Vapor", "Leaf"] //                exclude: ["Config", "Public", "Resources"]
        ),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

