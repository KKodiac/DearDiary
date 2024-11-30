import Firebase
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift

extension GoogleAuthService: GoogleAuthServiceInterface {
    @MainActor
    public func login(_ clientID: String, vc viewController: UIViewController) async throws -> AuthCredential {
        let provider = GIDSignIn.sharedInstance
        provider.configuration = GIDConfiguration(clientID: clientID)
        let result = try await provider.signIn(withPresenting: viewController)
        guard let token = result.user.idToken else {
            throw GoogleAuthError.invalidIDToken
        }
        let tokenString = result.user.accessToken.tokenString
        let credential = GoogleAuthProvider.credential(
            withIDToken: token.tokenString,
            accessToken: tokenString
        )
        return credential
    }
    
    @MainActor
    public func logout() async throws {
        GIDSignIn.sharedInstance.signOut()
    }
}
