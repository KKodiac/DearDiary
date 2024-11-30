@preconcurrency import ProjectDescription
import DependencyPlugin

let project = Project(
    name: "DearDiary",
    organizationName: "BibumTiger",
    targets: [
        .target(
            name: "DearDiary",
            destinations: Project.Environment.destinations,
            product: .app,
            bundleId: "\(Project.Environment.bundlePrefix).\(Project.Environment.appName).App",
            infoPlist: .extendingDefault(with: Project.Secrets.appInfoPList),
            sources: ["Sources/**"],
            entitlements: .dictionary([
                "com.apple.developer.applesignin": .array(["Default"])
            ]),
            dependencies: [
                .project(
                    target: "Features",
                    path: .relativeToRoot("Projects/Features"),
                    condition: .when([.ios])
                ),
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
            name: "DearDiaryTests",
            destinations: Project.Environment.destinations,
            product: .unitTests,
            bundleId: "\(Project.Environment.bundlePrefix).\(Project.Environment.appName).DearDiaryTests",
            infoPlist: .default,
            sources: ["Tests/**"],
            resources: [],
            dependencies: [.target(name: "DearDiary")],
            settings: .settings(configurations: [.defaultTest])
        ),
    ]
)
