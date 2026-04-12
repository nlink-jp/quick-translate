// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "QuickTranslate",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts", from: "2.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "QuickTranslate",
            dependencies: ["KeyboardShortcuts"],
            path: "Sources/QuickTranslate"
        ),
        .testTarget(
            name: "QuickTranslateTests",
            dependencies: ["QuickTranslate"],
            path: "Tests/QuickTranslateTests"
        ),
    ]
)
