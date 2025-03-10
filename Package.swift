// swift-tools-version: 6.0

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
			path: "BSGToolbarView/BSGToolbarView/Sources"
        ),
        .testTarget(
            name: "BSGToolbarViewTests",
            dependencies: ["BSGToolbarView"],
			path: "BSGToolbarView/BSGToolbarViewTests/Sources"
        ),
    ]
)
