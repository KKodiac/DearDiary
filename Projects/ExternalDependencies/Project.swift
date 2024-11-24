@preconcurrency import ProjectDescription
import DependencyPlugin

let project = Project(
    name: "ExternalDependencies",
    targets: [
        .target(
            name: "ExternalDependencies",
            destinations: Project.Environment.destinations,
            product: .staticLibrary,
            bundleId: "\(Project.Environment.bundlePrefix).\(Project.Environment.appName).ExternalDependencies",
            deploymentTargets: Project.Environment.deploymentTarget,
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: [],
            dependencies: [
                .external(
                    name: "ComposableArchitecture",
                    condition: .when([.ios, .macos])
                ),
                .external(
                    name: "Moya",
                    condition: .when([.ios, .macos])
                ),
                .external(
                    name: "FirebaseAuth",
                    condition: .when([.ios, .macos])
                ),
                .external(
                    name: "SwiftUICalendar",
                    condition: .when([.ios, .macos])
                ),
                .external(
                    name: "GoogleSignIn",
                    condition: .when([.ios, .macos])
                ),
                .external(
                    name: "GoogleSignInSwift",
                    condition: .when([.ios, .macos])
                )
            ],
            settings: .settings(configurations: [.defaultDebug, .defaultRelease])
        ),
    ]
)
