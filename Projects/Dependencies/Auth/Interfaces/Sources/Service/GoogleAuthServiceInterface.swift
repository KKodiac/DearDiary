import GoogleSignIn
import UIKit

public protocol GoogleAuthServiceInterface {
    @MainActor func login(_: String) async throws -> AuthCredential
    @MainActor func logout() async throws
}

final class GoogleAuthService: NSObject {
    
}
