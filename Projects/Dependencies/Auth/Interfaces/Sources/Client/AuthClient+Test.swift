import Foundation
import Dependencies
import ExternalDependencies
import FirebaseAuth

final class TestableFirebaseAuthService: FirebaseAuthServiceInterface {
    private let testableFirebaseApp = "TestFirebaseApp"
    
    var clientID: String? {
        FirebaseApp.app()?.options.clientID
    }
    
    @MainActor
    func configure() throws {
        guard FirebaseApp.app(name: testableFirebaseApp) == nil else {
            return
        }
        
        guard let path = Bundle(for: type(of: self)).path(forResource: "Info", ofType: "plist"),
              let options = FirebaseOptions(contentsOfFile: path) else {
            assert(false, "Couldn't load configuration file.")
            return
        }
        
        FirebaseApp.configure(name: testableFirebaseApp, options: options)
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

final class SnapshotFirebaseAuthService: FirebaseAuthServiceInterface {
    private let firebaseApp = "SnapshotFirebaseApp"
    
    var clientID: String? {
        FirebaseApp.app()?.options.clientID
    }
    
    @MainActor
    func configure() throws {
        guard FirebaseApp.app(name: firebaseApp) == nil else {
            return
        }
        
        guard let path = Bundle(for: type(of: self)).path(forResource: "Info", ofType: "plist"),
              let options = FirebaseOptions(contentsOfFile: path) else {
            assert(false, "Couldn't load configuration file.")
            return
        }
        
        FirebaseApp.configure(name: firebaseApp, options: options)
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
    
    public static let snapshotValue = AuthClient(
        firebaseAuthService: SnapshotFirebaseAuthService(),
        appleAuthService: AppleAuthService(),
        googleAuthService: GoogleAuthService()
    )
}