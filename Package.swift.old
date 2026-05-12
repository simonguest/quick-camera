// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Quick Camera",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "Quick Camera",
            targets: ["Quick Camera"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "Quick Camera",
            path: "Quick Camera",
            sources: [
                "QCAppDelegate.swift",
                "QCSettingsManager.swift",
                "QCUsbWatcher.swift",
            ]
        )
    ]
)
