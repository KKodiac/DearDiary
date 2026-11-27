import Dependencies
import Foundation
import FirebaseAuth

private enum OfflineAuthError: Error {
    case unavailable
}

/// Test and preview authentication never initializes Firebase or opens provider UI.
private struct OfflineFirebaseAuthService: FirebaseAuthServiceInterface {
    var clientID: String? { nil }
    var isConfigured: Bool { true }
    @MainActor func configure() {}
    func signIn(_ credential: AuthCredential) async throws -> AuthDataResult { throw OfflineAuthError.unavailable }
    func signIn(email: String, password: String) async throws -> AuthDataResult { throw OfflineAuthError.unavailable }
    func signUp(email: String, password: String) async throws -> AuthDataResult { throw OfflineAuthError.unavailable }
    func signOut() async throws { throw OfflineAuthError.unavailable }
}

private struct OfflineAppleAuthService: AppleAuthServiceInterface {
    func login() async throws -> AuthCredential { throw OfflineAuthError.unavailable }
}

private struct OfflineGoogleAuthService: GoogleAuthServiceInterface {
    @MainActor func login(_ clientID: String) async throws -> AuthCredential { throw OfflineAuthError.unavailable }
    @MainActor func logout() async throws { throw OfflineAuthError.unavailable }
}

extension AuthClient: TestDependencyKey {
    public static let testValue = AuthClient(
        firebaseAuthService: OfflineFirebaseAuthService(),
        appleAuthService: OfflineAppleAuthService(),
        googleAuthService: OfflineGoogleAuthService(),
        validator: ValidationService()
    )
    public static let snapshotValue = testValue
}
