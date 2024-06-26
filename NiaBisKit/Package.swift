// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "NiaBisKit",
  defaultLocalization: "en",
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
    .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"),
    .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-case-paths", from: "1.3.0"),
    .package(url: "https://github.com/AsyncSwift/AsyncLocationKit", from: "1.6.4"),
    .package(url: "https://github.com/apple/swift-format", from: "509.0.0"),
    .package(url: "https://github.com/kean/Nuke", from: "12.4.0"),
    .package(url: "https://github.com/zunda-pixel/LicenseProvider", from: "1.1.2"),
    .package(url: "https://github.com/siteline/swiftui-introspect", from: "1.1.3"),
    .package(url: "https://github.com/apple/swift-http-types", from: "1.0.0"),
    .package(url: "https://github.com/danielsaidi/SystemNotification", from: "1.1.0"),
    .package(url: "https://github.com/zunda-pixel/selene", from: "1.2.3"),
  ],
  targets: [
    .target(
      name: "NiaBisData"
    ),
    .target(
      name: "NiaBisUI",
      dependencies: [
        .target(name: "NiaBisData"),
        .target(name: "NiaBisClient"),
        .product(name: "Algorithms", package: "swift-algorithms"),
        .product(name: "Supabase", package: "supabase-swift"),
        .product(name: "Auth", package: "supabase-swift"),
        .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
        .product(name: "CasePaths", package: "swift-case-paths"),
        .product(name: "AsyncLocationKit", package: "AsyncLocationKit"),
        .product(name: "NukeUI", package: "Nuke"),
        .product(name: "SwiftUIIntrospect", package: "swiftui-introspect"),
        .product(name: "SystemNotification", package: "SystemNotification"),
      ],
      plugins: [
        .plugin(name: "LicenseProviderPlugin", package: "LicenseProvider"),
      ]
    ),
    .target(
      name: "NiaBisClient",
      dependencies: [
        .product(name: "HTTPTypes", package: "swift-http-types"),
        .product(name: "HTTPTypesFoundation", package: "swift-http-types"),
      ]
    ),
    .testTarget(
      name: "NiaBisClientTests",
      dependencies: [
        .target(name: "NiaBisClient"),
      ]
    ),
    .testTarget(
      name: "NiaBisDataTests",
      dependencies: [
        .target(name: "NiaBisData"),
      ]
    ),
    .testTarget(
      name: "NiaBisUITests",
      dependencies: [
        .target(name: "NiaBisUI"),
      ]
    ),
  ]
)
