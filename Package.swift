// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "STAdKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "STAdCore",
            targets: ["STAdCore"]
        ),
        .library(
            name: "STAdConnectors",
            targets: ["STAdConnectors"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/googleads/swift-package-manager-google-mobile-ads",
            .upToNextMajor(from: "11.0.0")
        ),
        .package(
            url: "https://github.com/facebook/FBAudienceNetwork",
            .upToNextMajor(from: "6.21.0")
        )
    ],
    targets: [
        .target(
            name: "STAdCore",
            path: "Sources/STAdCore",
            publicHeadersPath: "."
        ),
        .target(
            name: "STAdConnectors",
            dependencies: [
                "STAdCore",
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads"),
                .product(name: "FBAudienceNetwork", package: "FBAudienceNetwork")
            ],
            path: "Sources/STAdConnectors"
        )
    ]
)
