import FirebaseAuth
import ExternalDependencies

extension FirebaseAuthService: FirebaseAuthServiceInterface {
    // Firebase's default-app lookup logs an error before configuration. Keep the
    // successfully initialized handle so readiness checks never call that lookup.
    private static let configuredApp = LockIsolated<FirebaseApp?>(nil)

    var clientID: String? {
        Self.configuredApp.value?.options.clientID
    }

    var isConfigured: Bool {
        Self.configuredApp.value != nil
    }
    
    @MainActor
    func configure() throws {
        guard !isConfigured else { return }
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
              let options = FirebaseOptions(contentsOfFile: path) else {
            throw FirebaseAuthError.failedToConfigureFirebaseApp
        }
        
        let appID = options.googleAppID
        guard appID.range(of: #"^1:[0-9]+:ios:[a-fA-F0-9]+$"#, options: .regularExpression) != nil,
              let apiKey = options.apiKey, !apiKey.isEmpty, !apiKey.hasPrefix("CONFIGURE_"),
              options.bundleID == Bundle.main.bundleIdentifier else {
            throw FirebaseAuthError.failedToConfigureFirebaseApp
        }
        FirebaseApp.configure(options: options)
        Self.configuredApp.setValue(FirebaseApp.app())
    }
    
    func signIn(_ auth: AuthCredential) async throws -> AuthDataResult {
        let authApp = FirebaseAuth.Auth.auth()
        return try await authApp.signIn(with: auth)
    }
    
    func signIn(email: String, password: String) async throws -> AuthDataResult {
        let authApp = FirebaseAuth.Auth.auth()
        return try await authApp.signIn(withEmail: email, password: password)
    }
    
    func signUp(email: String, password: String) async throws -> AuthDataResult {
        let authApp = FirebaseAuth.Auth.auth()
        return try await authApp.createUser(withEmail: email, password: password)
    }
    
    func signOut() throws {
        let authApp = FirebaseAuth.Auth.auth()
        try authApp.signOut()
    }
}
