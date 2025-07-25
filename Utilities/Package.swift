// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Utilities",
    platforms: [
        .iOS("18.4")
    ],
    products: [
        .library(
            name: "PieChart",
            targets: ["PieChart"]
        )
    ],
    targets: [
        .target(
            name: "PieChart",
            path: "Sources/PieChart"
        )
    ]
)