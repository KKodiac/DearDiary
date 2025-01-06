@preconcurrency import ProjectDescription
import DependencyPlugin

let project = Project(
    name: "Features",
    targets: [
        .target(
            name: "Features",
            destinations: Project.Environment.destinations,
            product: .staticLibrary,
            bundleId: "\(Project.Environment.bundlePrefix).\(Project.Environment.appName).Features",
            infoPlist: .extendingDefault(with: Project.Secrets.appInfoPList),
            sources: [.glob(.relativeToCurrentFile("Features/*"))],
            dependencies: [
                .project(target: "Account", path: .relativeToCurrentFile("Account")),
                .project(target: "Diary", path: .relativeToCurrentFile("Diary")),
            ],
            settings: .settings(configurations: [.defaultDebug, .defaultRelease])
        )
    ]
)
