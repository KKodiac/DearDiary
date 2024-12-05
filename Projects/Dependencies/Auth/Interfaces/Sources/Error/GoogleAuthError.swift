import Foundation

public enum GoogleAuthError: LocalizedError {
    case googleViewControllerNotFound
    case invalidIDToken
    case invalidFirebaseApp
    case rootViewControllerNotFound
    case otherError(Error)
    
    public var errorDescription: String? {
        switch self {
        case .googleViewControllerNotFound:         return "Google Sign In View Controller not found"
        case .invalidIDToken:                       return "Invalid ID Token"
        case .invalidFirebaseApp:                   return "Invalid Firebase App"
        case .rootViewControllerNotFound:           return "Root View Controller not found"
        case .otherError(let error):                return "The authorization error with other error: \(error.localizedDescription)"
        }
    }
    
    public var errorMessage: String {
        return errorDescription ?? "Unknown google auth error: \(self.localizedDescription)"
    }
    
    public init(error: Error) {
        switch (error as NSError).code {
        default:        self = .otherError(error)
        }
    }
}
