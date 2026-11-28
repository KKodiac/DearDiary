import FirebaseAuth
import Foundation
import GoogleSignIn

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
    
    /// A nil message means the user canceled and no alert is needed.
    public var userMessage: String? {
        switch self {
        case .appleAuthError(.canceled):
            return nil
        case .firebaseAuthError(.failedToConfigureFirebaseApp),
             .firebaseAuthError(.clientIDIsNil), .googleAuthError(.invalidFirebaseApp):
            return "Account services are unavailable right now. Please try again later."
        case let .firebaseAuthError(.otherError(error)),
             let .googleAuthError(.otherError(error)),
             let .unExpectedError(error):
            return Self.message(for: error)
        default:
            return Self.retryMessage
        }
    }

    private static let retryMessage = "Something went wrong. Please try again."

    private static func message(for error: Error) -> String? {
        if case ValidationError.passwordDoesNotMatch = error {
            return "Enter the same password in both password fields."
        }
        let providerError = error as NSError
        if providerError.domain == kGIDSignInErrorDomain,
           providerError.code == -5 { // kGIDSignInErrorCodeCanceled
            return nil
        }
        guard providerError.domain == AuthErrorDomain else { return retryMessage }

        switch AuthErrorCode.Code(rawValue: providerError.code) {
        case .invalidEmail:
            return "Enter a valid email address."
        case .wrongPassword, .userNotFound, .invalidCredential:
            return "Check your sign-in details and try again."
        case .emailAlreadyInUse:
            return "An account already uses this email. Try signing in instead."
        case .weakPassword:
            return "Choose a stronger password and try again."
        case .networkError:
            return "Check your internet connection and try again."
        case .tooManyRequests:
            return "There have been too many attempts. Wait a few minutes and try again."
        default:
            return retryMessage
        }
    }

    public init(error: Error) {
        switch error {
        case let error as AuthError:
            self = error

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
