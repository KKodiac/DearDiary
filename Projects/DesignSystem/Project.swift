@preconcurrency import ProjectDescription
import DependencyPlugin

let project = Project(
    name: "DesignSystem",
    targets: [
        .target(
            name: "DesignSystem",
            destinations: Project.Environment.destinations,
            product: .staticLibrary,
            bundleId: "\(Project.Environment.bundlePrefix).\(Project.Environment.appName).DesignSystem",
            deploymentTargets: Project.Environment.deploymentTarget,
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            settings: .settings(configurations: [.defaultDebug, .defaultRelease])
        ),
    ],
    resourceSynthesizers: [
        .assets(),
        .fonts()
    ]
)
