import Foundation
@preconcurrency import ProjectDescription

public extension Project {
	enum Environment {
		public static let appName = "DearDiary"
        public static let destinations: Destinations = [.iPhone]
        public static let deploymentTarget: DeploymentTargets = .iOS("18.0")
		public static let bundlePrefix = "com.bibumtiger"
		public static let featureProductType = ProjectDescription.Product.staticLibrary
        public static let dependecies: [TargetDependency] = [
            .package(product: "ComposableArchitecture", type: .runtime),
            .package(product: "FirebaseAuth", type: .runtime),
            .package(product: "GoogleSignIn", type: .runtime),
            .package(product: "GoogleSignInSwift", type: .runtime),
            .package(product: "Moya", type: .runtime),
            .package(product: "SwiftUICalendar", type: .runtime)
        ]
        public static let packages: [Package] = [
            .remote(url: "https://github.com/pointfreeco/swift-composable-architecture.git", requirement: .upToNextMajor(from: "1.15.2")),
            .remote(url: "https://github.com/Moya/Moya.git", requirement: .upToNextMajor(from: "15.0.3")),
            .remote(url: "https://github.com/GGJJack/SwiftUICalendar", requirement: .upToNextMajor(from: "0.1.13")),
            .remote(url: "https://github.com/firebase/firebase-ios-sdk", requirement: .upToNextMajor(from: "10.20.0")),
            .remote(url: "https://github.com/google/GoogleSignIn-iOS", requirement: .upToNextMajor(from: "7.0.0"))
        ]
	}
}
