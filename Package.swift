// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NewsNetworkManager",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "NewsNetworkManager",
            targets: ["NewsNetworkManager"]),
    ],
    targets: [
        .target(
            name: "NewsNetworkManager"),
        .testTarget(
            name: "NewsNetworkManagerTests",
            dependencies: ["NewsNetworkManager"]),
    ]
)
