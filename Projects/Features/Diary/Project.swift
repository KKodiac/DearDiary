@preconcurrency import ProjectDescription
import DependencyPlugin

let project = Project(
    name: "Diary",
    targets: [
        .target(
            name: "Diary",
            destinations: Project.Environment.destinations,
            product: .staticLibrary,
            bundleId: "\(Project.Environment.bundlePrefix).\(Project.Environment.appName).Features.Diary",
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
            name: "DiaryTest",
            destinations: Project.Environment.destinations,
            product: .unitTests,
            bundleId: "\(Project.Environment.bundlePrefix).\(Project.Environment.appName).Features.DiaryTest",
            infoPlist: .extendingDefault(with: Project.Secrets.testInfoPList),
            sources: [.glob(.relativeToCurrentFile("Tests/**"))],
            dependencies: [
                .target(name: "DiaryExample"),
                .external(name: "SnapshotTesting")
            ],
            settings: .settings(configurations: [.defaultDebug, .defaultRelease])
        ),
        .target(
            name: "DiaryExample",
            destinations: Project.Environment.destinations,
            product: .app,
            bundleId: "\(Project.Environment.bundlePrefix).\(Project.Environment.appName).Features.DiaryExample",
            infoPlist: .extendingDefault(with: Project.Secrets.appInfoPList),
            sources: [.glob(.relativeToCurrentFile("Example/*"))],
            dependencies: [
                .target(name: "Diary")
            ],
            settings: .settings(configurations: [.defaultDebug, .defaultRelease])
        ),
    ]
)
