import Foundation

public enum ValidationError: LocalizedError {
    case passwordDoesNotMatch
    case otherError(Error)
    
    public var errorDescription: String? {
        switch self {
        case .passwordDoesNotMatch:
            return "The password does not match."
        case .otherError(let error):
            return "The authorization error with other error: \(error.localizedDescription)"
        }
    }
    
    public var errorMessage: String {
        return errorDescription ?? "Unknown google auth error: \(self.localizedDescription)"
    }
}
