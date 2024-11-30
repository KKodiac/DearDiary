import GoogleSignIn
import UIKit

public protocol GoogleAuthServiceInterface {
    @MainActor func login(_: String, vc: UIViewController) async throws -> AuthCredential
    @MainActor func logout() async throws
}

class GoogleAuthService: NSObject {
    
}
