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
      name: "NiaBisUI",
      targets: ["NiaBisUI"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/supabase-community/supabase-swift", from: "2.1.3"),
    .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-case-paths", from: "1.2.4"),
    .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.10.0"),
    .package(url: "https://github.com/AsyncSwift/AsyncLocationKit", from: "1.6.4"),
    .package(url: "https://github.com/apple/swift-format", from: "509.0.0"),
  ],
  targets: [
    .target(
      name: "NiaBisData",
      dependencies: [
        .product(name: "Tagged", package: "swift-tagged"),
      ]
    ),
    .target(
      name: "NiaBisUI",
      dependencies: [
        .target(name: "NiaBisData"),
        .product(name: "Supabase", package: "supabase-swift"),
        .product(name: "Auth", package: "supabase-swift"),
        .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
        .product(name: "CasePaths", package: "swift-case-paths"),
        .product(name: "Tagged", package: "swift-tagged"),
        .product(name: "AsyncLocationKit", package: "AsyncLocationKit"),
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
