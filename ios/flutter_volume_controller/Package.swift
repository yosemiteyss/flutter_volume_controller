// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flutter_volume_controller",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        .library(
            name: "flutter-volume-controller",
            targets: ["flutter_volume_controller"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "flutter_volume_controller"
        )
    ]
)

