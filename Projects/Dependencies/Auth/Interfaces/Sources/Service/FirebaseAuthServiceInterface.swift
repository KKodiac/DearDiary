import FirebaseCore

public protocol FirebaseAuthServiceInterface {
    var clientID: String? { get }
    var isConfigured: Bool { get }
    
    @MainActor func configure()
    func signIn(email: String, password: String) async throws -> AuthDataResult
    func signIn(_: AuthCredential) async throws -> AuthDataResult
    func signOut() async throws
}

final class FirebaseAuthService: NSObject {
    let appName: String = Bundle.main.bundleIdentifier ?? "com.deardiary.app"
}
