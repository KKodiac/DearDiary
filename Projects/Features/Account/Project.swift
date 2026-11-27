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
            deploymentTargets: Project.Environment.deploymentTarget,
            infoPlist: .extendingDefault(with: Project.Secrets.appInfoPList),
            sources: [.glob(.relativeToCurrentFile("**"), excluding: Project.Environment.staticLibraryExcludedSource)],
            dependencies: [
                .project(
                    target: "DesignSystem",
                    path: .relativeToRoot("Projects/DesignSystem")
                ),
                .project(target: "Auth", path: .relativeToRoot("Projects/Dependencies")),
                .external(name: "ComposableArchitecture"),
                .external(name: "GoogleSignIn"),
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
            deploymentTargets: Project.Environment.deploymentTarget,
            infoPlist: .extendingDefault(with: Project.Secrets.testInfoPList),
            sources: [.glob(.relativeToCurrentFile("Tests/**"))],
            dependencies: [
                .target(name: "AccountExample"),
                .external(name: "ComposableArchitecture"),
                .external(name: "SnapshotTesting")
            ],
            settings: .settings(configurations: [.defaultDebug, .defaultRelease])
        ),
        .target(
            name: "AccountExample",
            destinations: Project.Environment.destinations,
            product: .app,
            bundleId: "\(Project.Environment.bundlePrefix).\(Project.Environment.appName).Features.AccountExample",
            deploymentTargets: Project.Environment.deploymentTarget,
            infoPlist: .extendingDefault(with: Project.Secrets.appInfoPList),
            sources: [.glob(.relativeToCurrentFile("Example/*"))],
            dependencies: [
                .target(name: "Account"),
                .external(name: "ComposableArchitecture")
            ],
            settings: .settings(configurations: [.defaultDebug, .defaultRelease])
        ),
    ]
)
