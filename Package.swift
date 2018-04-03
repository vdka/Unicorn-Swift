// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Unicorn",
    products: [
        .library(name: "Unicorn", targets: ["Unicorn"]),
        .library(name: "UnicornX86", targets: ["UnicornX86"]),
        .library(name: "UnicornARM64", targets: ["UnicornARM64"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vdka/CUnicorn.git", .branch("master")),
    ],
    targets: [
        .target(name: "Unicorn", dependencies: []),
        .target(name: "UnicornX86", dependencies: ["Unicorn"]),
        .target(name: "UnicornARM64", dependencies: ["Unicorn"]),
    ]
)
