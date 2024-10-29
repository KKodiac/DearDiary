import Foundation

public struct User: Sendable {
    var uid: String
    var email: String?
    var name: String?
    var isNewUser: Bool?
}
