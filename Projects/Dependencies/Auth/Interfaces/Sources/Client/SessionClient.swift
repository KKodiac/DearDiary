import Dependencies
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

public struct SessionClient: Sendable {
    public struct Account: Equatable, Sendable {
        public let id: String
        public let email: String?

        public init(id: String, email: String?) {
            self.id = id
            self.email = email
        }
    }

    public var currentAccount: @Sendable () async throws -> Account?
    public var signOut: @Sendable () async throws -> Void

    public init(
        signOut: @escaping @Sendable () async throws -> Void,
        currentAccount: @escaping @Sendable () async throws -> Account? = { nil }
    ) {
        self.signOut = signOut
        self.currentAccount = currentAccount
    }
}

extension SessionClient: DependencyKey {
    public static let liveValue = Self(signOut: {
        try await MainActor.run {
            try AuthClient.liveValue.configure()
            try FirebaseAuth.Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
        }
    }, currentAccount: {
        try await MainActor.run {
            try AuthClient.liveValue.configure()
            return FirebaseAuth.Auth.auth().currentUser.map { Account(id: $0.uid, email: $0.email) }
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
