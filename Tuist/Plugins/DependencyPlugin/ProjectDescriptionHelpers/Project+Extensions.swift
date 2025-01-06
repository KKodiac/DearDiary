import Foundation
@preconcurrency import ProjectDescription

public extension Project {
	enum Environment {
		public static let appName = "DearDiary"
        public static let destinations: Destinations = [.iPhone]
        public static let deploymentTarget: DeploymentTargets = .iOS("18.0")
		public static let bundlePrefix = "com.bibumtiger"
		public static let featureProductType = ProjectDescription.Product.staticLibrary
        public static let staticLibraryExcludedSource: [Path] = ["Project.swift", "Tests/**", "Example/**"]
	}
}
