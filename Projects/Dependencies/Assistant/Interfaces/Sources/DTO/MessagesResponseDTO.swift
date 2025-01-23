public struct MessagesResponseDTO: Decodable {
    var id: String
    var object: String
    var createAt: Int
    var assistantID: String
    var threadID: String
    var runID: String
    var role: Role
    var content: [Content]
}
