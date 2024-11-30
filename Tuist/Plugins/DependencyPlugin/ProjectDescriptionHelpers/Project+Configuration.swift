import Foundation
@preconcurrency import ProjectDescription

public extension Configuration {
    static var defaultDebug: Self {
        .debug(name: "Debug", settings: [
            Project.SwiftVersion.declaration: Project.SwiftVersion.value(for: .debug),
            Project.OtherLinkerFlag.declaration: Project.OtherLinkerFlag.value(for: .debug),
        ])
    }
    
    static var defaultRelease: Self {
        .release(name: "Release", settings: [
            Project.SwiftVersion.declaration: Project.SwiftVersion.value(for: .release),
            Project.OtherLinkerFlag.declaration: Project.OtherLinkerFlag.value(for: .release),
        ])
    }
    
    static var defaultTest: Self {
        .debug(name: "Test", settings: [
            Project.SwiftVersion.declaration: Project.SwiftVersion.value(for: .test),
            Project.OtherLinkerFlag.declaration: Project.OtherLinkerFlag.value(for: .test),
        ])
    }
}

fileprivate protocol ProjectSettings {
    static var declaration: String { get }
    static func value(for settings: Project.Configuration) -> SettingValue
}

extension Project {
    fileprivate enum Configuration {
        case debug
        case release
        case test
    }
    
    fileprivate struct OtherLinkerFlag: ProjectSettings {
        static let declaration: String = "OTHER_LDFLAGS"
        
        static func value(for settings: Project.Configuration) -> ProjectDescription.SettingValue {
            switch settings {
            case .debug:
                return "-ObjC"
            case .release:
                return "-ObjC"
            case .test:
                return "-ObjC"
            }
        }
    }
    
    fileprivate struct SwiftVersion: ProjectSettings {
        static let declaration: String = "SWIFT_VERSION"
        
        static func value(for settings: Project.Configuration) -> ProjectDescription.SettingValue {
            switch settings {
            case .debug:
                return "5.10"
            case .release:
                return "6.0"
            case .test:
                return "6.0"
            }
        }
    }
    
    fileprivate struct SwiftStrictConcurrency: ProjectSettings {
        static let declaration: String = "SWIFT_STRICT_CONCURRENCY"
        
        static func value(for settings: Project.Configuration) -> SettingValue {
            switch settings {
            case .debug:
                return "complete"
            case .release:
                return "complete"
            case .test:
                return "minimal"
            }
        }
    }
}
