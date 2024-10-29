@preconcurrency import ProjectDescription
import DependencyPlugin

let project = Project(
    name: "ExternalDependencies",
    packages: Project.Environment.packages,
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
                .package(product: "ComposableArchitecture", type: .runtime),
                .package(product: "Moya", type: .runtime),
                .package(product: "FirebaseAuth", type: .runtime),
                .package(product: "SwiftUICalendar", type: .runtime),
                .package(product: "GoogleSignIn", type: .runtime),
                .package(product: "GoogleSignInSwift", type: .runtime)
            ],
            settings: .settings(configurations: [.defaultDebug, .defaultRelease])
        ),
    ]
)
