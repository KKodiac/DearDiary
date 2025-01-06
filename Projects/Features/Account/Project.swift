@preconcurrency import ProjectDescription
import DependencyPlugin

let project = Project(
    name: "Account",
    targets: [
        .target(
            name: "Account",
            destinations: Project.Environment.destinations,
            product: .staticLibrary,
            bundleId: "\(Project.Environment.bundlePrefix).\(Project.Environment.appName).Features.Account",
            infoPlist: .extendingDefault(with: Project.Secrets.appInfoPList),
            sources: [.glob(.relativeToCurrentFile("**"), excluding: Project.Environment.staticLibraryExcludedSource)],
            dependencies: [
                .project(
                    target: "DesignSystem",
                    path: .relativeToRoot("Projects/DesignSystem")
                ),
                .project(
                    target: "InternalDependencies",
                    path: .relativeToRoot("Projects/Dependencies")
                ),
                .project(
                    target: "ExternalDependencies",
                    path: .relativeToRoot("Projects/ExternalDependencies")
                ),
                .project(
                    target: "Utility",
                    path: .relativeToRoot("Projects/Utility")
                ),
            ],
            settings: .settings(configurations: [.defaultDebug, .defaultRelease])
        ),
        .target(
            name: "AccountTest",
            destinations: Project.Environment.destinations,
            product: .unitTests,
            bundleId: "\(Project.Environment.bundlePrefix).\(Project.Environment.appName).Features.AccountTest",
            infoPlist: .extendingDefault(with: Project.Secrets.testInfoPList),
            sources: [.glob(.relativeToCurrentFile("Tests/**"))],
            dependencies: [
                .target(name: "AccountExample"),
                .external(name: "SnapshotTesting")
            ],
            settings: .settings(configurations: [.defaultDebug, .defaultRelease])
        ),
        .target(
            name: "AccountExample",
            destinations: Project.Environment.destinations,
            product: .app,
            bundleId: "\(Project.Environment.bundlePrefix).\(Project.Environment.appName).Features.AccountExample",
            infoPlist: .extendingDefault(with: Project.Secrets.appInfoPList),
            sources: [.glob(.relativeToCurrentFile("Example/*"))],
            dependencies: [
                .target(name: "Account")
            ],
            settings: .settings(configurations: [.defaultDebug, .defaultRelease])
        ),
    ]
)
