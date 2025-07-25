// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "AnimationKit",
    platforms: [
        .iOS("18.4")
    ],
    products: [
        .library(
            name: "AnimationKit",
            targets: ["AnimationKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/airbnb/lottie-ios", exact: "4.5.2")
    ],
    targets: [
        .target(
            name: "AnimationKit",
            dependencies: [
                .product(name: "Lottie", package: "lottie-ios")
            ],
            path: "Sources"
        )
    ]
)
