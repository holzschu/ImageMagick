// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "ImageMagick",
    products: [
        .library(name: "ImageMagick", targets: ["magick"])
    ],
    dependencies: [
    ],
    targets: [
        .binaryTarget(
            name: "magick",
            url: "https://github.com/holzschu/ImageMagick/releases/download/1.0/magick.xcframework.zip",
            checksum: "a50256d6f016d3bf2b564022fa44a105072c9858d4fdeec02b930471cb22fb63"
        )
    ]
)

