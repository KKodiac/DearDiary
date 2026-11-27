@preconcurrency import ProjectDescription
import DependencyPlugin

let project = Project(
    name: "CoreDependencies",
    targets: [
        .target(
            name: "Auth",
            destinations: Project.Environment.destinations,
            product: .staticLibrary,
            bundleId: "\(Project.Environment.bundlePrefix).\(Project.Environment.appName).CoreDependencies.Auth",
            deploymentTargets: Project.Environment.deploymentTarget,
            infoPlist: .default,
            sources: ["Auth/**"],
            dependencies: [
                .external(name: "Dependencies"),
                .external(name: "FirebaseAuth"),
                .external(name: "GoogleSignIn"),
            ],
            settings: .settings(configurations: [.defaultDebug, .defaultRelease])
        ),
        .target(
            name: "Assistant",
            destinations: Project.Environment.destinations,
            product: .staticLibrary,
            bundleId: "\(Project.Environment.bundlePrefix).\(Project.Environment.appName).CoreDependencies.Assistant",
            deploymentTargets: Project.Environment.deploymentTarget,
            infoPlist: .default,
            sources: ["Assistant/**"],
            dependencies: [
                .external(name: "Dependencies"),
            ],
            settings: .settings(configurations: [.defaultDebug, .defaultRelease])
        ),
        .target(
            name: "Persistence",
            destinations: Project.Environment.destinations,
            product: .staticLibrary,
            bundleId: "\(Project.Environment.bundlePrefix).\(Project.Environment.appName).CoreDependencies.Persistence",
            deploymentTargets: Project.Environment.deploymentTarget,
            infoPlist: .extendingDefault(with: Project.Secrets.appInfoPList),
            sources: ["Persistence/**"],
            dependencies: [
                .external(name: "ComposableArchitecture"),
                .external(name: "Dependencies"),
            ],
            settings: .settings(configurations: [.defaultDebug, .defaultRelease])
        )
    ]
)
