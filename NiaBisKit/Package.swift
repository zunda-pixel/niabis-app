// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "NiaBisKit",
  platforms: [
    .iOS(.v17),
    .macOS(.v14),
  ],
  products: [
    .library(
      name: "NiaBisData",
      targets: ["NiaBisData"]
    ),
    .library(
      name: "NiaBisUI",
      targets: ["NiaBisUI"]
    ),
  ],
  targets: [
    .target(
      name: "NiaBisData"
    ),
    .target(
      name: "NiaBisUI",
      dependencies: [
        .target(name: "NiaBisData"),
      ]
    ),
    .testTarget(
      name: "NiaBisDataTests",
      dependencies: [
        .target(name: "NiaBisData"),
      ]
    ),
  ]
)
