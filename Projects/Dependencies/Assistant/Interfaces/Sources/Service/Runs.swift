import Moya

public enum Runs {
    case createRun(String)
    case createThreadAndRun
    case listRuns(String)
    case retrieveRun(String, String)
    case modifyRun(String, String)
    case cancelRun(String, String)
    
    case listRunSteps(String, String)
    case retrieveRunStep(String, String, String)
}

extension Runs: DefaultTargetType {
    public var path: String {
        switch self {
        case .createRun(let threadID), .listRuns(let threadID):
            return "/threads/\(threadID)/runs"
        case .createThreadAndRun:
            return "/threads/runs"
        case let .retrieveRun(threadID, runID), let .modifyRun(threadID, runID):
            return "/threads/\(threadID)/runs/\(runID)"
        case let .cancelRun(threadID, runID):
            return "/threads/\(threadID)/runs/\(runID)/cancel"
        case let .listRunSteps(threadID, runID):
            return "/threads/\(threadID)/runs/\(runID)/steps"
        case let .retrieveRunStep(threadID, runID, stepID):
            return "/threads/\(threadID)/runs/\(runID)/steps/\(stepID)"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .createRun, .createThreadAndRun, .modifyRun, .cancelRun:
            return .post
        case .listRuns, .retrieveRun, .listRunSteps, .retrieveRunStep:
            return .get
        }
    }

    public var task: Moya.Task {
        switch self {
        case .createRun(_):
            return .requestParameters(parameters: [:], encoding: JSONEncoding.default)
        case .createThreadAndRun:
            return .requestParameters(parameters: [:], encoding: JSONEncoding.default)
        case .listRuns(_):
            return .requestPlain
        case .retrieveRun(_, _):
            return .requestPlain
        case .modifyRun(_, _):
            return .requestPlain
        case .cancelRun(_, _):
            return .requestPlain
        case .listRunSteps(_, _):
            return .requestPlain
        case .retrieveRunStep(_, _, _):
            return .requestPlain
        }
    }
}
