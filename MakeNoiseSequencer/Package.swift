// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MakeNoiseSequencer",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "MakeNoiseSequencer",
            targets: ["MakeNoiseSequencer"]
        ),
    ],
    targets: [
        .target(
            name: "MakeNoiseSequencer",
            path: ".",
            exclude: ["Package.swift"],
            sources: [
                "App",
                "DesignSystem", 
                "Models",
                "Store",
                "Features"
            ]
        ),
    ]
)
