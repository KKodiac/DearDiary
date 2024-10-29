@preconcurrency import ProjectDescription
import DependencyPlugin

let project = Project(
    name: "DearDiary",
    packages: Project.Environment.packages,
    targets: [
        .target(
            name: "DearDiary",
            destinations: Project.Environment.destinations,
            product: .app,
            bundleId: "\(Project.Environment.bundlePrefix).\(Project.Environment.appName).DearDiary",
            infoPlist: .extendingDefault(with: Project.Secrets.appInfoPList),
            sources: ["Sources/**"],
            entitlements: .dictionary([
                "com.apple.developer.applesignin": .array(["Default"])
            ]),
            dependencies: Project.Environment.dependecies + [
                .project(
                    target: "Features",
                    path: .relativeToRoot("Projects/Features"),
                    condition: .when([.ios])
                )
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
