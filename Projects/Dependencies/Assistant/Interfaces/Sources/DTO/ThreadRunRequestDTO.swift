public struct ThreadRunRequestDTO: Encodable {
    var assistantID: String
    var thread: Thread
    
    init(assistantID: String, text: String) {
        self.assistantID = assistantID
        self.thread = Thread(message: [
            Messages(role: .user, content: text)
        ])
    }
}
