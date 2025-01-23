import Moya

public enum AssistantsRouter {
    case createAssistant
    case listAssistants
    case retrieveAssistant(String)
    case modifiyAssistant(String)
    case deleteAssistant(String)
}

extension AssistantsRouter: DefaultTargetType {
    public var path: String {
        switch self {
        case .createAssistant, .listAssistants:
            return "/assistants"
        case .retrieveAssistant(let assistantID), .modifiyAssistant(let assistantID), .deleteAssistant(let assistantID):
            return "/assistants/\(assistantID)"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .createAssistant, .modifiyAssistant:
            return .post
        case .listAssistants, .retrieveAssistant:
            return .get
        case .deleteAssistant:
            return .delete
        }
    }

    public var task: Moya.Task {
        switch self {
        case .createAssistant:
            return .requestParameters(parameters: [:], encoding: JSONEncoding.default)
        case .listAssistants:
            return .requestParameters(parameters: [:], encoding: URLEncoding.queryString)
        case .modifiyAssistant:
            return .requestParameters(parameters: [:], encoding: JSONEncoding.default)
        case .retrieveAssistant, .deleteAssistant:
            return .requestPlain
        }
    }
}
