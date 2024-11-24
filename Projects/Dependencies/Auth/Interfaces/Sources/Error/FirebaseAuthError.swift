import Foundation

enum FirebaseAuthError: LocalizedError {
    case unknown
    case firebaseAppIsAlreadyConfigured
    case otherError(Error)
    
    public var errorDescription: String? {
        switch self {
        case .unknown:                  return "The authorization attempt failed for an unknown reason."
        case .firebaseAppIsAlreadyConfigured: return "The configuration attempt failed because the firebase app is already configured."
        case .otherError(let error):    return "The authorization error with other error: \(error.localizedDescription)"
        }
    }
    
    public var errorMessage: String {
        return errorDescription ?? "unknown firebaseAuthError: \(self.localizedDescription)"
    }
    
    public init(error: Error) {
        switch (error as NSError).code {
        default:        self = .otherError(error)
        }
    }
}
