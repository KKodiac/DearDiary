import FirebaseCore

public protocol FirebaseAuthServiceInterface {
    var clientID: String? { get }
    
    @MainActor func configure() throws
    func signIn(email: String, password: String) async throws -> AuthDataResult
    func signIn(_: AuthCredential) async throws -> AuthDataResult
    func signOut() async throws
}

final class FirebaseAuthService: NSObject {
    let appName: String = Bundle.main.bundleIdentifier ?? "com.deardiary.app"
}
