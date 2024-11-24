import FirebaseCore

public protocol FirebaseAuthServiceInterface {
    var clientID: String? { get }
    
    func configure() async throws
    func signIn(_: AuthCredential) async throws -> AuthDataResult
    func signOut() async throws
}

class FirebaseAuthService: NSObject {
    let appName: String = Bundle.main.bundleIdentifier ?? "com.deardiary.app"
}
