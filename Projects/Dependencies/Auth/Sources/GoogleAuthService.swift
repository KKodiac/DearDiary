import Firebase
import GoogleSignIn
import GoogleSignInSwift

extension GoogleAuthService: GoogleAuthServiceInterface {
    public func login(_ clientID: String) async throws -> AuthCredential {
        guard let controller = await (
            UIApplication.shared.connectedScenes.first as? UIWindowScene
        )?.windows.first?.rootViewController else {
            throw GoogleAuthError.googleViewControllerNotFound
        }
        let provider = GIDSignIn.sharedInstance
        provider.configuration = GIDConfiguration(clientID: clientID)
        let result = try await provider.signIn(withPresenting: controller)
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
    
    public func logout() async throws {
        GIDSignIn.sharedInstance.signOut()
    }
}
