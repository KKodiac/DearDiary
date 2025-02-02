import Foundation
import Moya

public enum MessagesAssistantError: LocalizedError {
    case successfulStatusCodeNotFound(MoyaError)
    case responseDecodingError(DecodingError)
    case otherError(Error)
    
    public var errorDescription: String? {
        nil
    }
    
    public var errorMessage: String {
        return errorDescription ?? "Unknown messages assistant error: \(self.localizedDescription)"
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
