import Foundation
@preconcurrency import ProjectDescription

public extension Settings {
    static let defaultSettings: Self = {
        .settings(configurations: [
            .defaultRelease,
            .defaultDebug,
            .defaultTest
        ])
    }()
}
