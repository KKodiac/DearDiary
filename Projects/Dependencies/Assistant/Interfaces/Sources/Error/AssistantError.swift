import Foundation

public enum AssistantError: LocalizedError, Equatable {
    public static func == (lhs: AssistantError, rhs: AssistantError) -> Bool {
        return lhs.localizedDescription == rhs.localizedDescription
    }
    
    case activeThreadFound
    case runAssistantError(RunsAssistantError)
    case unknownError(Error)
    
    public var errorCode: String? {
        switch self {
        default:
            return nil
        }
    }
    
    public var errorMessage: String {
        switch self {
        case .activeThreadFound:
            return "activeThreadFound"
        case .runAssistantError(let runAssistantError):
            return "runAssistantError: \(runAssistantError.localizedDescription)"
        case .unknownError(let error):
            return "unknown authError: \(error.localizedDescription)"
        }
    }
    
    public var userMessage: String {
        switch self {
        default:
            return "클라이언트 오류입니다. \n잠시 후 다시 시도해 주세요."
        }
    }
    
    public init(error: Error) {
        switch error {
        case let error as RunsAssistantError:
            self = AssistantError.runAssistantError(error)
        default:
            self = AssistantError.unknownError(error)
        }
    }
}
