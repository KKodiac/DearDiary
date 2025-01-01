import Foundation
import Dependencies

public struct AuthClient {
    public typealias UID = String
    
    private let firebase: FirebaseAuthServiceInterface
    private let apple: AppleAuthServiceInterface
    private let google: GoogleAuthServiceInterface
    
    public init(
        // MARK: - Initializer Auth Services
        firebaseAuthService: FirebaseAuthServiceInterface,
        appleAuthService: AppleAuthServiceInterface,
        googleAuthService: GoogleAuthServiceInterface
    ) {
        self.firebase = firebaseAuthService
        self.apple = appleAuthService
        self.google = googleAuthService
    }
    
    @MainActor
    public func configure() throws -> Void {
        try firebase.configure()
    }
    
    @discardableResult
    public func signInWithGoogle() async throws -> UID {
        guard let clientID = firebase.clientID else {
            throw AuthError.firebaseAuthError(.clientIDIsNil)
        }
        
        do {
            let credential = try await google.login(clientID)
            let result = try await firebase.signIn(credential)
            
            return result.user.uid
        } catch  {
            throw AuthError(error: error)
        }
    }
    
    @discardableResult
    public func signInWithApple() async throws -> UID {
        do {
            let credential = try await apple.login()
            let result = try await firebase.signIn(credential)
            
            return result.user.uid
        } catch {
            throw  AuthError(error: error)
        }
    }
}

extension AuthClient: DependencyKey {
    public static let liveValue = AuthClient(
        firebaseAuthService: FirebaseAuthService(),
        appleAuthService: AppleAuthService(),
        googleAuthService: GoogleAuthService()
    )
}

extension DependencyValues {
    public var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}
