import Foundation
import Dependencies
import ExternalDependencies
import FirebaseAuth

final class TestableFirebaseAuthService: FirebaseAuthServiceInterface {
    var clientID: String? {
        FirebaseApp.app()?.options.clientID
    }
    
    @MainActor
    func configure() throws {
        guard FirebaseApp.app() == nil else {
            throw FirebaseAuthError.firebaseAppIsAlreadyConfigured
        }
        
        guard let path = Bundle(for: type(of: self)).path(forResource: "Info", ofType: "plist"),
              let options = FirebaseOptions(contentsOfFile: path) else {
            assert(false, "Couldn't load configuration file.")
            return
        }
        
        FirebaseApp.configure(options: options)
    }
    
    func signIn(_ auth: AuthCredential) async throws -> AuthDataResult {
        let authApp = FirebaseAuth.Auth.auth()
        return try await authApp.signIn(with: auth)
    }
    
    func signIn(email: String, password: String) async throws -> AuthDataResult {
        let authApp = FirebaseAuth.Auth.auth()
        return try await authApp.signIn(withEmail: email, password: password)
    }
    
    func signOut() throws {
        let authApp = FirebaseAuth.Auth.auth()
        try authApp.signOut()
    }
}

extension AuthClient: TestDependencyKey {
    public static let testValue = AuthClient(
        firebaseAuthService: TestableFirebaseAuthService(),
        appleAuthService: AppleAuthService(),
        googleAuthService: GoogleAuthService()
    )
}