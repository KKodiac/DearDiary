@preconcurrency import ProjectDescription
import DependencyPlugin

let project = Project(
    name: "Utility",
    targets: [
        .target(
            name: "Utility",
            destinations: Project.Environment.destinations,
            product: .staticLibrary,
            bundleId: "\(Project.Environment.bundlePrefix).\(Project.Environment.appName).Utility",
            deploymentTargets: Project.Environment.deploymentTarget,
            infoPlist: .default,
            sources: ["Sources/**"],
            settings: .settings(configurations: [.defaultDebug, .defaultRelease])
        ),
    ]
)
