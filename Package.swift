// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Asatsuyu",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .executable(
            name: "Asatsuyu",
            targets: ["Asatsuyu"]
        ),
    ],
    dependencies: [
        // DynamicNotchKit removed due to compatibility issues
        // Will implement custom notch overlay solution
    ],
    targets: [
        .executableTarget(
            name: "Asatsuyu",
            dependencies: [
                // No external dependencies for now
            ],
            path: "Sources/Asatsuyu",
            resources: [
                .process("Models/AsatsuyuDataModel.xcdatamodeld"),
            ]
        ),
        // .testTarget(
        //     name: "AsatsuyuTests",
        //     dependencies: ["Asatsuyu"],
        //     path: "Tests/AsatsuyuTests"
        // ),
    ]
)
