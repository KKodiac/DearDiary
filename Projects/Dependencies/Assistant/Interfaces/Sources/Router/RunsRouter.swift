import ExternalDependencies
import Foundation

public enum RunsRouter {
    case createRun(threadID: String)
    case createThreadAndRun(parameter: ThreadRunRequestDTO)
    case listRuns(threadID: String)
    case retrieveRun(threadID: String, runID: String)
    case modifyRun(threadID: String, runID: String)
    case cancelRun(threadID: String, runID: String)
    
    case listRunSteps(threadID: String, runID: String)
    case retrieveRunStep(threadID: String, runID: String, stepID: String)
}

extension RunsRouter: DefaultTargetType {
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
            return .requestParameters(
                parameters: [:],
                encoding: JSONEncoding.default
            )
        case .createThreadAndRun(let parameter):
            return .requestParameters(
                parameters: ["assistant_id": parameter.assistantID, "thread": parameter.thread],
                encoding: JSONEncoding.default
            )
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
