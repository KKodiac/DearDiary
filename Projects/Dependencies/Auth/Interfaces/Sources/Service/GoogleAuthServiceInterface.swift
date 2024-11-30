import GoogleSignIn
import UIKit

public protocol GoogleAuthServiceInterface {
    func login(_: String, vc: UIViewController) async throws -> AuthCredential
    func logout() async throws
}

class GoogleAuthService: NSObject {
    
}
