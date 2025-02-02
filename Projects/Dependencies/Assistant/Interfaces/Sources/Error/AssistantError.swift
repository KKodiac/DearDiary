import Foundation
import Moya

public enum AssistantError: LocalizedError, Equatable {
    public static func == (lhs: AssistantError, rhs: AssistantError) -> Bool {
        return lhs.localizedDescription == rhs.localizedDescription
    }
    
    case networkResponseError(MoyaError)
    case responseDecodingError(DecodingError)
    
    case activeThreadNotFound
    case configurationFailed
    case runAssistantError(RunsAssistantError)
    case messageAssistantError(MessagesAssistantError)
    case unknownError(Error)
    
    public var errorCode: String? {
        switch self {
        default:
            return nil
        }
    }
    
    public var errorMessage: String {
        switch self {
        case .networkResponseError:
            return "networkResponseError"
        case .responseDecodingError:
            return "responseDecodingError"
        case .activeThreadNotFound:
            return "activeThreadNotFound"
        case .configurationFailed:
            return "configurationFailed"
        case .runAssistantError(let runAssistantError):
            return "runAssistantError: \(runAssistantError.localizedDescription)"
        case .messageAssistantError(let messageAssistantError):
            return "messageAssistantError: \(messageAssistantError.localizedDescription)"
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
        case let error as MessagesAssistantError:
            self = AssistantError.messageAssistantError(error)
        case let error as MoyaError:
            self = .networkResponseError(error)
        case let error as DecodingError:
            self = .responseDecodingError(error)
        case let error as AssistantConfigurationError:
            self = AssistantError.configurationFailed
        case is Self:
            self = error as! Self
        default:
            self = AssistantError.unknownError(error)
        }
    }
}
