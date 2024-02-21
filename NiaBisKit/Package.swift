// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "NiaBisKit",
  products: [
    .library(
      name: "NiaBisKit",
      targets: ["NiaBisKit"]
    ),
  ],
  targets: [
    .target(
      name: "NiaBisKit"
    ),
    .testTarget(
      name: "NiaBisKitTests",
      dependencies: ["NiaBisKit"]
    ),
  ]
)
