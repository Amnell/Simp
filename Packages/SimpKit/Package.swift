// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SimpKit",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "SimpKit",
            targets: ["SimpKit"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "SimpKitBin",
            dependencies: ["SimpKit"],
            swiftSettings: [
                .unsafeFlags([
                    "-parse-as-library",
                    "-Xfrontend", "-disable-availability-checking",
                    "-Xfrontend", "-enable-experimental-concurrency",
                ])
            ]),
        .target(
            name: "SimpKit",
            dependencies: [],
            resources: [.process("Resources")])
    ]
)
