// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "BSGToolbarView",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "BSGToolbarView",
            targets: ["BSGToolbarView"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "BSGToolbarView",
            dependencies: [],
            path: "Sources",
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "BSGToolbarViewTests",
            dependencies: ["BSGToolbarView"],
            path: "Tests",
            exclude: ["Info.plist"]
        ),
    ]
)
