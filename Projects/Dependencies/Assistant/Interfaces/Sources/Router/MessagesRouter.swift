import Moya

public enum MessagesRouter {
    case createMessage(String)
    case listMessages(String)
    case retrieveMessage(String, String)
    case modifyMessage(String, String)
    case deleteMessage(String, String)
}

extension MessagesRouter: DefaultTargetType {
    public var path: String {
        switch self {
        case .createMessage(let threadID), .listMessages(let threadID):
            return "/threads/\(threadID)/messages"
        case let .retrieveMessage(threadID, messageID),
            let .modifyMessage(threadID, messageID),
            let .deleteMessage(threadID, messageID):
            return "/threads\(threadID)/messages/\(messageID)"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .createMessage, .modifyMessage:
            return .post
        case .listMessages, .retrieveMessage:
            return .get
        case .deleteMessage:
            return .delete
        }
    }

    public var task: Moya.Task {
        switch self {
        case .createMessage:
            return .requestParameters(parameters: [:], encoding: JSONEncoding.default)
        case .modifyMessage:
            return .requestParameters(parameters: [:], encoding: JSONEncoding.default)
        case .listMessages, .retrieveMessage, .deleteMessage:
            return .requestPlain
        }
    }
}
