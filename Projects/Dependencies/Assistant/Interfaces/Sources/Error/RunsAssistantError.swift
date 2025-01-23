import Foundation
import Moya

public enum RunsAssistantError: LocalizedError {
    case successfulStatusCodeNotFound(MoyaError)
    case responseDecodingError(DecodingError)
    case otherError(Error)
    
    public var errorDescription: String? {
        switch self {
        case .successfulStatusCodeNotFound(let error):
            return "The assistant service failed to return a successful status code: \(error.localizedDescription)"
        case .otherError(let error):
            return "The assistant service returned error with other error: \(error.localizedDescription)"
        case .responseDecodingError(let error):
            return "The assistant service failed to decode the response: \(error.localizedDescription)"
        }
    }
    
    public var errorMessage: String {
        return errorDescription ?? "Unknown google auth error: \(self.localizedDescription)"
    }
    
    public init(error: Error) {
        switch error {
        case let error as MoyaError:
            self = .successfulStatusCodeNotFound(error)
        case let error as DecodingError:
            self = .responseDecodingError(error)
        default:
            self = .otherError(error)
        }
    }
}
