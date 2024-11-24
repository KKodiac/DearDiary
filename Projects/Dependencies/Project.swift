@preconcurrency import ProjectDescription
import DependencyPlugin

let project = Project(
    name: "InternalDependencies",
    targets: [
        .target(
            name: "InternalDependencies",
            destinations: Project.Environment.destinations,
            product: .staticLibrary,
            bundleId: "\(Project.Environment.bundlePrefix).\(Project.Environment.appName).InternalDependencies",
            deploymentTargets: Project.Environment.deploymentTarget,
            infoPlist: .default,
            sources: ["Sources/*"],
            dependencies: [
                .target(name: "Auth", condition: .when(.all)),
                .target(name: "Assistant", condition: .when(.all)),
                .target(name: "Persistence", condition: .when(.all))
            ],
            settings: .settings(configurations: [.defaultDebug, .defaultRelease])
        ),
        .target(
            name: "Auth",
            destinations: Project.Environment.destinations,
            product: .staticLibrary,
            bundleId: "\(Project.Environment.bundlePrefix).\(Project.Environment.appName).InternalDependencies.Auth",
            deploymentTargets: Project.Environment.deploymentTarget,
            infoPlist: .default,
            sources: ["Auth/**"],
            dependencies: [
                .project(
                    target: "ExternalDependencies",
                    path: .relativeToRoot("Projects/ExternalDependencies")
                ),
            ],
            settings: .settings(configurations: [.defaultDebug, .defaultRelease])
        ),
        .target(
            name: "Assistant",
            destinations: Project.Environment.destinations,
            product: .staticLibrary,
            bundleId: "\(Project.Environment.bundlePrefix).\(Project.Environment.appName).InternalDependencies.Assistant",
            deploymentTargets: Project.Environment.deploymentTarget,
            infoPlist: .default,
            sources: ["Assistant/**"],
            dependencies: [
                .project(
                    target: "ExternalDependencies",
                    path: .relativeToRoot("Projects/ExternalDependencies")
                ),
            ],
            settings: .settings(configurations: [.defaultDebug, .defaultRelease])
        ),
        .target(
            name: "Persistence",
            destinations: Project.Environment.destinations,
            product: .staticLibrary,
            bundleId: "\(Project.Environment.bundlePrefix).\(Project.Environment.appName).InternalDependencies.Persistence",
            deploymentTargets: Project.Environment.deploymentTarget,
            infoPlist: .extendingDefault(with: Project.Secrets.appInfoPList),
            sources: ["Persistence/**"],
            dependencies: [
                .project(
                    target: "ExternalDependencies",
                    path: .relativeToRoot("Projects/ExternalDependencies")
                ),
            ],
            settings: .settings(configurations: [.defaultDebug, .defaultRelease])
        )
    ]
)
