// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "QCamera",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "QCamera",
            targets: ["QCamera"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "QCamera",
            path: "QCamera",
            sources: [
                "QCAppDelegate.swift",
                "QCSettingsManager.swift",
                "QCUsbWatcher.swift"
            ]
        )
    ]
)