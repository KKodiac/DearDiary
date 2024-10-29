import ComposableArchitecture
import Firebase

struct EmailCredential {
    var email: String
    var password: String
}

extension DependencyValues {
    var firebase: FirebaseProviderService {
        FirebaseProviderService(
            registerWithFirebaseAuthEmail: { credentials in
                let authObject = Firebase.Auth.auth()
                return try await authObject
                    .createUser(
                        withEmail: credentials.email,
                        password: credentials.password
                    )
            },
            authenticateWithFirebaseAuthEmail: { credentials in
                let authObject = Firebase.Auth.auth()
                return try await authObject
                    .signIn(
                        withEmail: credentials.email,
                        password: credentials.password
                    )
            },
            authenticateWithFirebaseAuthSocialProvider: { credentials in
                let authObject = Firebase.Auth.auth()
                return try await authObject.signIn(with: credentials)
            },
            invalidateWithFirebaseAuth: {
                let authObject = Firebase.Auth.auth()
                try authObject.signOut()
            },
            configureFirebaseWithOptions: {
                guard let path = Bundle.main.path(
                    forResource: "Info", ofType: "plist"
                ) else {
                    fatalError("Unable to find Info.plist")
                }
                
                guard let options = FirebaseOptions(contentsOfFile: path) else {
                    assert(false, "Couldn't load configuration file")
                    return
                }
                
                FirebaseApp.configure(options: options)
            },
            makeRandomNonceString: {
                let length = 32
                var randomBytes = [UInt8](repeating: 0, count: length)
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                
                let charset: [Character] =
                Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
                
                let nonce = randomBytes.map { byte in
                    charset[Int(byte) % charset.count]
                }
                
                return String(nonce)
            }
        )
    }
}

struct FirebaseProviderService {
    var registerWithFirebaseAuthEmail: (
        EmailCredential
    ) async throws -> AuthDataResult
    var authenticateWithFirebaseAuthEmail: (
        EmailCredential
    ) async throws -> AuthDataResult
    var authenticateWithFirebaseAuthSocialProvider: (
        AuthCredential
    ) async throws -> AuthDataResult
    var invalidateWithFirebaseAuth: () async throws -> Void
    var configureFirebaseWithOptions: () -> Void
    var makeRandomNonceString: () -> String
}
