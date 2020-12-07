// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Python-aux",
    products: [
        .library(name: "ImageMagick", targets: ["magick"])
    ],
    dependencies: [
    ],
    targets: [
        .binaryTarget(
            name: "magick",
            url: "https://github.com/holzschu/Python-aux/releases/download/1.0/magick.xcframework.zip",
            checksum: "35d8c6e7ac0cdfb0ed43be528fd065b003c8491453d6da0169f87569d83bc822"
        )
    ]
)

