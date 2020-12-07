// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Python-aux",
    products: [
        .library(name: "magick"])
    ],
    dependencies: [
    ],
    targets: [
        .binaryTarget(
            name: "magick",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/magick.xcframework.zip",
            checksum: "df9d3a7c089c4f31fb2b2b2f90e4dd36e398e363355076487c885347d3aae81a"
        )
    ]
)

