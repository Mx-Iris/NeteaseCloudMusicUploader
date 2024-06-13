// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NeteaseCloudMusicService",
    platforms: [.macOS(.v11)],
    products: [
        .library(
            name: "NeteaseCloudMusicModel",
            targets: ["NeteaseCloudMusicModel"]
        ),
        .library(
            name: "NeteaseCloudMusicService",
            targets: ["NeteaseCloudMusicService"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/joshuawright11/papyrus",
            .upToNextMajor(from: "0.6.10")
        ),
        .package(
            url: "https://github.com/SwiftyLab/MetaCodable",
            branch: "main"
        ),
        .package(
            url: "https://github.com/ReactiveX/RxSwift",
            .upToNextMajor(from: "6.0.0")
        ),
        .package(
            url: "https://github.com/Mx-Iris/RxSwiftPlus",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "NeteaseCloudMusicModel",
            dependencies: [
                .product(name: "MetaCodable", package: "MetaCodable"),
                .product(name: "HelperCoders", package: "MetaCodable"),
            ]
        ),
        .target(
            name: "NeteaseCloudMusicService",
            dependencies: [
                "NeteaseCloudMusicModel",
                .product(name: "Papyrus", package: "papyrus"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "RxSwiftPlus", package: "RxSwiftPlus"),
                .product(name: "RxDefaultsPlus", package: "RxSwiftPlus"),
            ]
        ),
        .testTarget(
            name: "NeteaseCloudMusicServiceTests",
            dependencies: ["NeteaseCloudMusicService"]
        ),
    ]
)
