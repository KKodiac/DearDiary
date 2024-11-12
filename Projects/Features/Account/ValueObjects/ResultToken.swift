import Foundation
@preconcurrency import GoogleSignIn

struct ResultToken: Sendable {
    let idToken: String
    let accessToken: String
    
    init(user: GIDGoogleUser) throws {
        guard let idToken = user.idToken else {
            throw ResultTokenError()
        }
        self.idToken = idToken.tokenString
        self.accessToken = user.accessToken.tokenString
    }
    
    struct ResultTokenError: Error {
        let message: String = "Could not extract token from Google sign in result"
    }
}
