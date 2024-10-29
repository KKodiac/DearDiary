import Foundation

public struct Profile: Codable {
    var name: String
    var personality: Personality
}

public enum Personality: String, CaseIterable, Codable, Sendable {
    case basic
}
