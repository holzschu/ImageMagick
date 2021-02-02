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
            checksum: "15366ec4c270a21008cffcfefed6862619dcee193112fa634213ae5ce4437aba"
        )
    ]
)

