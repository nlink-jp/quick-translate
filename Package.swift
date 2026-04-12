// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "QuickTranslate",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "QuickTranslate",
            path: "Sources/QuickTranslate"
        ),
        .testTarget(
            name: "QuickTranslateTests",
            dependencies: ["QuickTranslate"],
            path: "Tests/QuickTranslateTests"
        ),
    ]
)
