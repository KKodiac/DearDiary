import Dependencies
import Foundation

public struct AuthClient {
    private let firebase: FirebaseAuthServiceInterface
    private let apple: AppleAuthServiceInterface
    private let google: GoogleAuthServiceInterface
    private let validator: ValidationServiceInterface
    
    public init(
        // MARK: - Initializer Auth Services
        firebaseAuthService: FirebaseAuthServiceInterface,
        appleAuthService: AppleAuthServiceInterface,
        googleAuthService: GoogleAuthServiceInterface,
        validator: ValidationServiceInterface
    ) {
        self.firebase = firebaseAuthService
        self.apple = appleAuthService
        self.google = googleAuthService
        self.validator = validator
    }
    
    @MainActor
    public func configure() -> Void {
        guard firebase.isConfigured == false else { return }
        firebase.configure()
    }
    
    @discardableResult
    public func signInWithGoogle() async throws -> AuthDataResult {
        guard let clientID = firebase.clientID else {
            throw AuthError.firebaseAuthError(.clientIDIsNil)
        }
        
        do {
            let credential = try await google.login(clientID)
            let result = try await firebase.signIn(credential)
            
            return result
        } catch  {
            throw AuthError(error: error)
        }
    }
    
    @discardableResult
    public func signInWithApple() async throws -> AuthDataResult {
        do {
            let credential = try await apple.login()
            let result = try await firebase.signIn(credential)
            
            return result
        } catch {
            throw  AuthError(error: error)
        }
    }
    
    @discardableResult
    public func signInWithEmail(
        email: String,
        password: String
    ) async throws -> AuthDataResult {
        do {
            let result = try await firebase.signIn(email: email, password: password)
            
            return result
        } catch {
            throw AuthError(error: error)
        }
    }
    
    @discardableResult
    public func signUpWithEmail(
        email: String,
        password: String,
        confirmPassword: String
    ) async throws -> AuthDataResult {
        do {
            try validator.validate(password: password, with: confirmPassword)
            let result = try await firebase.signUp(email: email, password: password)
            
            return result
        } catch {
            throw AuthError(error: error)
        }
    }
}

extension AuthClient: DependencyKey {
    public static let liveValue = AuthClient(
        firebaseAuthService: FirebaseAuthService(),
        appleAuthService: AppleAuthService(),
        googleAuthService: GoogleAuthService(),
        validator: ValidationService()
    )
}

extension DependencyValues {
    public var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}
