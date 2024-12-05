import Foundation

public enum AuthError: LocalizedError, Equatable {
    public static func == (lhs: AuthError, rhs: AuthError) -> Bool {
        return lhs.localizedDescription == rhs.localizedDescription
    }
    
    case appleAuthError(AppleAuthError)
    case firebaseAuthError(FirebaseAuthError)
    case googleAuthError(GoogleAuthError)
    case unExpectedError(Error)
    
    public var errorCode: String? {
        switch self {
        default:
            return nil
        }
    }
    
    public var errorMessage: String {
        switch self {
        case let .appleAuthError(appleAuthError):
            return appleAuthError.errorMessage
            
        case let .firebaseAuthError(firebaseAuthError):
            return firebaseAuthError.errorMessage
            
        case let .googleAuthError(googleAuthError):
            return googleAuthError.errorMessage
            
        case .unExpectedError(let error):
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
        case let error as AppleAuthError:
            self = AuthError.appleAuthError(error)
            
        case let error as FirebaseAuthError:
            self = AuthError.firebaseAuthError(error)
        
        case let error as GoogleAuthError:
            self = AuthError.googleAuthError(error)
            
        default:
            self = AuthError.unExpectedError(error)
        }
    }
}
