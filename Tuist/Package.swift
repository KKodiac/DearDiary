// swift-tools-version: 5.9
@preconcurrency import PackageDescription

#if TUIST
import ProjectDescription

let packageSettings = PackageSettings(
    // Customize the product types for specific package product
    // Default is .staticFramework
    // productTypes: ["Alamofire": .framework,]
)
#endif

let package = Package(
    name: "ExternalDependencies",
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture.git",
            exact: Version(stringLiteral: "1.15.2")
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-snapshot-testing",
            exact: Version(stringLiteral: "1.12.0")
        ),
        .package(
            url: "https://github.com/Moya/Moya.git",
            exact: Version(stringLiteral: "15.0.3")
        ),
        .package(
            url: "https://github.com/GGJJack/SwiftUICalendar",
            exact: Version(stringLiteral: "0.1.13")
        ),
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk",
            exact: Version(stringLiteral: "10.20.0")
        ),
        .package(
            url: "https://github.com/google/GoogleSignIn-iOS",
            exact: Version(stringLiteral: "7.0.0")
        ),
    ]
)
