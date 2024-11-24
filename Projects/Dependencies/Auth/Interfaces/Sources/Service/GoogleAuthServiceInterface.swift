import GoogleSignIn

public protocol GoogleAuthServiceInterface {
    func login(_: String) async throws -> AuthCredential
    func logout() async throws
}

class GoogleAuthService: NSObject {
    
}
