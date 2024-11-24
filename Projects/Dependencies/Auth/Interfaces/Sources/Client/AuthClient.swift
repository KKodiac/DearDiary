import Foundation
import ComposableArchitecture

public struct AuthClient {
    public let firebase: FirebaseAuthServiceInterface
    public let apple: AppleAuthServiceInterface
    public let google: GoogleAuthServiceInterface
    
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
}

extension AuthClient: DependencyKey {
    public static var liveValue = AuthClient(
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
