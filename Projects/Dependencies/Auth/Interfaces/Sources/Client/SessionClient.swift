import Dependencies
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

public struct SessionClient: Sendable {
    public var signOut: @Sendable () async throws -> Void

    public init(signOut: @escaping @Sendable () async throws -> Void) {
        self.signOut = signOut
    }
}

extension SessionClient: DependencyKey {
    public static let liveValue = Self(signOut: {
        try await MainActor.run {
            try AuthClient.liveValue.configure()
            try FirebaseAuth.Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
        }
    })
    public static let testValue = Self(signOut: { throw FirebaseAuthError.failedToConfigureFirebaseApp })
}

public extension DependencyValues {
    var sessionClient: SessionClient {
        get { self[SessionClient.self] }
        set { self[SessionClient.self] = newValue }
    }
}
