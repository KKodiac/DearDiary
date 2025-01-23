import Moya

public enum ThreadsRouter {
    case createThread
    case retrieveThread(String)
    case modifyThread(String)
    case deleteThread(String)
}

extension ThreadsRouter: DefaultTargetType {
    public var path: String {
        switch self {
        case .createThread:
            return "/threads"
        case .retrieveThread(let threadID), .modifyThread(let threadID), .deleteThread(let threadID):
            return "/threads/\(threadID)"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .createThread, .modifyThread:
            return .post
        case .retrieveThread:
            return .get
        case .deleteThread:
            return .delete
        }
    }

    public var task: Moya.Task {
        switch self {
        case .createThread:
            return .requestParameters(parameters: [:], encoding: JSONEncoding.default)
        case .modifyThread:
            return .requestParameters(parameters: [:], encoding: JSONEncoding.default)
        case .retrieveThread, .deleteThread:
            return .requestPlain
        }
    }
}
