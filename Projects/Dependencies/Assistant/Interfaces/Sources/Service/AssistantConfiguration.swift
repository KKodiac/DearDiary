struct AssistantConfiguration {
    private var threadID: String?
    var assistantID: String
    
    init(assistantID: String) {
        self.threadID = nil
        self.assistantID = assistantID
    }
    
    mutating func update(threadID: String) {
        self.threadID = threadID
    }
    
    var isAssistantThreadActive: Bool {
        self.threadID != nil
    }
    
    func fetchThreadID() throws -> String {
        guard let threadID = self.threadID else {
            throw AssistantConfigurationError.threadIDNotFound
        }
        return threadID
    }
}

enum AssistantConfigurationError: Error {
    case threadIDNotFound
}
