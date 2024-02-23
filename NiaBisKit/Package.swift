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
  dependencies: [
    .package(url: "https://github.com/supabase-community/supabase-swift", from: "2.1.3"),
  ],
  targets: [
    .target(
      name: "NiaBisData"
    ),
    .target(
      name: "NiaBisUI",
      dependencies: [
        .target(name: "NiaBisData"),
        .product(name: "Supabase", package: "supabase-swift"),
        .product(name: "Auth", package: "supabase-swift"),
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
