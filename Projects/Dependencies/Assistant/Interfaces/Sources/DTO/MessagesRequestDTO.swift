import Foundation

public struct MessagesRequestDTO: Encodable {
    var role: Role
    var content: String
}
