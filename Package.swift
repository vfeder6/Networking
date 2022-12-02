// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Networking",
    platforms: [
        .iOS(.v14),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "Networking",
            targets: ["Networking"]
        )
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Networking",
            dependencies: []
        ),
        .testTarget(
            name: "NetworkingTests",
            dependencies: ["Networking"]
        )
    ]
)
