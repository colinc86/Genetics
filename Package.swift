// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Genetics",
    products: [
        .library(
            name: "Genetics",
            targets: ["Genetics"]),
        .executable(
            name: "GeneticsExample",
            targets: ["GeneticsExample"]),
    ],
    targets: [
        .target(
            name: "Genetics",
            dependencies: []),
        .testTarget(
            name: "GeneticsTests",
            dependencies: ["Genetics"]),
        .target(
            name: "GeneticsExample",
            dependencies: ["Genetics"]),
    ]
)
