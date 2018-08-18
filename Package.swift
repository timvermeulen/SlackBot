// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "SlackBot",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),
        .package(url: "https://github.com/timvermeulen/Newtype.git", .branch("master"))
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "Fluent", "FluentSQLite", "Newtype"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
    ]
)
